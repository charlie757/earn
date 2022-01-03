import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../SharedFiles/loading.dart';

class ShareText extends StatefulWidget {
  const ShareText({Key? key}) : super(key: key);

  @override
  _ShareTextState createState() => _ShareTextState();
}

class _ShareTextState extends State<ShareText> {
  bool loading = false;
  String? shareText;

  TextEditingController _shareController = TextEditingController();

  void getShareText() async {
    setState(() {
      loading = true;
    });
    await FirebaseFirestore.instance.collection('AllotableChampID').doc('allotable_champ_id').get().then((value) => shareText = value.data()!['shareText']);
    setState(() {
      loading = false;
      _shareController.text = shareText!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getShareText();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('Share Text'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        elevation: 0.0,
      ),
      body: ListView(
        children: [
          Container(height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _shareController,
                  keyboardType: TextInputType.text,
                  maxLines: 20,
                  onChanged: (val) {
                    shareText = val;
                  },
                  decoration: InputDecoration(hintText: 'Share Text', labelText: 'Share Text'),
                ),
                SizedBox(height: 20,),
                ElevatedButton(child: Text('Update'), onPressed: _updateShareText)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateShareText() async {
    if (shareText!.length > 50) {
      setState(() {
        loading = true;
      });
      _shareController.clear();
      await FirebaseFirestore.instance.collection('AllotableChampID').doc(
          'allotable_champ_id').update({
        'shareText': shareText
      });
      Fluttertoast.showToast(msg: 'Share Text Updated Successfully.',
          textColor: Colors.white,
          backgroundColor: Colors.green,
          gravity: ToastGravity.CENTER);
      setState(() {
        loading = false;
      });
    }
  }
}