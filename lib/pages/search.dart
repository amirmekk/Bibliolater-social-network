import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/pages/activity_feed.dart';
import 'package:social_network/pages/home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_network/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  Future<QuerySnapshot> searchResultFuture;
  TextEditingController searchController = TextEditingController();

  hanldeSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where(
          'displayName',
          isGreaterThanOrEqualTo: query,
        )
        .getDocuments();
    setState(() {
      searchResultFuture = users;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        onFieldSubmitted: hanldeSearch,
        decoration: InputDecoration(
          hintText: 'search for a user ...',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 20.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
            ),
            onPressed: () {
              searchController.clear();
            },
          ),
        ),
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300 : 150,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        builder: (contect, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach(
            (doc) {
              User user = User.fromDocument(doc);
              searchResults.add(UserResult(user));
            },
          );
          return ListView(
            children: searchResults,
          );
        },
        future: searchResultFuture);
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: user.id);
            },
            child: ListTile(
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl)),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
