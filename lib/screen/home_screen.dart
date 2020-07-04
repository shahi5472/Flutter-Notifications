import 'package:flutter/material.dart';
import 'package:flutter_notifications_demo/utilits/notification_plugin.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    notificationPlugin.setListenerForLowerVersion(onLowerFunction);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Local Notifications"),
      ),
      body: Container(
        child: Center(
          child: RaisedButton(
            child: Text("Send Notification"),
            onPressed: () async {
              await notificationPlugin.showNotification();
              await notificationPlugin.scheduleNotification();
              await notificationPlugin.repeatNotification();
              await notificationPlugin.showNotificationWithAttachment();
              await notificationPlugin.showWeeklyAtDayTime();
              await notificationPlugin.showDailyAtTime();
            },
          ),
        ),
      ),
    );
  }

  onNotificationClick() {}

  onLowerFunction() {}
}
