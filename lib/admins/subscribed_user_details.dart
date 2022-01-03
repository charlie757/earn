import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mny_champ/SharedFiles/loading.dart';

class SubscribedUserDetails extends StatefulWidget {
  final String currentPlan;
  final QueryDocumentSnapshot? querySnapshot;

  const SubscribedUserDetails({Key? key, required this.querySnapshot, required this.currentPlan})
      : super(key: key);

  @override
  _SubscribedUserDetailsState createState() => _SubscribedUserDetailsState();
}

class _SubscribedUserDetailsState extends State<SubscribedUserDetails> {
  bool loading = false;
  late DocumentSnapshot _documentSnapshot;

  _getChampDetails() async {
    String ref = 'Subscribed'+widget.currentPlan[0].toUpperCase()+widget.currentPlan.substring(1)+'Users';
    _documentSnapshot = await FirebaseFirestore.instance.collection(ref).doc(widget.querySnapshot!.id).get();
    setState(() => loading=false );
  }

  @override
  void initState() {
    super.initState();
    setState(() => loading=true );
    _getChampDetails();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('Subscribed ' + widget.currentPlan[0].toUpperCase() + widget.currentPlan.substring(1) + ' User: ' +
            _documentSnapshot.get('champ_id').toString()),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.pink,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectableText('Referencer: ' +
                          (_documentSnapshot.get('referencerID'))
                      ),
                    ],
                  )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                  title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Running Level: ' +
                      (_documentSnapshot.get('currentLevel') + 1)
                          .toString()),
                ],
              )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(color: Colors.green,
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Wallet Balance: ' +
                          (_documentSnapshot.get('wallet_balance'))
                              .toString(),style: TextStyle(color: Colors.white)),
                    ],
                  )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                  title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText('Sub Pay ID:    ' +
                      (_documentSnapshot.get('subscriptionPaymentID'))),
                ],
              )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Subscribed On Date: ' +
                          (_documentSnapshot.get('subscriptionDate').toDate())
                              .toString()),
                    ],
                  )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectableText('User ID:    ' +
                          (_documentSnapshot.id)
                      ),
                    ],
                  )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Referrels List: ' +
                          (_documentSnapshot.get('myReferrels').toString())
                      ),
                    ],
                  )),
            ),
          ),
          Container(child: Text(_documentSnapshot.data().toString())),
        ],
      ),
    );
  }
}