import 'dart:convert';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/dash_board_controller.dart';
import 'package:Urride/controller/ride_details_controller.dart';
import 'package:Urride/model/ride_model.dart';
import 'package:Urride/page/chats_screen/conversation_screen.dart';
import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/themes/custom_alert_dialog.dart';
import 'package:Urride/themes/custom_dialog_box.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:Urride/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../model/driver_location_update.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({Key? key}) : super(key: key);

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  dynamic argumentData = Get.arguments;

  GoogleMapController? _controller;

  Map<PolylineId, Polyline> polyLines = {};

  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;

  late LatLng departureLatLong;
  late LatLng destinationLatLong;

  final Map<String, Marker> _markers = {};

  String? type;
  RideData? rideData;
  String driverEstimateArrivalTime = '';

  @override
  void initState() {
    getArgumentData();
    setIcons();

    super.initState();
  }

  final controllerRideDetails = Get.put(RideDetailsController());
  final controllerDashBoard = Get.put(DashBoardController());

  getArgumentData() {
    if (argumentData != null) {
      type = argumentData['type'];
      rideData = argumentData['data'];

      departureLatLong = LatLng(double.parse(rideData!.latitudeDepart.toString()), double.parse(rideData!.longitudeDepart.toString()));
      destinationLatLong = LatLng(double.parse(rideData!.latitudeArrivee.toString()), double.parse(rideData!.longitudeArrivee.toString()));

      if (rideData!.statut == "on ride" || rideData!.statut == 'confirmed') {
        Constant.driverLocationUpdateCollection.doc(rideData!.idConducteur).snapshots().listen((event) async {
          DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate.fromJson(event.data() as Map<String, dynamic>);

          Dio dio = Dio();
          dynamic response = await dio.get(
              "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${rideData!.latitudeDepart},${rideData!.longitudeDepart}&destinations=${double.parse(driverLocationUpdate.driverLatitude.toString())},${double.parse(driverLocationUpdate.driverLongitude.toString())}&key=${Constant.kGoogleApiKey}");

          driverEstimateArrivalTime = response.data['rows'][0]['elements'][0]['duration']['text'].toString();

          setState(() {
            departureLatLong = LatLng(double.parse(driverLocationUpdate.driverLatitude.toString()), double.parse(driverLocationUpdate.driverLongitude.toString()));
            _markers[rideData!.id.toString()] = Marker(
                markerId: MarkerId(rideData!.id.toString()), infoWindow: InfoWindow(title: rideData!.prenomConducteur.toString()), position: departureLatLong, icon: taxiIcon!, rotation: double.parse(driverLocationUpdate.rotation.toString()));
            getDirections(dLat: double.parse(driverLocationUpdate.driverLatitude.toString()), dLng: double.parse(driverLocationUpdate.driverLongitude.toString()));
          });
        });
      } else {
        getDirections(dLat: 0.0, dLng: 0.0);
      }
    }
  }

  setIcons() async {
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/pickup.png").then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/dropoff.png").then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/ic_taxi.png").then((value) {
      taxiIcon = value;
    });

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/location.png").then((value) {
      stopIcon = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              initialCameraPosition: const CameraPosition(
                target: LatLng(48.8561, 2.2930),
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _controller!.moveCamera(CameraUpdate.newLatLngZoom(departureLatLong, 12));
              },
              polylines: Set<Polyline>.of(polyLines.values),
              markers: _markers.values.toSet(),
            ),
            Positioned(
              top: 10,
              left: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(4),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          if (rideData!.statut == 'confirmed')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Driver Estimate Arrival Time : '.tr,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    driverEstimateArrivalTime,
                                    style: TextStyle(color: ConstantColors.yellow, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          Visibility(
                            visible: Constant.rideOtp.toString().toLowerCase() == 'yes'.toLowerCase() && rideData!.statut == 'confirmed' && rideData!.rideType != 'driver' ? true : false,
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
                                      rideData!.otp.toString(),
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
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Row(
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     children: [
                          //       Expanded(
                          //         child: Padding(
                          //           padding: const EdgeInsets.only(left: 5.0),
                          //           child: Container(
                          //             height: 100,
                          //             decoration: BoxDecoration(
                          //                 border: Border.all(
                          //                   color: Colors.black12,
                          //                 ),
                          //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(vertical: 20),
                          //               child: Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   Image.asset(
                          //                     'assets/icons/passenger.png',
                          //                     height: 22,
                          //                     width: 22,
                          //                     color: ConstantColors.yellow,
                          //                   ),
                          //                   Padding(
                          //                     padding: const EdgeInsets.only(top: 8.0),
                          //                     child: Text(" ${rideData!.numberPoeple.toString()}",
                          //                         //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                          //                         style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: Padding(
                          //           padding: const EdgeInsets.only(left: 5.0),
                          //           child: Container(
                          //             height: 100,
                          //             decoration: BoxDecoration(
                          //                 border: Border.all(
                          //                   color: Colors.black12,
                          //                 ),
                          //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(vertical: 20),
                          //               child: Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   Text(
                          //                     Constant.currency.toString(),
                          //                     style: TextStyle(
                          //                       color: ConstantColors.yellow,
                          //                       fontWeight: FontWeight.bold,
                          //                       fontSize: 20,
                          //                     ),
                          //                   ),
                          //                   Text(
                          //                     Constant().amountShow(amount: rideData!.montant!.toString()),
                          //                     style: const TextStyle(
                          //                       fontWeight: FontWeight.w800,
                          //                       color: Colors.black54,
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: Padding(
                          //           padding: const EdgeInsets.only(left: 5.0),
                          //           child: Container(
                          //             height: 100,
                          //             decoration: BoxDecoration(
                          //                 border: Border.all(
                          //                   color: Colors.black12,
                          //                 ),
                          //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(vertical: 20),
                          //               child: Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   Image.asset(
                          //                     'assets/icons/ic_distance.png',
                          //                     height: 22,
                          //                     width: 22,
                          //                     color: ConstantColors.yellow,
                          //                   ),
                          //                   Padding(
                          //                     padding: const EdgeInsets.only(top: 8.0),
                          //                     child: Text(
                          //                       "${rideData!.distance.toString()} ${rideData!.distanceUnit}",
                          //                       overflow: TextOverflow.ellipsis,
                          //                       style: const TextStyle(
                          //                         fontWeight: FontWeight.w800,
                          //                         color: Colors.black54,
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: Padding(
                          //           padding: const EdgeInsets.only(left: 5.0),
                          //           child: Container(
                          //             height: 100,
                          //             decoration: BoxDecoration(
                          //                 border: Border.all(
                          //                   color: Colors.black12,
                          //                 ),
                          //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(vertical: 20),
                          //               child: Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   Image.asset(
                          //                     'assets/icons/time.png',
                          //                     height: 22,
                          //                     width: 22,
                          //                     color: ConstantColors.yellow,
                          //                   ),
                          //                   Padding(
                          //                     padding: const EdgeInsets.only(top: 8.0),
                          //                     child: Text(
                          //                       rideData!.duree.toString(),
                          //                       overflow: TextOverflow.ellipsis,
                          //                       style: const TextStyle(
                          //                         fontWeight: FontWeight.w800,
                          //                         color: Colors.black54,
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: rideData!.photoPath.toString(),
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
                                        Text("${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}",
                                            overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                        StarRating(size: 18, rating: rideData!.moyenne != "null" ? double.parse(rideData!.moyenne.toString()) : 0.0, color: ConstantColors.yellow),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Visibility(
                                          visible: rideData!.statut == "confirmed" ? true : false,
                                          child: InkWell(
                                              onTap: () {
                                                Get.to(ConversationScreen(), arguments: {
                                                  'receiverId': int.parse(rideData!.idConducteur.toString()),
                                                  'orderId': int.parse(rideData!.id.toString()),
                                                  'receiverName': "${rideData!.prenomConducteur} ${rideData!.nomConducteur}",
                                                  'receiverPhoto': rideData!.photoPath
                                                });
                                              },
                                              child: Image.asset(
                                                'assets/icons/chat_icon.png',
                                                height: 36,
                                                width: 36,
                                              )),
                                        ),
                                        rideData!.statut != "completed"
                                            ? Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: InkWell(
                                              onTap: () async {
                                                ShowToastDialog.showLoader("Please wait".tr);
                                                final Location currentLocation = Location();
                                                LocationData location = await currentLocation.getLocation();

                                                await FlutterShareMe().shareToWhatsApp(msg: 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
                                              },
                                              child: Container(
                                                  height: 36,
                                                  width: 36,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: ConstantColors.blueColor,
                                                  ),
                                                  child: const Icon(
                                                    Icons.share_rounded,
                                                    size: 26,
                                                    color: Colors.white,
                                                  ))),
                                        )
                                            : const Offstage(),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: InkWell(
                                              onTap: () {
                                                Constant.makePhoneCall(rideData!.driverPhone.toString());
                                              },
                                              child: Image.asset(
                                                'assets/icons/call_icon.png',
                                                height: 36,
                                                width: 36,
                                              )),
                                        ),
                                        Visibility(
                                          visible: rideData!.statut == "on ride" ? true : false,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: ButtonThem.buildButton(
                                              context,
                                              title: 'sos'.tr,
                                              btnHeight: 35,
                                              btnWidthRatio: 0.16,
                                              btnColor: ConstantColors.primary,
                                              txtColor: Colors.white,
                                              onPress: () async {
                                                LocationData location = await Location().getLocation();
                                                Map<String, dynamic> bodyParams = {
                                                  'lat': location.latitude,
                                                  'lng': location.longitude,
                                                  'ride_id': rideData!.id,
                                                };
                                                controllerRideDetails.sos(bodyParams).then((value) {
                                                  if (value != null) {
                                                    if (value['success'] == "success") {
                                                      ShowToastDialog.showToast(value['message']);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(rideData!.dateRetour.toString(), style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w600)),
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
                Divider(
                  color: Colors.grey.withOpacity(0.20),
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Visibility(
                        visible: rideData!.statut == "on ride" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'safe_message'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: ConstantColors.primary,
                              txtColor: Colors.white,
                              onPress: () async {
                                LocationData location = await Location().getLocation();
                                Map<String, dynamic> bodyParams = {
                                  'lat': location.latitude,
                                  'lng': location.longitude,
                                  'user_id': Preferences.getInt(Preferences.userId).toString(),
                                  'user_name': "${controllerRideDetails.userModel!.data!.prenom} ${controllerRideDetails.userModel!.data!.nom}",
                                  'user_cat': controllerRideDetails.userModel!.data!.userCat,
                                  'id_driver': rideData!.idConducteur,
                                  'feel_safe': 0,
                                  'trip_id': rideData!.id,
                                };
                                controllerRideDetails.feelNotSafe(bodyParams).then((value) {
                                  if (value != null) {
                                    if (value['success'] == "success") {
                                      ShowToastDialog.showToast("Report submitted".tr);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      // Visibility(
                      //   visible: rideData!.statut == "confirmed" ? true : false,
                      //   child: Expanded(
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(bottom: 5),
                      //       child: ButtonThem.buildButton(
                      //         context,
                      //         title: 'Conform Ride'.tr,
                      //         btnHeight: 45,
                      //         btnWidthRatio: 0.8,
                      //         btnColor: ConstantColors.primary,
                      //         txtColor: Colors.white,
                      //         onPress: () async {
                      //           showDialog(
                      //             barrierColor: Colors.black26,
                      //             context: context,
                      //             builder: (context) {
                      //               return CustomAlertDialog(
                      //                 title: "Do you want to confirm this ride?",
                      //                 onPressNegative: () {
                      //                   Get.back();
                      //                 },
                      //                 onPressPositive: () {
                      //                   Map<String, dynamic> bodyParams = {
                      //                     'id_ride': rideData!.id.toString(),
                      //                     'id_user': rideData!.idConducteur.toString(),
                      //                     'use_name': rideData!.prenomConducteur.toString(),
                      //                     'car_driver_confirmed': 1,
                      //                     'from_id': Preferences.getInt(Preferences.userId).toString(),
                      //                   };
                      //                   controllerRideDetails.setConformRequest(bodyParams).then((value) {
                      //                     if (value != null) {
                      //                       Get.back();
                      //                       showDialog(
                      //                           context: context,
                      //                           builder: (BuildContext context) {
                      //                             return CustomDialogBox(
                      //                               title: "On ride Successfully",
                      //                               descriptions: "Ride Successfully On ride .",
                      //                               onPress: () {
                      //                                 Get.back();
                      //                                 controllerDashBoard.onSelectItem(4);
                      //                               },
                      //                               img: Image.asset('assets/images/green_checked.png'),
                      //                             );
                      //                           });
                      //                     }
                      //                   });
                      //                 },
                      //               );
                      //             },
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Visibility(
                        visible: rideData!.statut == "rejected" ? false : true,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: ButtonThem.buildBorderButton(
                              context,
                              title: 'Cancel Ride'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: Colors.white,
                              txtColor: ConstantColors.primary,
                              btnBorderColor: ConstantColors.primary,
                              onPress: () async {
                                buildShowBottomSheet(context);
                                // showDialog(
                                //   barrierColor: Colors.black26,
                                //   context: context,
                                //   builder: (context) {
                                //     return CustomAlertDialog(
                                //       title: "Do you want to cancel this booking?",
                                //       onPressNegative: () {
                                //         Get.back();
                                //       },
                                //       onPressPositive: () {
                                //         Map<String, String> bodyParams = {
                                //           'id_ride': rideData!.id.toString(),
                                //           'id_user': rideData!.idConducteur.toString(),
                                //           'name': rideData!.prenom.toString(),
                                //           'from_id': Preferences.getInt(Preferences.userId).toString(),
                                //           'user_cat': controllerRideDetails.userModel!.data!.userCat.toString(),
                                //         };
                                //         controllerRideDetails.canceledRide(bodyParams).then((value) {
                                //           Get.back();
                                //           if (value != null) {
                                //             showDialog(
                                //                 context: context,
                                //                 builder: (BuildContext context) {
                                //                   return CustomDialogBox(
                                //                     title: "Cancel Successfully",
                                //                     descriptions: "Ride Successfully cancel.",
                                //                     onPress: () {
                                //                       Get.back();
                                //                       controllerDashBoard.onSelectItem(4);
                                //                     },
                                //                     img: Image.asset('assets/images/green_checked.png'),
                                //                   );
                                //                 });
                                //           }
                                //         });
                                //       },
                                //     );
                                //   },
                                // );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  final resonController = TextEditingController();

  buildShowBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Cancel Trip".tr,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Write a reason for trip cancellation".tr,
                        style: TextStyle(color: Colors.black.withOpacity(0.50)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: resonController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Cancel Trip'.tr,
                                btnHeight: 45,
                                btnWidthRatio: 0.8,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white,
                                onPress: () async {
                                  if (resonController.text.isNotEmpty) {
                                    Get.back();
                                    showDialog(
                                      barrierColor: Colors.black26,
                                      context: context,
                                      builder: (context) {
                                        return CustomAlertDialog(
                                          title: "Do you want to cancel this booking?".tr,
                                          onPressNegative: () {
                                            Get.back();
                                          },
                                          onPressPositive: () {
                                            Map<String, String> bodyParams = {
                                              'id_ride': rideData!.id.toString(),
                                              'id_user': rideData!.idConducteur.toString(),
                                              'name': "${rideData!.prenom} ${rideData!.nom}",
                                              'from_id': Preferences.getInt(Preferences.userId).toString(),
                                              'user_cat': controllerRideDetails.userModel!.data!.userCat.toString(),
                                              'reason': resonController.text.toString(),
                                            };
                                            controllerRideDetails.canceledRide(bodyParams).then((value) {
                                              Get.back();
                                              if (value != null) {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CustomDialogBox(
                                                        title: "Cancel Successfully",
                                                        descriptions: "Ride Successfully cancel.",
                                                        onPress: () {
                                                          Get.back();
                                                          controllerDashBoard.onSelectItem(1);
                                                        },
                                                        img: Image.asset('assets/images/green_checked.png'),
                                                      );
                                                    });
                                              }
                                            });
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    ShowToastDialog.showToast("Please enter a reason".tr);
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5, left: 10),
                              child: ButtonThem.buildBorderButton(
                                context,
                                title: 'Close'.tr,
                                btnHeight: 45,
                                btnWidthRatio: 0.8,
                                btnColor: Colors.white,
                                txtColor: ConstantColors.primary,
                                btnBorderColor: ConstantColors.primary,
                                onPress: () async {
                                  Get.back();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  getDirections({required double dLat, required double dLng}) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result;
    List<PolylineWayPoint> wayPointList = [];
    for (var i = 0; i < rideData!.stops!.length; i++) {
      wayPointList.add(PolylineWayPoint(location: rideData!.stops![i].location!));
    }

    if (rideData!.statut == "confirmed") {
      result = await polylinePoints.getRouteBetweenCoordinates(
        Constant.kGoogleApiKey.toString(),
        PointLatLng(double.parse(rideData!.latitudeDepart.toString()), double.parse(rideData!.longitudeDepart.toString())),
        PointLatLng(dLat, dLng),
        wayPoints: wayPointList,
        optimizeWaypoints: true,
        travelMode: TravelMode.driving,
      );
    } else if (rideData!.statut == "on ride") {
      result = await polylinePoints.getRouteBetweenCoordinates(
        Constant.kGoogleApiKey.toString(),
        PointLatLng(dLat, dLng),
        PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
        wayPoints: wayPointList,
        optimizeWaypoints: true,
        travelMode: TravelMode.driving,
      );
    } else {
      result = await polylinePoints.getRouteBetweenCoordinates(
        Constant.kGoogleApiKey.toString(),
        PointLatLng(departureLatLong.latitude, departureLatLong.longitude),
        PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
        wayPoints: wayPointList,
        optimizeWaypoints: true,
        travelMode: TravelMode.driving,
      );
    }

    _markers['Departure'] = Marker(
      markerId: const MarkerId('Departure'),
      infoWindow: const InfoWindow(title: "Departure"),
      position: LatLng(double.parse(rideData!.latitudeDepart.toString()), double.parse(rideData!.longitudeDepart.toString())),
      icon: departureIcon!,
    );

    _markers['Destination'] = Marker(
      markerId: const MarkerId('Destination'),
      infoWindow: const InfoWindow(title: "Destination"),
      position: destinationLatLong,
      icon: destinationIcon!,
    );

    for (var i = 0; i < rideData!.stops!.length; i++) {
      _markers['${rideData!.stops![i]}'] = Marker(
        markerId: MarkerId('${rideData!.stops![i]}'),
        infoWindow: InfoWindow(title: rideData!.stops![i].location!),
        position: LatLng(double.parse(rideData!.stops![i].latitude!), double.parse(rideData!.stops![i].longitude!)),
        icon: stopIcon!,
      );
    }

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: ConstantColors.primary,
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, _controller);

    setState(() {});
  }

  Future<void> updateCameraLocation(
      LatLng source,
      LatLng destination,
      GoogleMapController? mapController,
      ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}
