import 'dart:io';
import 'package:SocialNetwork/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  var _imageFile;
  bool _isUploading = false;
  String _postId = Uuid().v4();
  String userImg;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _captionController = TextEditingController();

  Future<dynamic> getData() async {
    final DocumentReference document = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUser.uid);

    await document.get().then<dynamic>((DocumentSnapshot document) async {
      setState(() {
        userImg = document['profilePhoto'];
      });
    });
  }

  Future getImageFromCamera() async {
    Navigator.pop(context);
    var image = await _picker.getImage(source: ImageSource.camera);
    setState(() => _imageFile = File(image.path));
  }

  Future getImageFromGallery() async {
    Navigator.pop(context);
    var image = await _picker.getImage(source: ImageSource.gallery);
    setState(() => _imageFile = File(image.path));
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: [
            SimpleDialogOption(
              child: Text('Photo with Camera'),
              onPressed: getImageFromCamera,
            ),
            SimpleDialogOption(
              child: Text('Photo from Gallery'),
              onPressed: getImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SvgPicture.asset(
              'assets/images/upload.svg',
              height: 250.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_imageFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$_postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _imageFile = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$_postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description, dynamic data}) {
    postsRef.doc(data['userId']).collection('userPosts').doc(_postId).set({
      "postId": _postId,
      "ownerId": data['userId'],
      "username": data['name'],
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
    // we need to see our posts in timeline
    timelineRef.doc(data['userId']).collection('timelinePosts').doc(_postId).set({
      "postId": _postId,
      "ownerId": data['userId'],
      "username": data['name'],
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  handleSubmit(data) async {
    setState(() {
      _isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(_imageFile);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: _locationController.text,
      description: _captionController.text,
      data: data,
    );
    _captionController.clear();
    _locationController.clear();
    setState(() {
      _imageFile = null;
      _isUploading = false;
    });
  }

  Scaffold buildUploadForm(data) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: _isUploading ? null : () => handleSubmit(data),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blue[200],
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _isUploading ? LinearProgressIndicator() : Text(''),
          Container(
            height: 210.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_imageFile),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(widget.currentUser.photoURL),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use current location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    _locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<DocumentSnapshot>(
      future: usersRef.doc(widget.currentUser.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          return _imageFile == null
              ? buildSplashScreen()
              : buildUploadForm(data);
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
