import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mny_champ/admins/admin_block.dart';
import '../FrontScreens/dash_board.dart';
import '../app/config/routes/app_pages.dart';

class UserManagement {
  //Authorized Subscriber Entry
  authorizedUsersEntry(BuildContext context) async {
    User user = FirebaseAuth.instance.currentUser!;

    bool subscriberFound = false;

    // if(!subscriberFound) {
    //   await FirebaseFirestore.instance
    //       .collection('Users')
    //       .where('id', isEqualTo: user.uid)
    //       .get()
    //       .then((docValue) {
    //     if (docValue.docs[0].exists) {
    //       if (docValue.docs[0].data()['adminUser'] == true) {
    //         if (user.uid == '2OqXR8PeWYb3h48Gti0PyK3mOED2' ||
    //             user.uid == '2P1qQT6hehS9eqzQzDgMwerJJfk2') {
    //           if (docValue.docs[0].data()['adminID'] == 'RajSinghEmitra' ||
    //               docValue.docs[0].data()['adminID'] == 'ShivaThePower') {
    //             Navigator.of(context)
    //                 .pushReplacement(MaterialPageRoute(
    //                 builder: (context) => DashBoard(currentPlan: 'premium')));
    //             subscriberFound = true;
    //             return;
    //           }
    //         }
    //       }
    //     }
    //   });
    // }

    if(!subscriberFound) {
      await FirebaseFirestore.instance
          .collection('SubscribedUsers')
          .doc(user.uid)
          .get()
          .then((docValue) {
        if (docValue.exists) {
          docValue.data()!['myPlans'].forEach((key, value){
            if(value) {
              subscriberFound = true;
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) => DashBoard(currentPlan: key.toString())));
            }
          });
        }
      });
    }
  }

  //Authorized Admin access
  authorizedAdmins(BuildContext context, String currentPlan) async {
    User user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection('/Users')
        .where('id', isEqualTo: user.uid)
        .get()
        .then((docValue) {
      if (docValue.docs[0].exists) {
        if (docValue.docs[0].data()['adminUser'] == true) {
          if (user.uid == '2OqXR8PeWYb3h48Gti0PyK3mOED2' ||
              user.uid == '2P1qQT6hehS9eqzQzDgMwerJJfk2') {
            if (docValue.docs[0].data()['adminID'] == 'RajSinghEmitra' ||
                docValue.docs[0].data()['adminID'] == 'ShivaThePower') {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AdminBlock(currentPlan: currentPlan)));
            }
          } else {
            Fluttertoast.showToast(msg: 'Not authorized admin');
          }
        }
      }
    });
  }

  // sign out
  Future signOut() async {
    try {
      return await FirebaseAuth.instance.signOut().then((value) => Get.offNamed(Routes.login));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}