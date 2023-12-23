import 'package:Urride/controller/payment_controller.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/widget/my_separator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';

class AddTripScreen extends StatelessWidget {
  AddTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PaymentController>(
      init: PaymentController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.primary,
          appBar: AppBar(
              backgroundColor: ConstantColors.primary,
              elevation: 0,
              centerTitle: true,
              title:
                  const Text("Add Trip", style: TextStyle(color: Colors.white)),
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
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 42, bottom: 20),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 65),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                    "${controller.data.value.prenomConducteur} ${controller.data.value.nomConducteur}",
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: RatingBar.builder(
                                  initialRating: double.parse(
                                      controller.data.value.moyenne.toString()),
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20,
                                  tapOnlyMode: false,
                                  updateOnDrag: false,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (double value) {},
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      controller.data.value.numberplate!
                                          .toUpperCase()
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600)),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                        "${controller.data.value.brand!} ${controller.data.value.model!}",
                                        style: const TextStyle(
                                            color: Colors.black38,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: MySeparator(color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 40, right: 40),
                            child: Text(
                              'Want to add trip for ${controller.data.value.prenomConducteur.toString()} ${controller.data.value.nomConducteur.toString()}?',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "It's appreciated but optional",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ConstantColors.subTitleTextColor,
                                  letterSpacing: 0.8),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller.tipAmount.value == 5) {
                                        controller.tipAmount.value = 0;
                                      } else {
                                        controller.tipAmount.value = 5;
                                      }
                                    },
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: controller.tipAmount.value == 5
                                            ? ConstantColors.primary
                                            : Colors.white,
                                        border: Border.all(
                                          color: controller.tipAmount.value == 5
                                              ? Colors.transparent
                                              : Colors.black.withOpacity(0.20),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 2,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                      child: Center(
                                          child: Text(
                                        Constant().amountShow(amount: '5'),
                                        style: TextStyle(
                                            color:
                                                controller.tipAmount.value == 5
                                                    ? Colors.white
                                                    : Colors.black),
                                      )),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller.tipAmount.value == 10) {
                                        controller.tipAmount.value = 0;
                                      } else {
                                        controller.tipAmount.value = 10;
                                      }
                                    },
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: controller.tipAmount.value == 10
                                            ? ConstantColors.primary
                                            : Colors.white,
                                        border: Border.all(
                                          color: controller.tipAmount.value ==
                                                  10
                                              ? Colors.transparent
                                              : Colors.black.withOpacity(0.20),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 2,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                      child: Center(
                                          child: Text(
                                        Constant().amountShow(amount: '10'),
                                        style: TextStyle(
                                            color:
                                                controller.tipAmount.value == 10
                                                    ? Colors.white
                                                    : Colors.black),
                                      )),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller.tipAmount.value == 15) {
                                        controller.tipAmount.value = 0;
                                      } else {
                                        controller.tipAmount.value = 15;
                                      }
                                    },
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: controller.tipAmount.value == 15
                                            ? ConstantColors.primary
                                            : Colors.white,
                                        border: Border.all(
                                          color: controller.tipAmount.value ==
                                                  15
                                              ? Colors.transparent
                                              : Colors.black.withOpacity(0.20),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 2,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                      child: Center(
                                          child: Text(
                                        Constant().amountShow(amount: '15'),
                                        style: TextStyle(
                                            color:
                                                controller.tipAmount.value == 15
                                                    ? Colors.white
                                                    : Colors.black),
                                      )),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller.tipAmount.value == 20) {
                                        controller.tipAmount.value = 0;
                                      } else {
                                        controller.tipAmount.value = 20;
                                      }
                                    },
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: controller.tipAmount.value == 20
                                            ? ConstantColors.primary
                                            : Colors.white,
                                        border: Border.all(
                                          color: controller.tipAmount.value ==
                                                  20
                                              ? Colors.transparent
                                              : Colors.black.withOpacity(0.20),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 2,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                      child: Center(
                                          child: Text(
                                        Constant().amountShow(amount: '20'),
                                        style: TextStyle(
                                            color:
                                                controller.tipAmount.value == 20
                                                    ? Colors.white
                                                    : Colors.black),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              tripAmountBottomSheet(context, controller);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                "Add other amount",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ConstantColors.yellow,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 20),
                            child: ButtonThem.buildButton(context,
                                btnHeight: 45,
                                title: "Done",
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white, onPress: () async {
                              Get.back();
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 6,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      imageUrl: controller.data.value.photoPath.toString(),
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Constant.loader(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final tripAmountTextFieldController = TextEditingController();

  tripAmountBottomSheet(BuildContext context, PaymentController controller) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Enter Tip option",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: tripAmountTextFieldController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            hintText: 'How many passenger',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ButtonThem.buildIconButton(context,
                                  iconSize: 16.0,
                                  icon: Icons.arrow_back_ios,
                                  iconColor: Colors.black,
                                  btnHeight: 40,
                                  btnWidthRatio: 0.25,
                                  title: "Cancel",
                                  btnColor: ConstantColors.yellow,
                                  txtColor: Colors.black, onPress: () {
                                Get.back();
                              }),
                            ),
                            Expanded(
                              child: ButtonThem.buildButton(context,
                                  btnHeight: 40,
                                  title: "Add".tr,
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white, onPress: () async {
                                controller.tipAmount.value = double.parse(
                                    tripAmountTextFieldController.text);
                                Get.back();
                              }),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}
