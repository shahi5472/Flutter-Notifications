import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show File, Platform;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}

class NotificationPlugin {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification> _behaviorSubject =
      BehaviorSubject<ReceivedNotification>();

  var initializationSettings;

  NotificationPlugin._() {
    init();
  }

  init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecific();
  }

  void _requestIOSPermission() {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(alert: false, badge: true, sound: true);
  }

  void initializePlatformSpecific() {
    //For Android
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_notification');

    //For IOS
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          ReceivedNotification receivedNotification = ReceivedNotification(
              id: id, title: title, body: body, payload: payload);
          _behaviorSubject.add(receivedNotification);
        });

    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
  }

  //For ios
  setListenerForLowerVersion(Function onLowerFunction) {
    _behaviorSubject.listen((receivedNotification) {
      onLowerFunction(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  onLowerFunction(ReceivedNotification receivedNotification) {}

  onNotificationClick(String payload) {}

  //Simple Notification
  Future<void> showNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.Max,
        priority: Priority.High,
        playSound: true,
        timeoutAfter: 50000);

    var isoChannelSpecifics = IOSNotificationDetails();

    var platFormChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, isoChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      Random().nextInt(1000),
      "Test title",
      "Test body",
      platFormChannelSpecifics,
      payload: "Test payload",
    );
  }

  //Schedule a Notification
  Future<void> scheduleNotification() async {
    var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    var androidChannelSpecifics = AndroidNotificationDetails(
      "channelId 1",
      "channelName 1",
      "channelDescription 1",
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    var isoChannelSpecifics = IOSNotificationDetails();

    var platFormChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, isoChannelSpecifics);

    await _flutterLocalNotificationsPlugin.schedule(
      Random().nextInt(10000),
      "Test title",
      "Test body",
      scheduleNotificationDateTime,
      platFormChannelSpecifics,
      payload: "Test payload",
    );
  }

  //Repeated Notifications
  Future<void> repeatNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      "channelId 3",
      "channelName 3",
      "channelDescription 3",
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
    );

    var isoChannelSpecifics = IOSNotificationDetails();

    var platFormChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, isoChannelSpecifics);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      Random().nextInt(100),
      "Test title",
      "Test body",
      RepeatInterval.EveryMinute,
      platFormChannelSpecifics,
      payload: "Test payload",
    );
  }

  //Show Notification with Attachment
  Future<void> showNotificationWithAttachment() async {
    var attachmentPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/800x200', 'attachment_img.jpg');
    var iOSPlatformSpecifics = IOSNotificationDetails(
      attachments: [IOSNotificationAttachment(attachmentPicturePath)],
    );
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(attachmentPicturePath),
      contentTitle: '<b>Attached Image</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Test Image',
      htmlFormatSummaryText: true,
    );
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL ID 2',
      'CHANNEL NAME 2',
      'CHANNEL DESCRIPTION 2',
      importance: Importance.High,
      priority: Priority.High,
      styleInformation: bigPictureStyleInformation,
    );
    var notificationDetails =
        NotificationDetails(androidChannelSpecifics, iOSPlatformSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      Random().nextInt(1000000),
      'Title with attachment',
      'Body with Attachment',
      notificationDetails,
    );
  }

  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  //Show Weekly at Day and Time
  Future<void> showWeeklyAtDayTime() async {
    var time = Time(10, 0, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 5',
      'CHANNEL_NAME 5',
      "CHANNEL_DESCRIPTION 5",
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await _flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      Random().nextInt(1000000),
      'Test Title at ${time.hour}:${time.minute}.${time.second}',
      'Test Body', //null
      Day.Saturday,
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  //Show Notification Daily at a time
  Future<void> showDailyAtTime() async {
    var time = Time(18, 0, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 4',
      'CHANNEL_NAME 4',
      "CHANNEL_DESCRIPTION 4",
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      Random().nextInt(100000000),
      'Test Title at ${time.hour}:${time.minute}.${time.second}',
      'Test Body', //null
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();
