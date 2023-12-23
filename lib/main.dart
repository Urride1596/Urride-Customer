import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/controller/dash_board_controller.dart';
import 'package:Urride/controller/settings_controller.dart';
import 'package:Urride/model/ride_model.dart';
import 'package:Urride/page/localization_screens/localization_screen.dart';
import 'package:Urride/page/route_view_screen/route_view_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'page/auth_screens/login_screen.dart';
import 'page/chats_screen/conversation_screen.dart';
import 'page/completed_ride_screens/trip_history_screen.dart';
import 'page/dash_board.dart';
import 'page/on_boarding_screen.dart';
import 'service/localization_service.dart';
import 'themes/constant_colors.dart';
import 'utils/Preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  Stripe.publishableKey = Constant.stripePublishablekey;
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.initPref();

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (!Platform.isIOS) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {}

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        print('=====ON MESSAGE======');
        if (message.data['status'] == "done") {
          await Get.to(ConversationScreen(), arguments: {
            'receiverId': int.parse(json.decode(message.data['message'])['senderId'].toString()),
            'orderId': int.parse(json.decode(message.data['message'])['orderId'].toString()),
            'receiverName': json.decode(message.data['message'])['senderName'].toString(),
            'receiverPhoto': json.decode(message.data['message'])['senderPhoto'].toString(),
          });
        } else if (message.data['statut'] == "confirmed" || message.data['statut'] == "driver_rejected") {
          DashBoardController dashBoardController = Get.put(DashBoardController());
          dashBoardController.selectedDrawerIndex.value = 1;
          await Get.to(DashBoard());
        } else if (message.data['statut'] == "on ride") {
          var argumentData = {'type': 'on_ride'.tr, 'data': RideData.fromJson(message.data)};
          Get.to(const RouteViewScreen(), arguments: argumentData);
        } else if (message.data['statut'] == "completed") {
          Get.to(const TripHistoryScreen(), arguments: {
            "rideData": RideData.fromJson(message.data),
          });
        }
      }
    });

    await FirebaseMessaging.instance.subscribeToTopic("Urride");
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {});

    await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "01",
            "Urride",
            importance: Importance.max,
            priority: Priority.high,
          ));

      await FlutterLocalNotificationsPlugin().show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    setupInteractedMessage(context);
    Future.delayed(const Duration(seconds: 3), () {
      if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
        LocalizationService().changeLocale(Preferences.getString(Preferences.languageCodeKey).toString());
      }
    });
    return GetMaterialApp(
      title: 'Urride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: ConstantColors.primary,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.locale,
      translations: LocalizationService(),
      builder: EasyLoading.init(),
      home: GetBuilder(
          init: SettingsController(),
          builder: (controller) {
            return Preferences.getString(Preferences.languageCodeKey).toString().isEmpty
                ? const LocalizationScreens(intentType: "main")
                : Preferences.getBoolean(Preferences.isFinishOnBoardingKey)
                ? Preferences.getBoolean(Preferences.isLogin)
                ? DashBoard()
                : LoginScreen()
                : const OnBoardingScreen(intentType: "main",);
          }),
    );
  }
}
