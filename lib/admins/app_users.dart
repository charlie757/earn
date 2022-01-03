import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mny_champ/SharedFiles/loading.dart';
import 'package:mny_champ/admins/app_user_details.dart';

class AppUsers extends StatefulWidget {
  @override
  _AppUsersState createState() => _AppUsersState();
}

class _AppUsersState extends State<AppUsers> {
  bool loading = true;
  late String totalUsers;

  fetchUsers() async {
    FirebaseFirestore.instance.collection('Users').get().then((users) async {
      totalUsers = users.docs.length.toString();
    }).then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    totalUsers = '';
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pink,
              title: Text('Total Users: ' + totalUsers),
              centerTitle: true,
            ),
            body: _totalUsersList(),
          );
  }

  Widget _totalUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .orderBy('installationDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.all(5.0),
            itemBuilder: (context, i) {
              return Container(
                padding: EdgeInsets.all(5.0),
                child: Card(
                  color: Colors.blue,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppUserDetails(snapshot: snapshot.data!.docs[i])));
                    },
                    child: ListTile(
                      title: Text(
                          snapshot.data!.docs[i].get('username'),
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      subtitle: Text(snapshot
                          .data!.docs[i].get('installationDate')
                          .toDate()
                          .toString()),
                      trailing: SelectableText(snapshot.data!.docs[i].get('phone')),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}