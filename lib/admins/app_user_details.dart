import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../SharedFiles/loading.dart';

// ignore: must_be_immutable
class AppUserDetails extends StatefulWidget {
  DocumentSnapshot snapshot;

  AppUserDetails({required this.snapshot});

  @override
  _AppUserDetailsState createState() => _AppUserDetailsState();
}

class _AppUserDetailsState extends State<AppUserDetails> {
  bool loading = false;
  bool payMode = false;

  getUserData() async {
    await FirebaseFirestore.instance.collection('Users').doc(widget.snapshot.id).get().then((value) {
      payMode = value.data()!['testMode'];
      setState(() => loading = false);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() => loading = true);
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(widget.snapshot.get('username')),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: loading ? Loading() : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(color: Colors.black26,
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text('Phone Number:'),
                    ),
                    Expanded(
                      child: SelectableText(widget.snapshot.get('phone'),style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(color: Colors.black26,
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text('Allow For Test Payment:'),
                    ),
                    Expanded(
                      child: Switch(value: payMode, onChanged: _changePaymentMode),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePaymentMode(bool value) async {
    if (value) {
      setState(() {
        payMode = true;
        loading = true;
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snapshot.id)
          .update({'testMode': payMode}).then(
              (val) {
            setState(() {
              loading = false;
            });
          });
    } else {
      setState(() {
        payMode = false;
        loading = true;
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snapshot.id)
          .update({'testMode': payMode}).then(
              (val) {
            setState(() {
              loading = false;
            });
          });
    }
  }
}