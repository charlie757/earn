import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../SharedFiles/dialog_maker.dart';
import '../SharedFiles/loading.dart';
import 'package:timeago/timeago.dart' as timeago;

class SubPaymentDetails extends StatefulWidget {
  @override
  _SubPaymentDetailsState createState() => _SubPaymentDetailsState();
}

class _SubPaymentDetailsState extends State<SubPaymentDetails> {
  bool loading = false;

  late QuerySnapshot _querySnapshot;

  void fetchSubscriptionPayments() async {
    await FirebaseFirestore.instance.collection('SubscriptionPayments').get().then((payments) {
      _querySnapshot = payments;
    }).then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      loading = true;
    });
    fetchSubscriptionPayments();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Subscription Payments: '+ _querySnapshot.size.toString()),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _recievedSubscriptionPaymentsList()
    );
  }

  Widget _recievedSubscriptionPaymentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('SubscriptionPayments').orderBy('subscriptionDate',descending: true).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Loading();
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.all(5.0),
            itemBuilder: (context, i) {
              return Container(
                padding: EdgeInsets.all(5.0),
                child: Card(
                  color: Colors.blue,
                  child: ListTile(
                    onTap: () => _paymentDetails(snapshot, i),
                    title: SelectableText(snapshot.data!.docs[i].id,
                        style: TextStyle(
                            color: Colors.white,fontSize: 16.0,fontWeight: FontWeight.bold
                        )),
                    subtitle: Text(timeago
                        .format(DateTime.tryParse(snapshot
                        .data!.docs[i].get('subscriptionDate')
                        .toDate()
                        .toString())!)
                        .toString(),style: TextStyle(color: Colors.black,fontSize: 16.0)),
                  ),
                ),
              );
            });
      },
    );
  }

  void _paymentDetails(AsyncSnapshot snapshot, int i) async {
    var payerName;
    var payerPhone;
    var payerID;

    await FirebaseFirestore.instance.collection('Users').doc(snapshot.data.docs[i].data()['subscriberID']).get().then((subscriberDoc) {
      payerName = subscriberDoc.data()!['username'];
      payerPhone = subscriberDoc.data()!['phone'];
      payerID = subscriberDoc.data()!['id'];
    });

    cDialog(
        context,
        Icon(Icons.monetization_on,
            color: Colors.green),
        " Payment Details!",
        'Name: '+ payerName + '\n\nPhone: '+ payerPhone +'\n\nDate: '+(snapshot
            .data.docs[i].data()['subscriptionDate']
            .toDate()
            .toString()) +'\n\nPayment ID: '+ snapshot.data.docs[i].id +'\n\nSubscriber ID: '+ payerID,
        300,
        Color.fromARGB(255, 0, 113, 219),
        Color.fromARGB(255, 0, 113, 219), Container());
  }
}