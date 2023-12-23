import 'package:Urride/constant/constant.dart';
import 'package:Urride/controller/rented_vehicle_controller.dart';
import 'package:Urride/model/rented_vehicle_model.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/themes/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RentedVehicleScreen extends StatelessWidget {
  const RentedVehicleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<RentedVehicleController>(
      init: RentedVehicleController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: ConstantColors.background,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.rentedVehicleData.isEmpty
                      ? Constant.emptyView(context, "You don't have any rented vehicle. please book ride.", false)
                      : ListView.builder(
                          itemCount: controller.rentedVehicleData.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return buildVehicleCard(context, controller.rentedVehicleData[index], controller);
                          }),
            ));
      },
    );
  }

  Widget buildVehicleCard(BuildContext context, RentedVehicleData data, RentedVehicleController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: data.image.toString(),
                      width: Responsive.width(20, context),
                      height: Responsive.width(20, context),
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Constant.loader(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.libTypeVehicule.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Constant().amountShow(amount: data.prix.toString()),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Container(
                            decoration: BoxDecoration(color: ConstantColors.yellow, borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6),
                              child: Text(data.statut.toString(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          " ${data.dateDebut.toString()} to ${data.dateFin.toString()}",
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),
            ButtonThem.buildButton(context, txtSize: 12, btnHeight: 30, btnWidthRatio: 0.3, title: "Cancel", btnColor: ConstantColors.yellow, txtColor: Colors.black, onPress: () {
              Map<String, dynamic> bodyParams = {
                'id': data.id.toString(),
              };
              controller.cancelBooking(bodyParams).then((value) {
                if (value != null) {
                  Get.back();
                  controller.getRentedData();
                }
              });
            }),
          ],
        ),
      ),
    );
  }
}
