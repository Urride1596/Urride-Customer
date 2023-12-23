import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/model/user_model.dart';
import 'package:Urride/page/auth_screens/login_screen.dart';
import 'package:Urride/page/contact_us/contact_us_screen.dart';
import 'package:Urride/page/coupon_code/coupon_code_screen.dart';
import 'package:Urride/page/dash_board.dart';
import 'package:Urride/page/favotite_ride_screens/favorite_ride_screen.dart';
import 'package:Urride/page/localization_screens/localization_screen.dart';
import 'package:Urride/page/my_profile/my_profile_screen.dart';
import 'package:Urride/page/new_ride_screens/new_ride_screen.dart';
import 'package:Urride/page/privacy_policy/privacy_policy_screen.dart';
import 'package:Urride/page/referral_screen/referral_screen.dart';
import 'package:Urride/page/rent_vehicle_screens/rent_vehicle_screen.dart';
import 'package:Urride/page/rented_vehicle.dart';
import 'package:Urride/page/terms_service/terms_of_service_screen.dart';
import 'package:Urride/page/wallet/wallet_screen.dart';
import 'package:Urride/service/api.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:launch_review/launch_review.dart';
import '../page/home_screens/home_screen.dart';

class DashBoardController extends GetxController {
  RxInt selectedDrawerIndex = 0.obs;

  @override
  void onInit() {
    getUsrData();
    updateToken();
    getPaymentSettingData();
    super.onInit();
  }

  UserModel? userModel;

  getUsrData() {
    userModel = Constant.getUserData();
  }

  updateToken() async {
    // use the returned token to send messages to users from your custom server
    String? token = await FirebaseMessaging.instance.getToken();

    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        updateFCMToken(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  final drawerItems = [
    DrawerItem('home', CupertinoIcons.home),
    DrawerItem('All Rides', Icons.local_car_wash),

    DrawerItem('promo_code', Icons.discount),
    DrawerItem('my_wallet', Icons.account_balance_wallet_outlined),
    DrawerItem('my_profile', Icons.person_outline),
    DrawerItem('refer_a_friend', Icons.people_sharp),
    DrawerItem('change_language', Icons.language),
    DrawerItem('term_service', Icons.design_services),
    DrawerItem('privacy_policy', Icons.privacy_tip),
    DrawerItem('contact_us', Icons.support_agent),
    DrawerItem('rate_business', Icons.rate_review_outlined),
    DrawerItem('sign_out', Icons.logout),
  ];

  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return const HomeScreen();
      case 1:
        return const NewRideScreen();
        // case 3:
      //   return const ConfirmedRideScreen();
      // case 4:
      //   return OnRideScreens();
      // case 5:
      //   return const CompletedRideScreen();
      // case 6:
      //   return const CanceledRideScreens();

      case 2:
        return const CouponCodeScreen();
      case 3:
        return WalletScreen();
      case 4:
        return MyProfileScreen();
      case 5:
        return const ReferralScreen();
      case 6:
        return const LocalizationScreens(
          intentType: "dashBoard",
        );
      case 7:
        return const TermsOfServiceScreen();
      case 8:
        return const PrivacyPolicyScreen();
      case 9:
        return const ContactUsScreen();

      default:
        return const Text("Error");
    }
  }

  onSelectItem(int index) {
    if (index == 10) {
      LaunchReview.launch(
        androidAppId: "com.digigrow.urride",
        iOSAppId: "com.digigrow.urride.ios",
      );
    } else if (index == 11) {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(LoginScreen());
    } else {
      selectedDrawerIndex.value = index;
    }
    Get.back();
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {'user_id': Preferences.getInt(Preferences.userId), 'fcm_id': token, 'device_id': "", 'user_cat': userModel!.data!.userCat};
      final response = await http.post(Uri.parse(API.updateToken), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }


  Future<dynamic> getPaymentSettingData() async {
    try {
      final response = await http.get(Uri.parse(API.paymentSetting), headers: API.header);

      log("---->");
      log("${API.header}");
      log(response.body);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
