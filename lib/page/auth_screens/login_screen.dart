import 'dart:convert';

import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/login_conroller.dart';
import 'package:Urride/page/auth_screens/add_profile_photo_screen.dart';
import 'package:Urride/page/auth_screens/forgot_password.dart';
import 'package:Urride/page/auth_screens/mobile_number_screen.dart';
import 'package:Urride/page/dash_board.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/themes/text_field_them.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  static final _phoneController = TextEditingController();
  static final _passwordController = TextEditingController();
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColors.background,
        body: Container(
          decoration: const BoxDecoration(

          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login with Email".tr,
                      style: const TextStyle(
                          letterSpacing: 0.60,
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                        width: 80,
                        child: Divider(
                          color: Colors.limeAccent,

                          thickness: 3,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Form(
                        key: _loginFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFieldThem.boxBuildTextField(
                              hintText: 'Email'.tr,
                              controller: _phoneController,
                              textInputType: TextInputType.emailAddress,
                              contentPadding: EdgeInsets.zero,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Password'.tr,
                                controller: _passwordController,
                                textInputType: TextInputType.text,
                                obscureText: false,
                                contentPadding: EdgeInsets.zero,
                                validators: (String? value) {
                                  if (value!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return 'required'.tr;
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: ButtonThem.buildButton(
                                  context,
                                  title: 'log in'.tr,
                                  btnHeight: 50,
                                  btnColor: Colors.limeAccent,
                                  txtColor: Colors.black,
                                  onPress: () async {
                                    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                    sharedPreferences.setString('email' , _phoneController.text);
                                    Get.to(DashBoard());
                                    FocusScope.of(context).unfocus();
                                    if (_loginFormKey.currentState!
                                        .validate()) {
                                      Map<String, String> bodyParams = {
                                        'email': _phoneController.text.trim(),
                                        'mdp': _passwordController.text,
                                        'user_cat': "customer",
                                      };
                                      await controller
                                          .loginAPI(bodyParams)
                                          .then((value) {
                                        if (value != null) {
                                          if (value.success == "Success") {
                                            Preferences.setInt(
                                                Preferences.userId,
                                                int.parse(
                                                    value.data!.id.toString()));
                                            Preferences.setString(
                                                Preferences.user,
                                                jsonEncode(value));
                                            _phoneController.clear();
                                            _passwordController.clear();
                                            if (value.data!.photo == null ||
                                                value.data!.photoPath
                                                    .toString()
                                                    .isEmpty) {
                                              Get.to(() =>
                                                  AddProfilePhotoScreen());
                                            } else {
                                              Preferences.setBoolean(
                                                  Preferences.isLogin, true);
                                              Get.offAll(DashBoard(),
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  //duration of transitions, default 1 sec
                                                  transition:
                                                  Transition.rightToLeft);
                                            }
                                          } else {
                                            ShowToastDialog.showToast(
                                                value.error);
                                          }
                                        }
                                      });
                                    }
                                  },
                                )),
                            GestureDetector(
                              onTap: () {
                                Get.to(ForgotPasswordScreen(),
                                    duration: const Duration(
                                        milliseconds:
                                        400), //duration of transitions, default 1 sec
                                    transition: Transition.rightToLeft);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Text(
                                    "Forgot Password".tr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: ButtonThem.buildBorderButton(
                                  context,
                                  title: 'Login With Phone Number'.tr,
                                  btnHeight: 50,
                                  btnColor: Colors.limeAccent,
                                  txtColor: Colors.black,
                                  onPress: () {
                                    FocusScope.of(context).unfocus();
                                    Get.to(MobileNumberScreen(isLogin: true),
                                        duration: const Duration(
                                            milliseconds:
                                            400), //duration of transitions, default 1 sec
                                        transition: Transition.rightToLeft);
                                  },
                                  btnBorderColor: const Color(0x6ac0ff02),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(

          ),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'You don’t have an account yet? '.tr,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(MobileNumberScreen(isLogin: false),
                              duration: const Duration(
                                  milliseconds:
                                  400), //duration of transitions, default 1 sec
                              transition:
                              Transition.rightToLeft); //transition effect);
                        },
                    ),
                    TextSpan(
                      text: 'SIGNUP'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.limeAccent),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                              MobileNumberScreen(
                                isLogin: false,
                              ),
                              duration: const Duration(
                                  milliseconds:
                                  400), //duration of transitions, default 1 sec
                              transition:
                              Transition.rightToLeft); //transition effect);
                        },
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
