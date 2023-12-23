// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/phone_number_controller.dart';
import 'package:Urride/page/auth_screens/add_profile_photo_screen.dart';
import 'package:Urride/page/dash_board.dart';
import 'package:Urride/service/api.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../themes/constant_colors.dart';
import 'signup_screen.dart';

class OtpScreen extends StatelessWidget {
  String? phoneNumber;
  String? verificationId;

  OtpScreen({Key? key, required this.phoneNumber, required this.verificationId})
      : super(key: key);

  final controller = Get.put(PhoneNumberController());
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          height: Get.height,

          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Enter OTP".tr,
                          style: const TextStyle(
                              letterSpacing: 0.60,
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                            width: 80,
                            child: Divider(
                              color: Colors.limeAccent,
                              thickness: 3,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Pinput(
                            controller: textEditingController,
                            defaultPinTheme: PinTheme(
                              height: 50,
                              width: 50,
                              textStyle: const TextStyle(
                                  letterSpacing: 0.60,
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                              // margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.limeAccent,
                                    width: 1.0),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            length: 6,
                          ),

                          // PinCodeTextField(
                          //   length: 6,
                          //   appContext: context,
                          //   keyboardType: TextInputType.phone,
                          //   textInputAction: TextInputAction.done,
                          //   pinTheme: PinTheme(
                          //     fieldHeight: 50,
                          //     fieldWidth: 50,
                          //     activeColor: ConstantColors.textFieldBoarderColor,
                          //     selectedColor:
                          //         ConstantColors.textFieldBoarderColor,
                          //     inactiveColor:
                          //         ConstantColors.textFieldBoarderColor,
                          //     activeFillColor: Colors.white,
                          //     inactiveFillColor: Colors.white,
                          //     selectedFillColor: Colors.white,
                          //     shape: PinCodeFieldShape.box,
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   enableActiveFill: true,
                          //   cursorColor: ConstantColors.primary,
                          //   controller: textEditingController,
                          //   onCompleted: (v) async {},
                          //   onChanged: (value) {
                          //     log(value);
                          //   },
                          // ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'done'.tr,
                              btnHeight: 50,
                              btnColor: Colors.limeAccent,
                              txtColor: Colors.black,
                              onPress: () async {
                                FocusScope.of(context).unfocus();

                                if (textEditingController.text.length == 6) {
                                  ShowToastDialog.showLoader("Verify OTP".tr);
                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId:
                                              verificationId.toString(),
                                          smsCode: textEditingController.text);
                                  await FirebaseAuth.instance
                                      .signInWithCredential(credential)
                                      .then((value) async {
                                    Map<String, String> bodyParams = {
                                      'phone': phoneNumber.toString(),
                                      'user_cat': "customer",
                                    };
                                    await controller
                                        .phoneNumberIsExit(bodyParams)
                                        .then((value) async {
                                      if (value == true) {
                                        Map<String, String> bodyParams = {
                                          'phone': phoneNumber.toString(),
                                          'user_cat': "customer",
                                        };
                                        await controller
                                            .getDataByPhoneNumber(bodyParams)
                                            .then((value) {
                                          if (value != null) {
                                            if (value.success == "success") {
                                              ShowToastDialog.closeLoader();

                                              Preferences.setInt(
                                                  Preferences.userId,
                                                  int.parse(value.data!.id
                                                      .toString()));
                                              Preferences.setString(
                                                  Preferences.user,
                                                  jsonEncode(value));
                                              Preferences.setString(
                                                  Preferences.accesstoken,
                                                  value.data!.accesstoken
                                                      .toString());
                                              Preferences.setString(
                                                  Preferences.admincommission,
                                                  value.data!.adminCommission
                                                      .toString());
                                              API.header['accesstoken'] =
                                                  Preferences.getString(
                                                      Preferences.accesstoken);

                                              if (value.data!.photo == null ||
                                                  value.data!.photoPath
                                                      .toString()
                                                      .isEmpty) {
                                                Get.to(() =>
                                                    AddProfilePhotoScreen());
                                              } else {
                                                Preferences.setBoolean(
                                                    Preferences.isLogin, true);
                                                Get.offAll(DashBoard());
                                              }
                                            } else {
                                              ShowToastDialog.showToast(
                                                  value.error);
                                            }
                                          }
                                        });
                                      } else if (value == false) {
                                        ShowToastDialog.closeLoader();
                                        Get.off(SignupScreen(
                                          phoneNumber: phoneNumber.toString(),
                                        ));
                                      }
                                    });
                                  }).catchError((error) {
                                    ShowToastDialog.closeLoader();
                                    ShowToastDialog.showToast(
                                        "Code is Invalid".tr);
                                  });
                                } else {
                                  ShowToastDialog.showToast(
                                      "Please Enter OTP".tr);
                                }
                              },
                            ))
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
