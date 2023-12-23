import 'package:Urride/controller/on_boarding_controller.dart';
import 'package:Urride/page/auth_screens/login_screen.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  final String intentType;

  const OnBoardingScreen({Key? key, required this.intentType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: intentType == "dashBoard" && controller.selectedPageIndex.value != 0
                ? InkWell(
                    onTap: () {
                      controller.pageController
                          .jumpToPage(controller.selectedPageIndex.value - 1);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  )
                : const Offstage(),
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.selectedPageIndex,
                      itemCount: controller.onBoardingList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Center(
                                  child: Image.asset(
                                    controller.onBoardingList[index].imageAsset
                                        .toString(),
                                    width: 260,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Column(
                                children: [
                                  Text(
                                    controller.onBoardingList[index].title
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40.0, vertical: 20),
                                    child: Text(
                                      controller
                                          .onBoardingList[index].description
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          letterSpacing: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                          ],
                        );
                      }),
                ),
                controller.selectedPageIndex.value == 2
                    ? ElevatedButton(
                        onPressed: () {
                          Preferences.setBoolean(
                              Preferences.isFinishOnBoardingKey, true);
                          Get.offAll(LoginScreen());
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.limeAccent),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12),
                          child: Text(
                            'Get started',
                            style: const TextStyle(
                                fontSize: 16,
                                letterSpacing: 1.5,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          controller.pageController.jumpToPage(
                              controller.selectedPageIndex.value + 1);
                        },
                        child: Text(
                          'skip'.tr,
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 1.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        )),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.onBoardingList.length,
                      (index) => Container(
                          margin: controller.selectedPageIndex.value == index
                              ? const EdgeInsets.symmetric(horizontal: 10)
                              : EdgeInsets.zero,
                          width: controller.selectedPageIndex.value == index
                              ? 50
                              : 66,
                          height: 10,
                          decoration: BoxDecoration(
                            color: controller.selectedPageIndex.value == index
                                ? Colors.limeAccent
                                : Colors.white,
                            borderRadius: borderRadius(
                                controller.selectedPageIndex.value, index),
                          )),
                    ),
                  ),
                ),

                // InkWell(onTap: () {
                //   if (controller.selectedPageIndex.value == controller.onBoardingList.length - 1) {
                //     Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                //     Get.offAll(LoginScreen());
                //   } else {
                //     controller.pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
                //   }
                // }, child: Obx(() {
                //   return Text(
                //     controller.isLastPage ? 'done'.tr : 'next'.tr,
                //     style: const TextStyle(fontSize: 16),
                //   );
                // }))
              ],
            ),
          ),
        );
      },
    );
  }

  BorderRadiusGeometry borderRadius(int index, int currentIndex) {
    if (index == 0 && currentIndex == 0) {
      return const BorderRadius.all(Radius.circular(10.0));
    }
    if (index == 0 && currentIndex == 1) {
      return const BorderRadius.only(
          topLeft: Radius.circular(40.0), bottomLeft: Radius.circular(40.0));
    }
    if (index == 0 && currentIndex == 2) {
      return const BorderRadius.only(
          topRight: Radius.circular(40.0), bottomRight: Radius.circular(40.0));
    }
    if (index == 1 && currentIndex == 1) {
      return const BorderRadius.all(Radius.circular(10.0));
    }
    if (index == 1 && currentIndex == 1) {
      return const BorderRadius.all(Radius.circular(10.0));
    }
    if (index == 1 && currentIndex == 2) {
      return const BorderRadius.all(Radius.circular(10.0));
    }
    if (index == 2 && currentIndex == 2) {
      return const BorderRadius.all(Radius.circular(10.0));
    }
    if (index == 2 && currentIndex == 0) {
      return const BorderRadius.only(
          topLeft: Radius.circular(40.0), bottomLeft: Radius.circular(40.0));
    }
    if (index == 2 && currentIndex == 1) {
      return const BorderRadius.only(
          topRight: Radius.circular(40.0), bottomRight: Radius.circular(40.0));
    }
    return const BorderRadius.all(Radius.circular(10.0));
  }
}
