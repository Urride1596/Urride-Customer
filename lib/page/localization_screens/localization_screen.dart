import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/localization_controller.dart';
import 'package:Urride/page/on_boarding_screen.dart';
import 'package:Urride/service/localization_service.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationScreens extends StatelessWidget {
  final String intentType;

  const LocalizationScreens({Key? key, required this.intentType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<LocalizationController>(
      init: LocalizationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: intentType == "dashBoard"
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(top: 30),
                  child: Text(
                    'select_language'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.languageList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Obx(
                        () => InkWell(
                          onTap: () {
                            controller.selectedLanguage.value =
                                controller.languageList[index].code.toString();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: controller.languageList[index].code ==
                                      controller.selectedLanguage.value
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: ConstantColors.primary),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(
                                              5.0) //                 <--- border radius here
                                          ),
                                    )
                                  : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(controller
                                              .languageList[index].language
                                              .toString(),
                                            style: TextStyle(
                                            color: Colors.white,
                                              fontSize: 30// Set white color for the text
                                            // Add any other text style properties as needed
                                          ),

                                          ),


                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                LocalizationService()
                    .changeLocale(controller.selectedLanguage.value);
                Preferences.setString(Preferences.languageCodeKey,
                    controller.selectedLanguage.toString());
                if (intentType == "dashBoard") {
                  ShowToastDialog.showToast("Language change successfully".tr);
                } else {
                  Get.offAll(const OnBoardingScreen(intentType: '',));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.black,
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.navigate_next, size: 32),
            ),
          ),
        );
      },
    );
  }
}
