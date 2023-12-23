import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/on_ride_controller.dart';
import 'package:Urride/controller/ride_details_controller.dart';
import 'package:Urride/model/ride_model.dart';
import 'package:Urride/page/route_view_screen/route_view_screen.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class OnRideScreens extends StatelessWidget {
  OnRideScreens({Key? key}) : super(key: key);
  final controllerRideDetails = Get.put(RideDetailsController());

  @override
  Widget build(BuildContext context) {
    return GetX<OnRideController>(
      init: OnRideController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: ConstantColors.background,
            body: RefreshIndicator(
              onRefresh: () => controller.getOnRide(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : controller.rideList.isEmpty
                        ? Constant.emptyView(context, "You have not booked any trip.\n Please book a cab now", true)
                        : ListView.builder(
                            itemCount: controller.rideList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return onRideWidgets(context, controller.rideList[index]);
                            }),
              ),
            ));
      },
    );
  }

  Widget onRideWidgets(BuildContext context, RideData data) {
    return InkWell(
      onTap: () {
        var argumentData = {'type': 'on_ride'.tr, 'data': data};
        Get.to(const RouteViewScreen(), arguments: argumentData);
      },
      child: Padding(
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
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/icons/ic_pic_drop_location.png",
                      height: 70,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.departName.toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(),
                            Text(
                              data.destinationName.toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'on_ride'.tr,
                      style: TextStyle(color: ConstantColors.primary),
                    )
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/icons/passenger.png',
                                      height: 22,
                                      width: 22,
                                      color: ConstantColors.yellow,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(" ${data.numberPoeple.toString()}",
                                          //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
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
                                      Constant().amountShow(amount: data.montant.toString()),
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/icons/ic_distance.png',
                                      height: 22,
                                      width: 22,
                                      color: ConstantColors.yellow,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("${data.distance.toString()} ${data.distanceUnit}",
                                          //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/icons/time.png',
                                      height: 22,
                                      width: 22,
                                      color: ConstantColors.yellow,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(data.duree.toString(),
                                          //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
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
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Constant.loader(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${data.prenomConducteur} ${data.nomConducteur}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                              StarRating(size: 18, rating: double.parse(data.moyenne.toString()), color: ConstantColors.yellow),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: InkWell(
                                    onTap: () {
                                      Constant.makePhoneCall(data.driverPhone.toString());
                                    },
                                    child: Image.asset(
                                      'assets/icons/call_icon.png',
                                      height: 36,
                                      width: 36,
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: ButtonThem.buildButton(
                                  context,
                                  title: 'sos'.tr,
                                  btnHeight: 35,
                                  btnWidthRatio: 0.2,
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white,
                                  onPress: () async {
                                    LocationData location = await Location().getLocation();
                                    Map<String, dynamic> bodyParams = {
                                      'lat': location.latitude,
                                      'lng': location.longitude,
                                      'ride_id': data.id,
                                    };
                                    controllerRideDetails.sos(bodyParams).then((value) {
                                      if (value != null) {
                                        if (value['success'] == "success") {
                                          ShowToastDialog.showToast(value['message'].toString());
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(data.dateRetour.toString(), style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w600)),
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
      ),
    );
  }
}
