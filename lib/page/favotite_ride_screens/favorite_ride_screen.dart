import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/favorite_controller.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/favorite_model.dart';

class FavoriteRideScreen extends StatelessWidget {
  const FavoriteRideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FavoriteController>(
      init: FavoriteController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: ConstantColors.background,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RefreshIndicator(
                onRefresh: () => controller.favouriteData(),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : controller.favouriteList.isEmpty
                        ? Constant.emptyView(
                            context, "You have not any favourite ride".tr, true)
                        : ListView.builder(
                            itemCount: controller.favouriteList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return newRideWidgets(context, controller,
                                  controller.favouriteList[index], index);
                            }),
              ),
            ));
      },
    );
  }

  Widget newRideWidgets(BuildContext context, FavoriteController controller,
      Data data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.near_me, color: Colors.black),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(data.departName.toString()),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => Container(
                            margin: const EdgeInsets.all(2),
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            )),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me,
                        color: Color(0xff040096),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(data.destinationName.toString()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset("assets/icons/ic_distance.png",
                              height: 24, width: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child:
                                Text("${data.distance} ${data.distanceUnit}"),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.date_range, color: ConstantColors.yellow),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("${data.creer}m"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ButtonThem.buildButton(context,
                  btnWidthRatio: 0.3,
                  btnHeight: 35,
                  title: 'delete'.tr,
                  btnColor: ConstantColors.yellow,
                  txtColor: Colors.black, onPress: () {
                deleteFavDialog(context, controller, index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  deleteFavDialog(
      BuildContext context, FavoriteController controller, int index) {
    Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        Get.back();
        controller
            .deleteFavouriteRide(controller.favouriteList[index].id.toString())
            .then((value) {
          if (value != null) {
            if (value['success'] == "success") {
              controller.favouriteList.removeAt(index);
              ShowToastDialog.showToast(
                  "Favourite ride delete successfully".tr);
            } else {
              ShowToastDialog.showToast(value['error']);
            }
          }
        });
      },
    );
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No".tr),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Favourite".tr),
      content: Text("Are you sure you want to delete favourite ride?".tr),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
