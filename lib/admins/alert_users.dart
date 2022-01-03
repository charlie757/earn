import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../SharedFiles/loading.dart';

class AlertUsers extends StatefulWidget {
  const AlertUsers({Key? key}) : super(key: key);

  @override
  _AlertUsersState createState() => _AlertUsersState();
}

class _AlertUsersState extends State<AlertUsers> {
  bool loading = false;
  String? _titleText;
  String? _messageText;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Send Alert'),
        centerTitle: true,
        elevation: 0.0,
      ),
      bottomNavigationBar: ElevatedButton(onPressed: _sendAlert,
      child: Text('Send'),),
      body: ListView(
        children: [
          Card(color: Colors.blue.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Title', labelText: 'Title',
                    ),
                    onChanged: (value) => _titleText = value,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 20,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Message', labelText: 'Message',
                    ),
                    onChanged: (value) => _messageText = value,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  void _sendAlert () async {
    setState(() => loading = true );
    await FirebaseFirestore.instance.collection('AlertMessages').doc('AlertForUsers').update(
        {
          "alertTitle": _titleText,
          "alertMessage": _messageText
        }).then((value) {
      _titleController.clear();
      _messageController.clear();
      setState(() => loading = false );
      Fluttertoast.showToast(msg: 'Alert sent successfully.', textColor: Colors.white, backgroundColor: Colors.green, gravity: ToastGravity.CENTER);
    });
  }
}