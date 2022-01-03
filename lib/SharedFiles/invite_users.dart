import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mny_champ/UsersManageFiles/userManagement.dart';
import 'package:share/share.dart';

class InviteUsers extends StatelessWidget {

  final String userRefCode,currentPlan;
  String? shareText;

  UserManagement _userManagement = UserManagement();

  InviteUsers({required this.userRefCode,required this.currentPlan});

  Future<String> getShareText() async {
    await FirebaseFirestore.instance.collection('AllotableChampID').doc('allotable_champ_id').get().then((value) => shareText = value.data()!['shareText']);
    return shareText!;
  }

  @override
  Widget build(BuildContext context) {
    getShareText();
    // ignore: deprecated_member_use
    return InkWell(
        onTap: () async {
          await Share.share(
              shareText! + ' Referrel Code: '+ userRefCode + '\n\n Use Referrel Code: '+userRefCode,
              subject: 'MNY CHAMP');
        },
      onLongPress: () =>
          _userManagement.authorizedAdmins(context, currentPlan),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.share),
      ),
    );
  }
}