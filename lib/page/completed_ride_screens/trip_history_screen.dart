import 'package:Urride/constant/constant.dart';
import 'package:Urride/controller/payment_controller.dart';
import 'package:Urride/model/tax_model.dart';
import 'package:Urride/page/chats_screen/conversation_screen.dart';
import 'package:Urride/page/review_screens/add_review_screen.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'payment_selection_screen.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PaymentController>(
      init: PaymentController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          appBar: AppBar(
              backgroundColor: ConstantColors.background,
              elevation: 0,
              centerTitle: true,
              title: Text("Trip Details".tr,
                  style: TextStyle(color: Colors.black)),
              leading: Padding(
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
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                      )),
                ),
              )),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12),
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
                                  controller.data.value.departName.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.data.value.stops!.length,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.data.value.stops![index]
                                                .location
                                                .toString(),
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
                                  controller.data.value.destinationName
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icons/passenger.png',
                                                height: 22,
                                                width: 22,
                                                color: ConstantColors.yellow,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                    " ${controller.data.value.numberPoeple.toString()}",
                                                    //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black54)),
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
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Column(
                                            children: [
                                              Text(
                                                Constant.currency.toString(),
                                                style: TextStyle(
                                                  color: ConstantColors.yellow,
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
                                                    amount: controller
                                                        .data.value.montant),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black54,
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
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icons/ic_distance.png',
                                                height: 22,
                                                width: 22,
                                                color: ConstantColors.yellow,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                    "${double.parse(controller.data.value.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${controller.data.value.distanceUnit}",
                                                    //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black54)),
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
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icons/time.png',
                                                height: 22,
                                                width: 22,
                                                color: ConstantColors.yellow,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                    controller.data.value.duree
                                                        .toString(),
                                                    //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black54)),
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
                                    imageUrl: controller.data.value.photoPath
                                        .toString(),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Constant.loader(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${controller.data.value.prenomConducteur.toString()} ${controller.data.value.nomConducteur.toString()}",
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600)),
                                        StarRating(
                                            size: 18,
                                            rating:
                                                controller.data.value.moyenne !=
                                                        "null"
                                                    ? double.parse(controller
                                                        .data.value.moyenne
                                                        .toString())
                                                    : 0.0,
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
                                        InkWell(
                                            onTap: () {
                                              Get.to(ConversationScreen(),
                                                  arguments: {
                                                    'receiverId': int.parse(
                                                        controller.data.value
                                                            .idConducteur
                                                            .toString()),
                                                    'orderId': int.parse(
                                                        controller.data.value.id
                                                            .toString()),
                                                    'receiverName':
                                                        "${controller.data.value.prenomConducteur} ${controller.data.value.nomConducteur}",
                                                    'receiverPhoto': controller
                                                        .data.value.photoPath
                                                  });
                                            },
                                            child: Image.asset(
                                              'assets/icons/chat_icon.png',
                                              height: 36,
                                              width: 36,
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: InkWell(
                                              onTap: () {
                                                Constant.makePhoneCall(
                                                    controller
                                                        .data.value.driverPhone
                                                        .toString());
                                              },
                                              child: Image.asset(
                                                'assets/icons/call_icon.png',
                                                height: 36,
                                                width: 36,
                                              )),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                          controller.data.value.dateRetour
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.black26,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(2, 2),
                          ),
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  "Sub Total".tr,
                                  style: TextStyle(
                                      letterSpacing: 1.0,
                                      color: ConstantColors.subTitleTextColor,
                                      fontWeight: FontWeight.w600),
                                )),
                                Text(
                                    Constant().amountShow(
                                        amount: controller.data.value.montant),
                                    style: TextStyle(
                                        letterSpacing: 1.0,
                                        color: ConstantColors.titleTextColor,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black.withOpacity(0.40),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  "Discount".tr,
                                  style: TextStyle(
                                      letterSpacing: 1.0,
                                      color: ConstantColors.subTitleTextColor,
                                      fontWeight: FontWeight.w600),
                                )),
                                Text(
                                    "(-${Constant().amountShow(amount: controller.discountAmount.value.toString())})",
                                    style: const TextStyle(
                                        letterSpacing: 1.0,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black.withOpacity(0.40),
                              ),
                            ),
                            ListView.builder(
                              itemCount:
                                  controller.data.value.statutPaiement == "yes"
                                      ? controller.data.value.taxModel!.length
                                      : Constant.taxList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                TaxModel taxModel =
                                    controller.data.value.statutPaiement ==
                                            "yes"
                                        ? controller.data.value.taxModel![index]
                                        : Constant.taxList[index];
                                return ListTile(
                                  horizontalTitleGap: 0,
                                  minVerticalPadding: 0,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${taxModel.libelle.toString()} (${taxModel.type == "Fixed" ? Constant().amountShow(amount: taxModel.value) : "${taxModel.value}%"})',
                                    style: TextStyle(
                                        fontSize: 12,
                                        letterSpacing: 1.0,
                                        color: ConstantColors.subTitleTextColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Text(
                                      Constant().amountShow(
                                          amount: controller
                                              .calculateTax(taxModel: taxModel)
                                              .toString()),
                                      style: TextStyle(
                                          letterSpacing: 1.0,
                                          color:
                                              ConstantColors.subTitleTextColor,
                                          fontWeight: FontWeight.w800)),
                                );
                              },
                            ),

                            // Row(
                            //   children: [
                            //     Expanded(
                            //         child: Text(
                            //       "${Constant.taxName} ${Constant.taxType == "Percentage" ? "(${Constant.taxValue}%)" : "(${Constant.taxValue})"}",
                            //       style: TextStyle(
                            //           letterSpacing: 1.0,
                            //           color: ConstantColors.subTitleTextColor,
                            //           fontWeight: FontWeight.w600),
                            //     )),
                            //     Text(
                            //         Constant().amountShow(
                            //             amount: controller.taxAmount.value
                            //                 .toString()),
                            //         style: TextStyle(
                            //             letterSpacing: 1.0,
                            //             color: ConstantColors.titleTextColor,
                            //             fontWeight: FontWeight.w800)),
                            //   ],
                            // ),

                            Visibility(
                              visible: controller.tipAmount.value == 0
                                  ? false
                                  : true,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: Divider(
                                      color: Colors.black.withOpacity(0.40),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Driver Tip".tr,
                                        style: TextStyle(
                                            letterSpacing: 1.0,
                                            color: ConstantColors
                                                .subTitleTextColor,
                                            fontWeight: FontWeight.w600),
                                      )),
                                      Text(
                                          Constant().amountShow(
                                              amount: controller.tipAmount.value
                                                  .toString()),
                                          style: TextStyle(
                                              letterSpacing: 1.0,
                                              color:
                                                  ConstantColors.titleTextColor,
                                              fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black.withOpacity(0.40),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  "Total".tr,
                                  style: TextStyle(
                                      letterSpacing: 1.0,
                                      color: ConstantColors.titleTextColor,
                                      fontWeight: FontWeight.w600),
                                )),
                                Text(
                                    Constant().amountShow(
                                        amount: controller
                                            .getTotalAmount()
                                            .toString()),
                                    style: TextStyle(
                                        letterSpacing: 1.0,
                                        color: ConstantColors.primary,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                    child: ButtonThem.buildButton(context,
                        btnHeight: 40,
                        title: controller.data.value.statutPaiement == "yes"
                            ? "paid".tr
                            : "Pay Now".tr,
                        btnColor: controller.data.value.statutPaiement == "yes"
                            ? Colors.green
                            : ConstantColors.primary,
                        txtColor: Colors.white, onPress: () {
                  if (controller.data.value.statutPaiement == "yes") {
                    // controller.feelAsSafe(data.id.toString()).then((value) {
                    //   if (value != null) {
                    // controller.getCompletedRide();
                    //   }
                    // });
                  } else {
                    // Get.to(PaymentSelectionScreen(), arguments: {
                    //   "rideData": controller.data.value,
                    // });
                  }
                })),
                Visibility(
                  visible: controller.data.value.statutPaiement == "yes",
                  child: Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ButtonThem.buildBorderButton(
                          context,
                          title: 'Add Review'.tr,
                          btnWidthRatio: 0.8,
                          btnHeight: 40,
                          btnColor: Colors.white,
                          txtColor: ConstantColors.primary,
                          btnBorderColor: ConstantColors.primary,
                          onPress: () async {
                            Get.to(const AddReviewScreen(), arguments: {
                              "rideData": controller.data.value,
                            });
                          },
                        )),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
