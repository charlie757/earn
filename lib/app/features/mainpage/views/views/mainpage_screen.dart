import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../../NotificationHandler/notification_handling.dart';
import '../../../../../PaymentFiles/payment_start.dart';
import '../../../../../SharedFiles/loading.dart';
import '../../../../../UsersManageFiles/userManagement.dart';

class MainPageScreen extends StatefulWidget {
  @override
  _MainPageScreenState createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen>
    with SingleTickerProviderStateMixin {
  bool loading = false;

  UserManagement _userManagement = UserManagement();

  NotificationHandling _notificationHandling = NotificationHandling();

  getSubscribedChamps() async {
    setState(() =>loading = true);
    await _userManagement.authorizedUsersEntry(context);
    setState(() =>loading = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _notificationHandling.handleMessaging(context);
    getSubscribedChamps();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Container(
      child: SubscriptionPayments(),
    );
  }
}