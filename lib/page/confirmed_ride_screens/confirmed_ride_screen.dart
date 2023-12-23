import 'package:Urride/constant/constant.dart';
import 'package:Urride/controller/confirmed_ride_controller.dart';
import 'package:Urride/model/ride_model.dart';
import 'package:Urride/page/chats_screen/conversation_screen.dart';
import 'package:Urride/page/route_view_screen/route_view_screen.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmedRideScreen extends StatelessWidget {
  const ConfirmedRideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ConfirmedRideController>(
      init: ConfirmedRideController(),
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
                        ? Constant.emptyView(context, "You have not booked any trip.\n Please book a cab now", true)
                        : ListView.builder(
                            itemCount: controller.rideList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return confirmedRideWidgets(context, controller.rideList[index], controller);
                            }),
              ),
            ));
      },
    );
  }

  Widget confirmedRideWidgets(BuildContext context, RideData data, ConfirmedRideController controller) {
    return InkWell(
      onTap: () async {
        var argumentData = {'type': 'confirmed'.tr, 'data': data};
        final backData = await Get.to(const RouteViewScreen(), arguments: argumentData);

        if (backData != null) {
          if (backData == true) {
            controller.getNewRide();
          }
        }
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
                            Text(data.departName.toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Divider(),
                            Text(data.destinationName.toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'confirmed'.tr,
                      style: TextStyle(color: ConstantColors.primary),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: Constant.rideOtp.toString() == 'yes' ? true : false,
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
                                      Constant().amountShow(amount: data.montant!.toString()),
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
                          height: 80,
                          width: 80,
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
                              Text("${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
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
                              InkWell(
                                  onTap: () {
                                    Get.to(ConversationScreen(), arguments: {
                                      'receiverId': int.parse(data.idConducteur.toString()),
                                      'orderId': int.parse(data.id.toString()),
                                      'receiverName': "${data.prenom} ${data.nom}",
                                      'receiverPhoto': data.photoPath
                                    });
                                  },
                                  child: Image.asset(
                                    'assets/icons/chat_icon.png',
                                    height: 36,
                                    width: 36,
                                  )),
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
