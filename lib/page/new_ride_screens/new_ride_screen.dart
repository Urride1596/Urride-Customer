import 'dart:developer';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/new_ride_controller.dart';
import 'package:Urride/model/ride_model.dart';
import 'package:Urride/page/complaint/add_complaint_screen.dart';
import 'package:Urride/page/completed_ride_screens/trip_history_screen.dart';
import 'package:Urride/page/review_screens/add_review_screen.dart';
import 'package:Urride/page/route_view_screen/route_view_screen.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:text_scroll/text_scroll.dart';

class NewRideScreen extends StatelessWidget {
  const NewRideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<NewRideController>(
      init: NewRideController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: ConstantColors.background,
            body: RefreshIndicator(
              onRefresh: () => controller.getNewRide(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : controller.rideList.isEmpty
                    ? Constant.emptyView(
                    context,
                    "You have not booked any trip.\n Please book a cab now"
                        .tr,
                    true)
                    : ListView.builder(
                    itemCount: controller.rideList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return newRideWidgets(controller, context,
                          controller.rideList[index]);
                    }),


              ),

            )


        );

      },
    );
  }

  Widget newRideWidgets(
      NewRideController controller, BuildContext context, RideData data) {
    return InkWell(
      onTap: () async {
        if (data.statut == "completed") {
          var isDone = await Get.to(const TripHistoryScreen(), arguments: {
            "rideData": data,
          });
          if (isDone != null) {
            controller.getNewRide();
          }
        } else {
          var argumentData = {'type': data.statut.toString(), 'data': data};
          Get.to(const RouteViewScreen(), arguments: argumentData);
        }
      },
      child: Stack(
        children: [
          Padding(
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/location.png",
                              height: 20,
                            ),
                            Image.asset(
                              "assets/icons/line.png",
                              height: 30,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            data.departName.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.stops!.length,
                        itemBuilder: (context, int index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    String.fromCharCode(index + 65),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Image.asset(
                                    "assets/icons/line.png",
                                    height: 30,
                                    color: ConstantColors.hintTextColor,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.stops![index].location.toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/icons/round.png",
                          height: 18,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            data.destinationName.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: data.statut == "confirmed" &&
                          Constant.rideOtp.toString() == 'yes' &&
                          data.rideType != 'driver'
                          ? true
                          : false,
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.grey.withOpacity(0.20),
                            thickness: 1,
                          ),
                          Row(
                            children: [
                              const Text(
                                'OTP : ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                data.otp.toString(),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.grey.withOpacity(0.20),
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icons/passenger.png',
                                            height: 22,
                                            width: 22,
                                            color: Colors.limeAccent,
                                          ),
                                          Text(
                                              " ${data.numberPoeple.toString()}",
                                              //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Constant.currency.toString(),
                                          style: TextStyle(
                                            color: Colors.limeAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        // Image.asset(
                                        //   'assets/icons/price.png',
                                        //   height: 22,
                                        //   width: 22,
                                        //   color: ConstantColors.yellow,
                                        // ),
                                        Text(
                                          Constant().amountShow(
                                              amount: data.montant.toString()),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/ic_distance.png',
                                          height: 22,
                                          width: 22,
                                          color: Colors.limeAccent,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(top: 8.0),
                                          child: TextScroll(
                                            "${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${data.distanceUnit}",
                                            mode: TextScrollMode.bouncing,
                                            pauseBetween:
                                            const Duration(seconds: 2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(

                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 100,

                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/time.png',
                                          height: 22,
                                          width: 22,
                                          color: Colors.limeAccent,

                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(top: 8.0),
                                          child: TextScroll(
                                              data.duree.toString(),
                                              mode: TextScrollMode.bouncing,
                                              pauseBetween:
                                              const Duration(seconds: 2),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: data.photoPath.toString(),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Constant.loader(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${data.prenomConducteur} ${data.nomConducteur}",
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600)),
                                  StarRating(
                                      size: 18,
                                      rating:
                                      double.parse(data.moyenne.toString()),
                                      color: ConstantColors.yellow),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      data.statut != "completed"
                                          ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10),
                                        child: InkWell(
                                            onTap: () async {
                                              ShowToastDialog.showLoader(
                                                  "Please wait");
                                              final Location
                                              currentLocation =
                                              Location();
                                              LocationData location =
                                              await currentLocation
                                                  .getLocation();
                                              ShowToastDialog
                                                  .closeLoader();

                                              await FlutterShareMe()
                                                  .shareToWhatsApp(
                                                  msg:
                                                  'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
                                            },
                                            child: Container(
                                                height: 36,
                                                width: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black,
                                                ),
                                                child: const Icon(
                                                  Icons.share_rounded,
                                                  size: 26,
                                                  color: Colors.white,
                                                ))),
                                      )
                                          : const Offstage(),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: InkWell(
                                            onTap: () {
                                              Constant.makePhoneCall(
                                                  data.driverPhone.toString());
                                            },
                                            child: Image.asset(
                                              'assets/icons/call_icon.png',
                                              height: 36,
                                              width: 36,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(data.dateRetour.toString(),
                                    style: const TextStyle(
                                        color: Colors.black26,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: data.statut == "completed",
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: ButtonThem.buildButton(context,
                                    btnHeight: 40,
                                    title: data.statutPaiement == "yes"
                                        ? "Paid".tr
                                        : "Pay Now".tr,
                                    btnColor: data.statutPaiement == "yes"
                                        ? Colors.limeAccent
                                        : ConstantColors.primary,
                                    txtColor: Colors.black, onPress: () async {
                                      if (data.statutPaiement == "yes") {
                                        controller.getNewRide();
                                      } else {
                                        var isDone = await Get.to(
                                            const TripHistoryScreen(),
                                            arguments: {
                                              "rideData": data,
                                            });
                                        if (isDone != null) {
                                          controller.getNewRide();
                                        }
                                      }
                                    })),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: ButtonThem.buildBorderButton(
                                  context,
                                  title: 'Add Review'.tr,
                                  btnWidthRatio: 0.8,
                                  btnHeight: 40,
                                  btnColor: Colors.limeAccent,
                                  txtColor: Colors.black,
                                  btnBorderColor: ConstantColors.primary,
                                  onPress: () async {
                                    Get.to(const AddReviewScreen(), arguments: {
                                      "rideData": data,
                                    })!
                                        .then((value) {
                                      controller.getNewRide();
                                    });
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: data.statut == "completed",
                      child: ButtonThem.buildBorderButton(
                        context,
                        title: 'Add Complaint'.tr,
                        btnHeight: 40,
                        btnColor: Colors.limeAccent,
                        txtColor: Colors.black,
                        btnBorderColor: ConstantColors.primary,
                        onPress: () async {
                          Get.to(AddComplaintScreen(), arguments: {
                            "rideData": data,
                          })!
                              .then((value) {
                            controller.getNewRide();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              right: 0,
              child: Image.asset(
                data.statut == "new"
                    ? 'assets/images/new.png'
                    : data.statut == "confirmed"
                    ? 'assets/images/conformed.png'
                    : data.statut == "on ride"
                    ? 'assets/images/onride.png'
                    : data.statut == "completed"
                    ? 'assets/images/completed.png'
                    : 'assets/images/rejected.png',
                height: 120,
                width: 120,
              )),
        ],
      ),
    );
  }
}
