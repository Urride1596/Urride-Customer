import 'dart:developer';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/controller/rent_vehicle_controller.dart';
import 'package:Urride/model/rent_vehicle_model.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/themes/responsive.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RentVehicleScreen extends StatelessWidget {
  RentVehicleScreen({Key? key}) : super(key: key);

  static final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetX<RentVehicleController>(
      init: RentVehicleController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: controller.isLoading.value
                ? Constant.loader()
                : controller.rentVehicleList.isEmpty
                    ? Constant.emptyView(context, "Vehicle not found".tr, false)
                    : ListView.builder(
                        itemCount: controller.rentVehicleList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return buildVehicleCard(context,
                              controller.rentVehicleList[index], controller);
                        }),
          ),
        );
      },
    );
  }

  Widget buildVehicleCard(BuildContext context, RentVehicleData data,
      RentVehicleController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    width: Responsive.width(24, context),
                    height: Responsive.width(22, context),
                    imageUrl: data.image.toString(),
                    fit: BoxFit.fill,
                    placeholder: (context, url) => Constant.loader(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.libelle.toString(),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Constant().amountShow(amount: data.prix.toString()),
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_seat,
                                  color: ConstantColors.yellow,
                                  size: 18,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                      " ${data.noOfPassenger.toString()}",
                                      //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Divider(color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ButtonThem.buildButton(context,
                txtSize: 12,
                btnHeight: 40,
                btnWidthRatio: 0.4,
                title: 'book_now'.tr,
                btnColor: Colors.limeAccent,
                txtColor: Colors.black, onPress: () {
              buildShowBottomSheet(context, data, controller);
            }),
          )
        ],
      ),
    );
  }

  final GlobalKey<FormState> _contactKey = GlobalKey();

  buildShowBottomSheet(BuildContext context, RentVehicleData data,
      RentVehicleController controller) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Obx(
                () => Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Reservation Information".tr,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Total to Pay".tr,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Text(
                            Constant().amountShow(amount: data.prix.toString()),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Number of days".tr,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Text(
                            "${daysBetween(controller.startDate.value, controller.endDate.value)}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Start date".tr,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2040))
                                  .then((value) {
                                controller.startDate.value = DateTime.parse(
                                    DateFormat('yyyy-MM-dd 00:00:00')
                                        .format(value!));
                              });
                            },
                            child: Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(controller.startDate.value),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "End date".tr,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              showDatePicker(
                                      context: context,
                                      initialDate: controller.startDate.value,
                                      firstDate: controller.startDate.value,
                                      lastDate: DateTime(2040))
                                  .then((value) {
                                controller.endDate.value = DateTime.parse(
                                    DateFormat('yyyy-MM-dd 00:00:00')
                                        .format(value!));
                              });
                            },
                            child: Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(controller.endDate.value),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Form(
                        key: _contactKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Contact number'.tr,
                              labelText: 'Contact number'.tr,
                              contentPadding: EdgeInsets.zero,
                              suffixIcon: Icon(
                                Icons.phone,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "send".tr,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black, onPress: () {
                              if (_contactKey.currentState!.validate()) {
                                Map<String, dynamic> bodyParams = {
                                  'nb_jour': daysBetween(
                                          controller.startDate.value,
                                          controller.endDate.value)
                                      .toString(),
                                  'date_debut': DateFormat('yyyy-MM-dd')
                                      .format(controller.startDate.value),
                                  'date_fin': DateFormat('yyyy-MM-dd')
                                      .format(controller.endDate.value),
                                  'contact': _phoneController.text,
                                  'id_user_app':
                                      Preferences.getInt(Preferences.userId)
                                          .toString(),
                                  'id_vehicule': data.id.toString(),
                                };
                                controller
                                    .setLocation(bodyParams)
                                    .then((value) {
                                  if (value != null) {
                                    Get.back();
                                  }
                                });
                              }
                            }),
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "cancel".tr,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black, onPress: () {
                              Navigator.pop(context);
                            }),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  int daysBetween(DateTime from, DateTime to) {
    log(from.toString());
    log(to.toString());
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays + 1;
  }
}
