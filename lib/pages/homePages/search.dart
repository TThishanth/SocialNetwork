import 'package:SocialNetwork/pages/homePages/activity_feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController _searchController = TextEditingController();
  String searchString = " ";

  AppBar buildSearchField() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white70,
      title: Container(
        width: double.infinity,
        child: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search users",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _searchController.clear(),
            ),
          ),
          onChanged: (val) {
            setState(() {
              searchString = val.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: (searchString.trim() == "" && searchString == null)
          ? usersRef.snapshots()
          : usersRef
              .where('searchIndex', arrayContains: searchString)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('We got an error ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.none:
            return Text('Oops no data present!');
          case ConnectionState.done:
            return Text('We are done!');
          default:
            return ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
              return GestureDetector(
                onTap: () =>
                    showProfile(context, profileId: document['userId']),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(document['profilePhoto']),
                  ),
                  title: Text(
                    document['name'],
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    document['email'],
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList());
        }
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildSearchField(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: buildSearchResults(),
        ),
      ),
    );
  }
}
