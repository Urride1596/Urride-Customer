// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/sign_up_controller.dart';
import 'package:Urride/page/auth_screens/add_profile_photo_screen.dart';
import 'package:Urride/page/auth_screens/login_screen.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/themes/text_field_them.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  String? phoneNumber;

  SignupScreen({Key? key, required this.phoneNumber}) : super(key: key);

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  var _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _conformPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    _phoneController = TextEditingController(text: phoneNumber);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(

          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Sign up".tr.toUpperCase(),
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
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldThem.boxBuildTextField(
                                  hintText: 'Name'.tr,
                                  controller: _firstNameController,
                                  textInputType: TextInputType.text,
                                  maxLength: 22,
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFieldThem.boxBuildTextField(
                                  hintText: 'Last Name'.tr,
                                  controller: _lastNameController,
                                  textInputType: TextInputType.text,
                                  maxLength: 22,
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
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldThem.boxBuildTextField(
                              hintText: 'phone'.tr,
                              controller: _phoneController,
                              textInputType: TextInputType.number,
                              maxLength: 13,
                              enabled: false,
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
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldThem.boxBuildTextField(
                              hintText: 'Email(Optional)'.tr,
                              controller: _emailController,
                              textInputType: TextInputType.emailAddress,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 16),
                          //   child: TextFieldThem.boxBuildTextField(
                          //     hintText: 'address'.tr,
                          //     controller: _addressController,
                          //     textInputType: TextInputType.text,
                          //     contentPadding: EdgeInsets.zero,
                          //     validators: (String? value) {
                          //       if (value!.isNotEmpty) {
                          //         return null;
                          //       } else {
                          //         return 'required'.tr;
                          //       }
                          //     },
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldThem.boxBuildTextField(
                              hintText: 'password'.tr,
                              controller: _passwordController,
                              textInputType: TextInputType.text,
                              obscureText: false,
                              contentPadding: EdgeInsets.zero,
                              validators: (String? value) {
                                if (value!.length >= 6) {
                                  return null;
                                } else {
                                  return 'Password required at least 6 characters'
                                      .tr;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldThem.boxBuildTextField(
                              hintText: 'confirm_password'.tr,
                              controller: _conformPasswordController,
                              textInputType: TextInputType.text,
                              obscureText: false,
                              contentPadding: EdgeInsets.zero,
                              validators: (String? value) {
                                if (_passwordController.text != value) {
                                  return 'Confirm password is invalid'.tr;
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldThem.boxBuildTextField(
                              hintText: 'Referral Code (Optional)'.tr,
                              controller: _referralCodeController,
                              textInputType: TextInputType.text,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Sign up'.tr,
                                btnHeight: 45,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black,
                                onPress: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    Map<String, String> bodyParams = {
                                      'firstname': _firstNameController.text
                                          .trim()
                                          .toString(),
                                      'lastname': _lastNameController.text
                                          .trim()
                                          .toString(),
                                      'phone': _phoneController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'password': _passwordController.text,
                                      'referral_code': _referralCodeController
                                          .text
                                          .toString(),
                                      // 'address': _addressController.text,
                                      'login_type': 'phone',
                                      'tonotify': 'yes',
                                      'account_type': 'customer',
                                    };
                                    await controller
                                        .signUp(bodyParams)
                                        .then((value) {
                                      if (value != null) {
                                        if (value.success == "success") {
                                          Preferences.setInt(
                                              Preferences.userId,
                                              int.parse(
                                                  value.data!.id.toString()));
                                          Preferences.setString(
                                              Preferences.user,
                                              jsonEncode(value));
                                          Get.to(AddProfilePhotoScreen());
                                        } else {
                                          ShowToastDialog.showToast(
                                              value.error);
                                        }
                                      }
                                    });
                                  }
                                },
                              )),
                        ],
                      ),
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
                        color: Colors.limeAccent,
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
      bottomNavigationBar: Container(

        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Already have an account? '.tr,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll(LoginScreen(),
                            duration: const Duration(
                                milliseconds:
                                    400), //duration of transitions, default 1 sec
                            transition:
                                Transition.rightToLeft); //transition effect);
                      },
                  ),
                  TextSpan(
                    text: ' login'.tr.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.limeAccent),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll(LoginScreen(),
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
    );
  }
}
