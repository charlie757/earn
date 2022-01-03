import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mny_champ/SharedFiles/loading.dart';
import 'package:mny_champ/admins/subscribed_user_details.dart';
import 'package:url_launcher/url_launcher.dart';
import '../SharedFiles/dialog_maker.dart';

class SubscribedUsers extends StatefulWidget {
  final String currentPlan;

  SubscribedUsers({required this.currentPlan});

  @override
  _SubscribedUsersState createState() => _SubscribedUsersState();
}

class _SubscribedUsersState extends State<SubscribedUsers> {
  bool loading = true;
  late QuerySnapshot subUsers;
  List<String> subUserNames = [];
  List<String> subUserPhones = [];
  List<Map<String, dynamic>> subUserPlans = [];

  fetchSubscribedUsers() async {
    await FirebaseFirestore.instance
        .collection('SubscribedUsers')
        .get()
        .then((users) async {
      subUsers = users;
      for (int i = 0; i < subUsers.size; i++) {
        subUserPlans.add(subUsers.docs[i].get('myPlans'));
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(subUsers.docs[i].id)
            .get()
            .then((value) {
          subUserNames.add(value.get('username'));
          subUserPhones.add(value.get('phone'));
        });
      }
    });
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    fetchSubscribedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pink,
              title: Text('Subscribed Users: ' + subUsers.size.toString()),
              centerTitle: true,
            ),
            body: _subscribedUsersList(),
          );
  }

  Widget _subscribedUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('SubscribedUsers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.all(5.0),
            itemBuilder: (context, int index) {
              return Container(
                color: Colors.blue,
                padding: EdgeInsets.all(5.0),
                child: Card(
                  elevation: 5.0,
                  child: ListTile(
                    onTap: () async {
                      String ref = 'Subscribed' +
                          widget.currentPlan[0].toUpperCase() +
                          widget.currentPlan.substring(1) +
                          'Users';
                      await FirebaseFirestore.instance
                          .collection(ref)
                          .doc(snapshot.data!.docs[index].id)
                          .get()
                          .then((val) {
                        if (val.exists) {
                          print('Hiii');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SubscribedUserDetails(
                                  querySnapshot: snapshot.data!.docs[index],
                                  currentPlan: widget.currentPlan)));
                        } else {
                          print('Hello');
                          _champNotSubscribed(snapshot, index);
                        }
                      });
                    },
                    leading: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('images/call.png'),
                        ),
                        onTap: () => launch('tel:' + subUserPhones[index])),
                    trailing: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('images/whats.png'),
                      ),
                      onTap: () => launch("whatsapp://send?phone=" +
                          subUserPhones[index] +
                          "&text="),
                    ),
                    title: Center(
                      child: Text(subUserNames[index],
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                    ),
                    subtitle: Center(
                      child: Text(subUserPlans[index].keys.toString().toUpperCase(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  void _champNotSubscribed(AsyncSnapshot snapshot, int i) async {
    var champName;
    var champPhone;
    var champAppID;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(snapshot.data.docs[i].id)
        .get()
        .then((subscriberDoc) {
      champName = subscriberDoc.data()!['username'];
      champPhone = subscriberDoc.data()!['phone'];
      champAppID = subscriberDoc.data()!['id'];
    });

    cDialog(
        context,
        Icon(Icons.warning, color: Colors.red),
        " "+ widget.currentPlan[0].toUpperCase()+widget.currentPlan.substring(1) +" Plan!",
        'Name: ' +
            champName +
            '\n\nPhone: ' +
            champPhone +
            '\n\nRegistration ID: ' +
            champAppID + '\n\nMr '+champName +' is not subscribed in '+widget.currentPlan + ' plan.',
        250,
        Color.fromARGB(255, 0, 113, 219),
        Color.fromARGB(255, 0, 113, 219),
        Container());
  }
}