import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mny_champ/SharedFiles/loading.dart';

class UnSubscribedUsers extends StatefulWidget {
  @override
  _UnSubscribedUsersState createState() => _UnSubscribedUsersState();
}

class _UnSubscribedUsersState extends State<UnSubscribedUsers> {
  bool loading = true;
  late String totalUsers;

  List<DocumentSnapshot> _unsubscribedUsers = [];

  fetchUsers() async {
    await FirebaseFirestore.instance.collection('Users').get().then((users) async {
      for(int i=0; i< users.docs.length; i++) {
        await FirebaseFirestore.instance.collection('SubscribedUsers').doc(users.docs[i].id).get().then((value) {
          if(value.exists == false) {
            _unsubscribedUsers.add(users.docs[i]);
          }
        });
      }
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
        title: Text('UnSubscribed Users: ' + _unsubscribedUsers.length.toString()),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:20.0),
            child: InkWell(child: Icon(Icons.notifications), onTap: _sendAlert),
          )
        ],
      ),
      body: _unRegisteredUsersList(),
    );
  }

  Widget _unRegisteredUsersList() {
    return ListView.builder(
        itemCount: _unsubscribedUsers.length,
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, int i) {
          return Container(
            padding: EdgeInsets.all(5.0),
            child: Card(
              color: Colors.red,
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                          _unsubscribedUsers[i].get('username'),
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
                subtitle: Text(_unsubscribedUsers[i].get('installationDate')
                    .toDate()
                    .toString()),
                trailing: SelectableText(_unsubscribedUsers[i].get('phone')),
              ),
            ),
          );
        });
  }

  void _sendAlert () async {
    Random random = new Random();
    int randomNumber = random.nextInt(90) + 10;
    setState(() => loading = true );
    await FirebaseFirestore.instance.collection('AlertUnsubscribedUsers').doc('AlertForUsers').update(
        {
          "alertTag": randomNumber,
        }).then((value) {
      setState(() => loading = false );
      Fluttertoast.showToast(msg: 'Alert sent successfully.', textColor: Colors.white, backgroundColor: Colors.green, gravity: ToastGravity.CENTER);
    });
  }
}