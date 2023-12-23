import 'dart:ui';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/home_controller.dart';
import 'package:Urride/model/driver_hiring_model.dart';
import 'package:Urride/model/driver_model.dart';
import 'package:Urride/model/user_vehicle_category_model.dart';
import 'package:Urride/model/vehicle_category_model.dart';

import 'package:Urride/themes/button_them.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:Urride/themes/custom_dialog_box.dart';
import 'package:Urride/themes/text_field_them.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:Urride/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../new_ride_screens/new_ride_screen.dart';

import 'home_screen.dart';




String? gender;


class RadioExampleApp extends StatelessWidget {
  const RadioExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
enum SingingCharacter { lafayette, jefferson }
// double rideDetailscontainerHeight = 0;
// double requestridecontainerHeight = 0;
// double searchcontainerHeight = 300;
// bool drqwopen = true;
// void displayRequestRideContainer()
// {
//   setstate((){
//     requestridecontainerHeight = 250.0;
//   });
// }
// resetApp()
// {
//   setState(() {
//     drawerOpen = true;
//     searchcontainerHeight = 300.0;
//     rideDetailscontainerHeight = 0;
//     bottomPaddingofMap = 230.0;
//     polylineSet.clear();
//     markerSet.clear();
//     circleSet.clear();
//     pLineCoordinates.clear();
//   });
//   locatePosition();
// }
// void displayRideDetailsContainer()async
// {
//   await getPlaceDirection();
//   setState(({
//     searchcontainerHeight = 0;
//     rideDetailsContainerHeiht = 240.0;
//     bottomPaddingOfMap = 230.0;
//     drawerOpen=true;
//   }))
// }
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final CameraPosition _kInitialPosition = const CameraPosition(
      target: LatLng(19.018255973653343, 72.84793849278007),
      zoom: 11.0,
      tilt: 0,
      bearing: 0);

  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  String tripStatus = 'searching';
  final controller = Get.put(HomeController());

  GoogleMapController? _controller;
  final Location currentLocation = Location();

  final Map<String, Marker> _markers = {};

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;

  LatLng? departureLatLong;
  LatLng? destinationLatLong;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  get selectedOption => null;

  get controllerRideDetails => "";



  @override
  void initState() {
    setIcons();
    controller.multiStopList.clear();
    controller.multiStopListNew.clear();
    super.initState();
  }

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          size: Size(10, 10),
        ),
        "assets/icons/pickup.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          size: Size(10, 10),
        ),
        "assets/icons/dropoff.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          size: Size(10, 10),
        ),
        "assets/icons/ic_taxi.png")
        .then((value) {
      taxiIcon = value;
    });
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          size: Size(10, 10),
        ),
        "assets/icons/location.png")
        .then((value) {
      stopIcon = value;
    });


  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCurrentLocation(bool isDepartureSet) async {
    if (isDepartureSet) {
      LocationData location = await currentLocation.getLocation();
      List<get_cord_address.Placemark> placeMarks =
      await get_cord_address.placemarkFromCoordinates(
          location.latitude ?? 0.0, location.longitude ?? 0.0);

      final address = (placeMarks.first.subLocality!.isEmpty
          ? ''
          : "${placeMarks.first.subLocality}, ") +
          (placeMarks.first.street!.isEmpty
              ? ''
              : "${placeMarks.first.street}, ") +
          (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
          (placeMarks.first.subAdministrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.subAdministrativeArea}, ") +
          (placeMarks.first.administrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.administrativeArea}, ") +
          (placeMarks.first.country!.isEmpty
              ? ''
              : "${placeMarks.first.country}, ") +
          (placeMarks.first.postalCode!.isEmpty
              ? ''
              : "${placeMarks.first.postalCode}, ");
      departureController.text = address;
      setState(() {
        setDepartureMarker(
            LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     Get.to(PaymentSelectionScreen());
      //   },
      // ),
      backgroundColor: ConstantColors.background,
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            initialCameraPosition: _kInitialPosition,
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
              LocationData location = await currentLocation.getLocation();
              _controller!.moveCamera(CameraUpdate.newLatLngZoom(
                  LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
                  14));
            },
            polylines: Set<Polyline>.of(polyLines.values),
            myLocationEnabled: true,
            markers: _markers.values.toSet(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: ElevatedButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      "assets/icons/ic_side_menu.png",
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Column(
                      children: [
                        Builder(builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 00),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/icons/location.png",
                                  height: 25,
                                  width: 25,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      await controller
                                          .placeSelectAPI(context)
                                          .then((value) {
                                        if (value != null) {
                                          departureController.text = value
                                              .result.formattedAddress
                                              .toString();
                                          setDepartureMarker(LatLng(
                                              value.result.geometry!.location
                                                  .lat,
                                              value.result.geometry!.location
                                                  .lng));
                                        }
                                      });
                                    },
                                    child: buildTextField(
                                      title: "Departure".tr,
                                      textController: departureController,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    getCurrentLocation(true);
                                  },
                                  autofocus: false,
                                  icon: const Icon(
                                    Icons.my_location_outlined,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            for (int index = 0;
                            index < controller.multiStopListNew.length;
                            index += 1)
                              Container(
                                key: ValueKey(
                                    controller.multiStopListNew[index]),
                                child: Column(
                                  children: [
                                    const Divider(),
                                    InkWell(
                                        onTap: () async {
                                          await controller
                                              .placeSelectAPI(context)
                                              .then((value) {
                                            if (value != null) {
                                              controller.multiStopListNew[index]
                                                  .editingController.text =
                                                  value.result.formattedAddress
                                                      .toString();
                                              controller.multiStopListNew[index]
                                                  .latitude =
                                                  value.result.geometry!
                                                      .location.lat
                                                      .toString();
                                              controller.multiStopListNew[index]
                                                  .longitude =
                                                  value.result.geometry!
                                                      .location.lng
                                                      .toString();
                                              setStopMarker(
                                                  LatLng(
                                                      value.result.geometry!
                                                          .location.lat,
                                                      value.result.geometry!
                                                          .location.lng),
                                                  index);
                                            }
                                          });
                                        },
                                        child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                String.fromCharCode(index + 65),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: ConstantColors
                                                        .hintTextColor),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: buildTextField(
                                                  title:
                                                  "Where do you want to stop ?"
                                                      .tr,
                                                  textController: controller
                                                      .multiStopListNew[index]
                                                      .editingController,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  controller.removeStops(index);
                                                  _markers
                                                      .remove("Stop $index");
                                                  getDirections();
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 25,
                                                  color: ConstantColors
                                                      .hintTextColor,
                                                ),
                                              )
                                            ])),
                                  ],
                                ),
                              ),
                          ],
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final AddStopModel item = controller
                                  .multiStopListNew
                                  .removeAt(oldIndex);
                              controller.multiStopListNew
                                  .insert(newIndex, item);
                            });
                          },
                        ),

                        const Divider(),
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/dropoff.png",
                              height: 25,
                              width: 25,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await controller
                                      .placeSelectAPI(context)
                                      .then((value) {
                                    if (value != null) {
                                      destinationController.text = value
                                          .result.formattedAddress
                                          .toString();
                                      setDestinationMarker(LatLng(
                                          value.result.geometry!.location.lat,
                                          value.result.geometry!.location.lng));
                                    }
                                  });
                                },
                                child: buildTextField(
                                  title: "Where do you want to go ?".tr,
                                  textController: destinationController,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ListView.builder(
                        //     shrinkWrap: true,
                        //     itemCount: controller.multiStopList.length,
                        //     itemBuilder: (context, int index) {
                        //       return Draggable(
                        //         onDragEnd: (DraggableDetails details) {
                        //           print(
                        //               '\x1b[92m ====== ${details.velocity.pixelsPerSecond}');
                        //           print('\x1b[92m ====== ${details.offset}');
                        //         },
                        //         feedback: Material(
                        //           child: ConstrainedBox(
                        //             constraints: BoxConstraints(
                        //                 maxWidth:
                        //                     MediaQuery.of(context).size.width),
                        //             child: Column(
                        //               children: [
                        //                 const Divider(),
                        //                 InkWell(
                        //                   onTap: () async {
                        //                     await controller
                        //                         .placeSelectAPI(context)
                        //                         .then((value) {
                        //                       if (value != null) {
                        //                         controller
                        //                                 .multiStopList[index]
                        //                                 .editingController
                        //                                 .text =
                        //                             value
                        //                                 .result.formattedAddress
                        //                                 .toString();
                        //                         controller.multiStopList[index]
                        //                                 .latitude =
                        //                             value.result.geometry!
                        //                                 .location.lat
                        //                                 .toString();
                        //                         controller.multiStopList[index]
                        //                                 .longitude =
                        //                             value.result.geometry!
                        //                                 .location.lng
                        //                                 .toString();
                        //                         setStopMarker(
                        //                             LatLng(
                        //                                 value.result.geometry!
                        //                                     .location.lat,
                        //                                 value.result.geometry!
                        //                                     .location.lng),
                        //                             index);
                        //                       }
                        //                     });
                        //                   },
                        //                   child: Row(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.center,
                        //                     children: [
                        //                       Icon(
                        //                         Icons.location_on_outlined,
                        //                         size: 25,
                        //                         color: ConstantColors
                        //                             .hintTextColor,
                        //                       ),
                        //                       SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       Expanded(
                        //                         child: buildTextField(
                        //                           title:
                        //                               "Where do you want to stop ?",
                        //                           textController: controller
                        //                               .multiStopList[index]
                        //                               .editingController,
                        //                         ),
                        //                       ),
                        //                       SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       InkWell(
                        //                         onTap: () {
                        //                           controller.removeStops(index);
                        //                           _markers
                        //                               .remove("Stop $index");
                        //                           getDirections();
                        //                         },
                        //                         child: Icon(
                        //                           Icons.close,
                        //                           size: 25,
                        //                           color: ConstantColors
                        //                               .hintTextColor,
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        // child: Column(
                        //   children: [
                        //     const Divider(),
                        //     InkWell(
                        //       onTap: () async {
                        //         await controller
                        //             .placeSelectAPI(context)
                        //             .then((value) {
                        //           if (value != null) {
                        //             controller.multiStopList[index]
                        //                     .editingController.text =
                        //                 value.result.formattedAddress
                        //                     .toString();
                        //             controller.multiStopList[index]
                        //                     .latitude =
                        //                 value.result.geometry!.location
                        //                     .lat
                        //                     .toString();
                        //             controller.multiStopList[index]
                        //                     .longitude =
                        //                 value.result.geometry!.location
                        //                     .lng
                        //                     .toString();
                        //             setStopMarker(
                        //                 LatLng(
                        //                     value.result.geometry!
                        //                         .location.lat,
                        //                     value.result.geometry!
                        //                         .location.lng),
                        //                 index);
                        //           }
                        //         });
                        //       },
                        //       child: Row(
                        //         crossAxisAlignment:
                        //             CrossAxisAlignment.center,
                        //         children: [
                        //           Icon(
                        //             Icons.location_on_outlined,
                        //             size: 25,
                        //             color: ConstantColors.hintTextColor,
                        //           ),
                        //           SizedBox(
                        //             width: 5,
                        //           ),
                        //           Expanded(
                        //             child: buildTextField(
                        //               title:
                        //                   "Where do you want to stop ?",
                        //               textController: controller
                        //                   .multiStopList[index]
                        //                   .editingController,
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: 5,
                        //           ),
                        //           InkWell(
                        //             onTap: () {
                        //               controller.removeStops(index);
                        //               _markers.remove("Stop $index");
                        //               getDirections();
                        //             },
                        //             child: Icon(
                        //               Icons.close,
                        //               size: 25,
                        //               color:
                        //                   ConstantColors.hintTextColor,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        //         ),
                        //       );
                        //     }),

                        const Divider(),
                        InkWell(
                          onTap: () {
                            controller.addStops();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: ConstantColors.hintTextColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Add stop'.tr,
                                style: TextStyle(
                                    color: ConstantColors.hintTextColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],

                    ),
                  ),
                ),
              ),
            ],
          ),
//           widget(
//             bottom:0.0,
//             left:0.0,
//             right:0.0,
//             child: AnimatesSize(
// vsync:this,
//              curve:Cure.bounceIn,
//              duration: newDuration(milliseconds:160),
//              child:Container(
//                height:rideDetailsContainerHeight,
//
//
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
//                color:Colors.white,
//                boxShadow:[
//                  BoxShadow(
//                    spreadRadius: 0.5,
//                    blurRadius: 16.0,
//                    color: Colors.black54,
//                      offset:Offset(0.7,0.7),
//                  )
//                ]
//              ),
//
//               height:requestRideContainerHeight,
//               child:Padding(
//                 padding:const EdgeInsets.all(30.0),
//                 child: Column(
//                   children:[
//
//                     SizedBox(height:12.0,),
//                     SizedBox(
//                       width:double.infinity,
//                       child:ColorizeAnimatedTextKit(
//                         onTap: () {
//                           print("Tap Event");
//                         },
//                         text:[
//                           "Request A Ride",
//                           "Please Wait",
//                           "Finding A Driver",
//                         ],
//                         textStyle:TextStyle(
//                           fontSize: 55.0,
//                           fontFamily: "Signature"
//                       ),
//                         colors : [
//                           Colors.green,
//                           Colors.purple,
//                           Colors.pink,
//                           Colors.blue,
//                           Colors.yellow,
//                           Colors.red,
//                         ],
//                          textAlign:TextAlign.center,
//                         alignment:AlignmentDirectional.topStart,
//
//
//                           ),
//                     ),
//                     SizedBox(height: 22.0),
//                     container(
//                       height:60.0,
//                       width:60.0,
//                       decoration:BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(26.0),
//                         border: Border.all(width:2.0,color:Colors.grey300),
//                       )
//                         child:Icon(Icon.close,size:26.0),
//                 SizedBox(height: 10.0,),
//                 Container(
//                   width:Double.infinity,
//                   child:Text("Cancel Ride",textAlign: TextAlign.center,style: TextStyle(fontSize:12.0),),
//                 ),
//                 )
//                     )
//                         ],
//                         isRepeatingAnimation: true,
// ],
//
//               ),
//                   ),
//           ),
//                   )
//
//
//
//
//           ),

          // Widget(
          //   bottom: 0.0,
          //   left: 0.0,
          //   right: 0.0,
          //   child: AnimatedSize(
          //     vsync: this,
          //     curve: Curves.bounceIn,
          //     duration: Duration(milliseconds: 160),
          //     child: Container(
          //       height: rideDetailsContainerHeight,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.only(
          //           topLeft: Radius.circular(16.0),
          //           topRight: Radius.circular(16.0),
          //         ),
          //         color: Colors.white,
          //         boxShadow: [
          //           BoxShadow(
          //             spreadRadius: 0.5,
          //             blurRadius: 16.0,
          //             color: Colors.black54,
          //             offset: Offset(0.7, 0.7),
          //           ),
          //         ],
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.all(30.0),
          //         child: Column(
          //           children: [
          //             SizedBox(height: 12.0),
          //             SizedBox(
          //               width: double.infinity,
          //               child: ColorizeAnimatedTextKit(
          //                 onTap: () {
          //                   print("Tap Event");
          //                 },
          //                 text: [
          //                   "Request A Ride",
          //                   "Please Wait",
          //                   "Finding A Driver",
          //                 ],
          //                 textStyle: TextStyle(
          //                   fontSize: 55.0,
          //                   fontFamily: "Signature",
          //                 ),
          //                 colors: [
          //                   Colors.green,
          //                   Colors.purple,
          //                   Colors.pink,
          //                   Colors.blue,
          //                   Colors.yellow,
          //                   Colors.red,
          //                 ],
          //                 textAlign: TextAlign.center,
          //                 alignment: AlignmentDirectional.topStart,
          //               ),
          //             ),
          //             SizedBox(height: 22.0),
          //             Container(
          //               height: 60.0,
          //               width: 60.0,
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 borderRadius: BorderRadius.circular(26.0),
          //                 border: Border.all(width: 2.0, color: Colors.grey300),
          //               ),
          //               child: Icon(Icons.close, size: 26.0),
          //             ),
          //             SizedBox(height: 10.0),
          //             Container(
          //               width: double.infinity,
          //               child: Text(
          //                 "Cancel Ride",
          //                 textAlign: TextAlign.center,
          //                 style: TextStyle(fontSize: 12.0),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // );



          Visibility(
            visible: controller.confirmWidgetVisible.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: confirmWidget(),
            ),
          ),
        ],






      ),
    );
  }

  setDepartureMarker(LatLng departure) {
    setState(() {
      _markers.remove("Departure");
      _markers['Departure'] = Marker(
        markerId: const MarkerId('Departure'),
        infoWindow: const InfoWindow(title: "Departure"),
        position: departure,
        icon: departureIcon!,
      );
      departureLatLong = departure;
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(departure.latitude, departure.longitude), zoom: 14)));

      // _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(departure.latitude, departure.longitude), zoom: 18)));
      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    });
  }

  setDestinationMarker(LatLng destination) {
    setState(() {
      _markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: destination,
        icon: destinationIcon!,
      );
      destinationLatLong = destination;

      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    });
  }

  setStopMarker(LatLng destination, int index) {
    // final List<int> codeUnits = "Anand".codeUnits;
    // final Uint8List unit8List = Uint8List.fromList(codeUnits);
    // print('\x1b[97m ===== $unit8List =====');
    setState(() {
      _markers['Stop $index'] = Marker(
        markerId: MarkerId('Stop $index'),
        infoWindow:
        InfoWindow(title: "Stop ${String.fromCharCode(index + 65)}"),
        position: destination,
        icon: stopIcon!,
      ); //BitmapDescriptor.fromBytes(unit8List));
      // destinationLatLong = destination;

      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    });
  }

  Widget buildTextField(
      {required title, required TextEditingController textController}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: ConstantColors.titleTextColor),
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    );
  }

  getDirections() async {
    List<PolylineWayPoint> wayPointList = [];
    for (var i = 0; i < controller.multiStopList.length; i++) {
      wayPointList.add(PolylineWayPoint(
          location: controller.multiStopList[i].editingController.text));
    }
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constant.kGoogleApiKey.toString(),
      PointLatLng(departureLatLong!.latitude, departureLatLong!.longitude),
      PointLatLng(destinationLatLong!.latitude, destinationLatLong!.longitude),
      wayPoints: wayPointList,
      optimizeWaypoints: true,
      travelMode: TravelMode.driving,
    );

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
      color: Colors.black ,
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );
    polyLines[id] = polyline;
    setState(() {});
  }

  confirmWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ButtonThem.buildIconButton(context,
                iconSize: 16.0,
                icon: Icons.arrow_back_ios,
                iconColor: Colors.limeAccent,
                btnHeight: 40,
                btnWidthRatio: 0.25,
                title: "Back".tr,
                btnColor: Colors.black,
                txtColor: Colors.limeAccent, onPress: () {
                  controller.confirmWidgetVisible.value = false;
                }),
          ),
          Expanded(
            child: ButtonThem.buildButton(context,
                btnHeight: 40,
                title: "Continue".tr,
                btnColor: Colors.limeAccent,
                txtColor: Colors.black, onPress: () async {
                  await controller
                      .getDurationDistance(departureLatLong!, destinationLatLong!)
                      .then((durationValue) async {
                    if (durationValue != null) {
                      await controller.getUserPendingPayment().then((value) async {
                        if (value != null) {
                          if (value['success'] == "success") {
                            if (value['data']['amount'] != 0) {
                              _pendingPaymentDialog(context);
                            } else {
                              if (Constant.distanceUnit == "KM") {
                                controller.distance.value = durationValue['rows']
                                    .first['elements']
                                    .first['distance']['value'] /
                                    1000.00;
                              } else {
                                controller.distance.value = durationValue['rows']
                                    .first['elements']
                                    .first['distance']['value'] /
                                    1609.34;
                              }

                              controller.duration.value = durationValue['rows']
                                  .first['elements']
                                  .first['duration']['text'];
                              // Get.back();
                              controller.confirmWidgetVisible.value = false;
                              tripOptionBottomSheet(context);
                            }
                          } else {
                            if (Constant.distanceUnit == "KM") {
                              controller.distance.value = durationValue['rows']
                                  .first['elements']
                                  .first['distance']['value'] /
                                  1000.00;
                            } else {
                              controller.distance.value = durationValue['rows']
                                  .first['elements']
                                  .first['distance']['value'] /
                                  1609.34;
                            }
                            controller.duration.value = durationValue['rows']
                                .first['elements']
                                .first['duration']['text'];
                            controller.confirmWidgetVisible.value = false;
                            // Get.back();
                            tripOptionBottomSheet(context);
                          }
                        }
                      });
                    }
                  });
                }),
          ),
        ],
      ),
    );
  }



  final passengerController = TextEditingController(text: "1");

  tripOptionBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.white,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Select Type".tr,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),

                        ),
                      ),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                                "assets/icons/Vehicle.gif",
                                height: 170, width: 170
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset("assets/icons/driver.png",
                                height: 100, width: 170),
                          )
                        ],
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Padding(

                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              child: ButtonThem.buildButton(context,

                                  btnHeight: 40,
                                  btnWidthRatio: 0.4,
                                  title: "Rider".tr,
                                  btnColor: Colors.limeAccent,
                                  txtColor: Colors.black, onPress: () async {
                                    if (passengerController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please Select Vehicle Type".tr);
                                    } else {
                                      await controller
                                          .getVehicleCategory()
                                          .then((value) {
                                        if (value != null) {
                                          if (value.success == "Success") {
                                            Get.back();

                                            chooseVehicleBottomSheet(
                                              context,
                                              value as VehicleCategoryModel,
                                            );
                                          }
                                        }
                                      });
                                    }
                                  }),
                            ),
                            Expanded(

                              child: ButtonThem.buildButton(context,
                                  btnHeight: 40,
                                  title: "Driver".tr,
                                  btnWidthRatio: 0.7,
                                  btnColor: Colors.limeAccent,
                                  txtColor: Colors.black, onPress: () async {
                                    if (passengerController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please Select Trip Type".tr);
                                    } else {
                                      await controller
                                          .getUserVehicleCategory()
                                          .then((value) {
                                        if (value != null) {
                                          if (value.success == "Success") {
                                            Get.back();

                                            chooseUserVehicleBottomSheet(
                                              context,
                                              value as UserVehicleCategoryModel,
                                            );
                                          }
                                        }
                                      });
                                    }
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

  chooseVehicleBottomSheet(
      BuildContext context,
      VehicleCategoryModel vehicleCategoryModel,
      ) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Choose Your Vehicle Type".tr,
                        style:
                        const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset("assets/icons/ic_distance.png",
                                  height: 24, width: 24),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text("Distance".tr,
                                    style: const TextStyle(fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                        Text(
                            "${controller.distance.value.toStringAsFixed(2)} ${Constant.distanceUnit}")
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: vehicleCategoryModel.data!.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Obx(
                                  () => InkWell(
                                onTap: () {
                                  controller.vehicleData =
                                  vehicleCategoryModel.data![index];
                                  controller.selectedVehicle.value =
                                      vehicleCategoryModel.data![index].id
                                          .toString();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: controller
                                            .selectedVehicle.value ==
                                            vehicleCategoryModel
                                                .data![index].id
                                                .toString()
                                            ? Colors.limeAccent
                                            : Colors.black.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: vehicleCategoryModel
                                                .data![index].image
                                                .toString(),
                                            fit: BoxFit.fill,
                                            width: 80,
                                            height: 50,
                                            placeholder: (context, url) =>
                                                Constant.loader(),
                                            errorWidget:
                                                (context, url, error) =>
                                            const Icon(Icons.error),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 10),
                                                    child: Text(
                                                      vehicleCategoryModel
                                                          .data![index].libelle
                                                          .toString(),
                                                      textAlign:
                                                      TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: controller
                                                              .selectedVehicle
                                                              .value ==
                                                              vehicleCategoryModel
                                                                  .data![
                                                              index]
                                                                  .id
                                                                  .toString()
                                                              ? Colors.black
                                                              : Colors.black,
                                                          fontWeight:
                                                          FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        controller
                                                            .duration.value,
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: TextStyle(
                                                          color: controller
                                                              .selectedVehicle
                                                              .value ==
                                                              vehicleCategoryModel
                                                                  .data![
                                                              index]
                                                                  .id
                                                                  .toString()
                                                              ? Colors.black
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        Constant().amountShow(
                                                            amount:
                                                            "${controller.calculateTripPrice(
                                                              distance: controller
                                                                  .distance.value,
                                                              deliveryCharges: double.parse(
                                                                  vehicleCategoryModel
                                                                      .data![index]
                                                                      .deliveryCharges!),
                                                              minimumDeliveryCharges:
                                                              double.parse(
                                                                  vehicleCategoryModel
                                                                      .data![
                                                                  index]
                                                                      .minimumDeliveryCharges!),
                                                              minimumDeliveryChargesWithin:
                                                              double.parse(
                                                                  vehicleCategoryModel
                                                                      .data![
                                                                  index]
                                                                      .minimumDeliveryChargesWithin!),
                                                            )}"),
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: TextStyle(
                                                          color: controller
                                                              .selectedVehicle
                                                              .value ==
                                                              vehicleCategoryModel
                                                                  .data![
                                                              index]
                                                                  .id
                                                                  .toString()
                                                              ? Colors.black
                                                              : Colors.black,
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
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.limeAccent,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: Colors.black,
                                txtColor: Colors.limeAccent, onPress: () {
                                  Get.back();
                                  tripOptionBottomSheet(context);
                                }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book Now".tr,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black, onPress: () async {
                                  if (controller.selectedVehicle.value.isNotEmpty) {
                                    double cout = 0.0;

                                    if (controller.distance.value >
                                        double.parse(controller.vehicleData!
                                            .minimumDeliveryChargesWithin!)) {
                                      cout = (controller.distance.value *
                                          double.parse(controller
                                              .vehicleData!.deliveryCharges!))
                                          .toDouble();
                                    } else {
                                      cout = double.parse(controller
                                          .vehicleData!.minimumDeliveryCharges
                                          .toString());
                                    }
                                    await controller
                                        .getDriverDetails(
                                        controller.vehicleData!.id.toString(),
                                        departureLatLong!.latitude.toString(),
                                        departureLatLong!.longitude.toString())
                                        .then((value) {
                                      if (value != null) {
                                        if (value.success == "Success") {
                                          print(
                                              '== Constant.driverRadius!==${Constant.driverRadius!}');
                                          List<DriverData> driverData = [];
                                          for (var i = 0;
                                          i < value.data!.length;
                                          i++) {
                                            if (double.parse(
                                                value.data![i].distance!) <=
                                                double.parse(
                                                    Constant.driverRadius!)) {
                                              driverData.add(value.data![i]);
                                            }
                                          }
                                          if (driverData.isNotEmpty) {
                                            Get.back();
                                            conformDataBottomSheet(
                                                context, driverData[0], cout);
                                          } else {
                                            ShowToastDialog.showToast(
                                                "Driver not available".tr);
                                          }
                                        } else {
                                          ShowToastDialog.showToast(
                                              "Driver not available".tr);
                                        }
                                      }
                                    });
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Please select Vehicle Type".tr);
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  chooseUserVehicleBottomSheet(
      BuildContext context,
      UserVehicleCategoryModel uservehicleCategoryModel,
      ) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Select The Trip Type".tr,

                        style:
                        const TextStyle(fontSize: 18, color: Colors.black),
                      ),


                    ),
                    Row(
                      children: [
                        Expanded(
                          child:RadioListTile(
                            contentPadding:EdgeInsets.all(0.0),
                            title: Text("One Way"),
                            value: "Oneway",
                            groupValue: gender,
                            onChanged: (value){
                              setState(() {
                                gender = value.toString();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child:RadioListTile(
                            contentPadding:EdgeInsets.all(0.0),
                            title: Text("Round Trip"),
                            value: "Round",
                            groupValue: gender,
                            onChanged: (value){
                              setState(() {
                                gender = value.toString();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: uservehicleCategoryModel.data!.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Obx(
                                  () => InkWell(
                                onTap: () {
                                  controller.userVehicleData =
                                  uservehicleCategoryModel.data![index];
                                  controller.selectedUserVehicle.value =
                                      uservehicleCategoryModel.data![index].id
                                          .toString();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: controller
                                            .selectedUserVehicle.value ==
                                            uservehicleCategoryModel
                                                .data![index].id
                                                .toString()
                                            ? Colors.limeAccent
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: uservehicleCategoryModel
                                                .data![index].image
                                                .toString(),
                                            fit: BoxFit.fill,
                                            width: 80,
                                            height: 50,
                                            placeholder: (context, url) =>
                                                Constant.loader(),
                                            errorWidget:
                                                (context, url, error) =>
                                            const Icon(Icons.error),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 10),
                                                    child: Text(
                                                      uservehicleCategoryModel
                                                          .data![index].libelle
                                                          .toString(),
                                                      textAlign:
                                                      TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: controller
                                                              .selectedUserVehicle
                                                              .value ==
                                                              uservehicleCategoryModel
                                                                  .data![
                                                              index]
                                                                  .id
                                                                  .toString()
                                                              ? Colors.black
                                                              : Colors.black,
                                                          fontWeight:
                                                          FontWeight.w500),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.limeAccent,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: Colors.black,
                                txtColor: Colors.limeAccent, onPress: () {
                                  Get.back();
                                  tripOptionBottomSheet(context);
                                }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Continue".tr,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black, onPress: () async {
                                  if (controller.selectedUserVehicle.value.isNotEmpty) {
                                    double cout = 0.0;

                                    if (controller.distance.value >
                                        double.parse(controller.userVehicleData!
                                            .minimumDeliveryChargesWithin!)) {
                                      cout = (controller.distance.value *
                                          double.parse(controller
                                              .userVehicleData!.deliveryCharges!))
                                          .toDouble();
                                    } else {
                                      cout = double.parse(controller
                                          .userVehicleData!.minimumDeliveryCharges
                                          .toString());
                                    }
                                    await controller
                                        .getdriverHiringDetails(
                                        controller.userVehicleData!.id.toString(),
                                        departureLatLong!.latitude.toString(),
                                        departureLatLong!.longitude.toString())
                                        .then((value) {
                                      if (value != null) {
                                        if (value.success == "Success") {
                                          print(
                                              '== Constant.driverRadius!==${Constant.driverRadius!}');
                                          List<DriverHiringData> driverHiringData = [];
                                          for (var i = 0;
                                          i < value.data!.length;
                                          i++) {
                                            if (double.parse(
                                                value.data![i].distance!) <=
                                                double.parse(
                                                    Constant.driverRadius!)) {
                                              driverHiringData.add(value.data![i]);
                                            }
                                          }
                                          if (driverHiringData.isNotEmpty) {
                                            Get.back();
                                            conformDataHiringBottomSheet(
                                                context, driverHiringData[0], cout);
                                          } else {
                                            ShowToastDialog.showToast(
                                                "Driver not available".tr);
                                          }
                                        } else {
                                          ShowToastDialog.showToast(
                                              "Driver not available".tr);
                                        }
                                      }
                                    });
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Please select Vehicle Type".tr);
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }



  conformDataBottomSheet(
      BuildContext context, DriverData driverModel, double tripPrice) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.white,
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
                child: Obx(
                      () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              // child: CachedNetworkImage(
                              //   imageUrl: driverModel.photo.toString(),
                              //   fit: BoxFit.cover,
                              //   height: 72,
                              //   width: 72,
                              //   placeholder: (context, url) =>
                              //       Constant.loader(),
                              //   errorWidget: (context, url, error) =>
                              //   const Icon(Icons.error),
                              // ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //   driverModel.prenom.toString(),
                                //   style: TextStyle(
                                //       fontSize: 16,
                                //       color: ConstantColors.titleTextColor,
                                //       fontWeight: FontWeight.w800),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 3),
                                //   child: StarRating(
                                //       size: 18,
                                //       rating: double.parse(
                                //           driverModel.moyenne.toString()),
                                //       color: Colors.limeAccent),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 3),
                                //   child: Text(
                                //     "Total trips".tr +
                                //         " ${driverModel.totalCompletedRide.toString()}",
                                //     style: TextStyle(
                                //       color: ConstantColors.subTitleTextColor,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          // Column(
                          //   children: [
                          //     InkWell(
                          //       onTap: () {
                          //         Constant.makePhoneCall(
                          //             driverModel.toString());
                          //       },
                          //       child: ClipOval(
                          //         child: Container(
                          //           color: Colors.limeAccent,
                          //           child: const Padding(
                          //             padding: EdgeInsets.all(6.0),
                          //             child: Icon(
                          //               Icons.phone,
                          //               size: 18,
                          //               color: Colors.black,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //
                          //     Padding(
                          //       padding: const EdgeInsets.only(top: 10),
                          //       child: InkWell(
                          //           onTap: () {
                          //             _favouriteNameDialog(context);
                          //           },
                          //           child: Image.asset(
                          //             'assets/icons/add_fav.png',
                          //             height: 32,
                          //             width: 32,
                          //           )),
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                      Padding(

                        padding: const EdgeInsets.symmetric(vertical: 20.0),

                        child: Row(
                          children: [
                            Expanded(

                              child: InkWell(

                                onTap: () {
                                  _paymentMethodDialog(
                                    context,
                                  );
                                },
                                child: buildDetails(
                                  title: controller.paymentMethodType.value,
                                  value: 'Payment'.tr,),
                              ),
                            ),

                            const SizedBox(
                              width: 10,

                            ),
                            Expanded(
                                child: buildDetails(
                                    title: controller.duration.value,
                                    value: 'Duration'.tr)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: buildDetails(
                                    title: Constant().amountShow(
                                        amount: tripPrice.toString()),
                                    value: 'Trip Price'.tr,
                                    txtColor: Colors.black)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Opacity(
                            opacity: 0.6,
                            // child: Text(
                            //   "Cab Details:".tr,
                            //   style: const TextStyle(
                            //       fontSize: 12, fontWeight: FontWeight.w500),
                            // ),
                          ),
                          // Text(
                          //   driverModel.model.toString(),
                          //   style: const TextStyle(fontWeight: FontWeight.w600),
                          // ),
                          // const Text(
                          //   "|",
                          //   style: TextStyle(fontWeight: FontWeight.w600),
                          // ),
                          // Text(
                          //   driverModel.brand.toString(),
                          //   style: const TextStyle(fontWeight: FontWeight.w600),
                          // ),
                          // const Text(
                          //   "|",
                          //   style: TextStyle(fontWeight: FontWeight.w600),
                          // ),
                          Text(
                            driverModel.numberplate.toString(),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.limeAccent,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: Colors.black,
                                txtColor: Colors.limeAccent, onPress: () async {
                                  await controller
                                      .getUserVehicleCategory()
                                      .then((value) {
                                    if (value != null) {
                                      if (value.success == "Success") {
                                        Get.back();
                                        List tripPrice = [];
                                        for (int i = 0;
                                        i < value.data!.length;
                                        i++) {
                                          tripPrice.add(0.0);
                                        }
                                        if (value.data!.isNotEmpty) {
                                          for (int i = 0;
                                          i < value.data!.length;
                                          i++) {
                                            if (controller.distance.value >
                                                double.parse(value.data![i]
                                                    .minimumDeliveryChargesWithin!)) {
                                              tripPrice.add((controller
                                                  .distance.value *
                                                  double.parse(value.data![i]
                                                      .deliveryCharges!))
                                                  .toDouble()
                                                  .toStringAsFixed(int.parse(
                                                  Constant.decimal ?? "2")));
                                            } else {
                                              tripPrice.add(double.parse(value
                                                  .data![i]
                                                  .minimumDeliveryCharges!)
                                                  .toStringAsFixed(int.parse(
                                                  Constant.decimal ?? "2")));
                                            }
                                          }
                                        }
                                        chooseVehicleBottomSheet(
                                          context,
                                          value as VehicleCategoryModel,
                                        );
                                      }
                                    }
                                  });
                                }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book now".tr,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black, onPress: () {
                                  if (controller.paymentMethodType.value ==
                                      "Select Method") {
                                    ShowToastDialog.showToast(
                                        "Please select payment method".tr);
                                  } else {
                                    List stopsList = [];
                                    for (var i = 0;
                                    i < controller.multiStopListNew.length;
                                    i++) {
                                      stopsList.add({
                                        "latitude": controller
                                            .multiStopListNew[i].latitude
                                            .toString(),
                                        "longitude": controller
                                            .multiStopListNew[i].longitude
                                            .toString(),
                                        "location": controller.multiStopListNew[i]
                                            .editingController.text
                                            .toString()
                                      });
                                    }

                                    Map<String, dynamic> bodyParams = {
                                      'user_id':
                                      Preferences.getInt(Preferences.userId)
                                          .toString(),
                                      'lat1': departureLatLong!.latitude.toString(),
                                      'lng1':
                                      departureLatLong!.longitude.toString(),
                                      'lat2':
                                      destinationLatLong!.latitude.toString(),
                                      'lng2':
                                      destinationLatLong!.longitude.toString(),
                                      'cout': tripPrice.toString(),
                                      'distance': controller.distance.toString(),
                                      'distance_unit':
                                      Constant.distanceUnit.toString(),
                                      'duree': controller.duration.toString(),
                                      'id_conducteur': driverModel.id.toString(),
                                      'id_payment':
                                      controller.paymentMethodId.value,
                                      'depart_name': departureController.text,
                                      'destination_name':
                                      destinationController.text,
                                      'stops': stopsList,
                                      'place': '',
                                      'number_poeple': passengerController.text,
                                      'image': '',
                                      'image_name': "",
                                      'statut_round': 'no',
                                      'trip_objective':
                                      controller.tripOptionCategory.value,
                                      'age_children1': controller
                                          .addChildList[0].editingController.text,
                                      'age_children2':
                                      controller.addChildList.length == 2
                                          ? controller.addChildList[1]
                                          .editingController.text
                                          : "",
                                      'age_children3':
                                      controller.addChildList.length == 3
                                          ? controller.addChildList[2]
                                          .editingController.text
                                          : "",
                                    };
                                    controller.bookRide(bodyParams).then((value) {
                                      if (value != null) {
                                        if (value['success'] == "success") {
                                          Get.back();
                                          departureController.clear();
                                          destinationController.clear();
                                          polyLines = {};
                                          departureLatLong = null;
                                          destinationLatLong = null;
                                          passengerController.clear();
                                          tripPrice = 0.0;
                                          _markers.clear();
                                          controller.clearData();
                                          getDirections();
                                          setIcons();

                                          // Show a loading widget while searching for a driver
                                          // Show loading dialog while searching for a driver
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 10),
                                                    Text("Searching for a driver to accept..."),
                                                  ],
                                                ),
                                              );
                                            },
                                          );



                                          // Simulate a delay to represent the process of searching for a driver
                                          Future.delayed(Duration(seconds: 300), () {
                                            // Close the loading dialog
                                            Navigator.of(context).pop();

                                            // Update the content of the success dialog
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "",
                                                  descriptions: "Your booking has been sent successfully",
                                                  onPress: () {
                                                    // Close the current dialog
                                                    Navigator.of(context).pop();

                                                    // Redirect to the waiting screen
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => NewRideScreen()),
                                                    );
                                                  },
                                                  img: Image.asset('assets/images/green_checked.png'),
                                                );
                                              },
                                            );
                                          });
                                        }
                                      }
                                    });






                                  }
                                }),



                          ),
                        ],
                      ),
                    ],
                  ),

                ),
              );
            }),

          );

        });






  }
  Widget buildBody() {
    switch (tripStatus) {
      case 'searching':
        return buildSearchScreen();
      case 'waiting':
        return buildWaitingScreen();
    // Add more cases for different trip statuses
      default:
        return Container();
    }
  }

  Widget buildSearchScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Search for a booking'),
          ElevatedButton(
            onPressed: () {
              // Perform booking search logic
              // ...

              // Update trip status to 'waiting'
              setState(() {
                tripStatus = 'waiting';
              });
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
  Widget buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Waiting for driver confirmation...'),
          // You can add a loading spinner or any other UI elements here
        ],
      ),
    );
  }

  conformDataHiringBottomSheet(
      BuildContext context, DriverHiringData driverHiringModel, double tripPrice) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.white,
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
                child: Obx(
                      () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: driverHiringModel.photo.toString(),
                                fit: BoxFit.cover,
                                height: 72,
                                width: 72,
                                placeholder: (context, url) =>
                                    Constant.loader(),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  driverHiringModel.prenom.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: ConstantColors.titleTextColor,
                                      fontWeight: FontWeight.w800),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: StarRating(
                                      size: 18,
                                      rating: double.parse(
                                          driverHiringModel.moyenne.toString()),
                                      color: Colors.limeAccent),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "Total trips".tr +
                                        " ${driverHiringModel.totalCompletedRide.toString()}",
                                    style: TextStyle(
                                      color: ConstantColors.subTitleTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Constant.makePhoneCall(
                                      driverHiringModel.toString());
                                },
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.limeAccent,
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: InkWell(
                                    onTap: () {
                                      _favouriteNameDialog(context);
                                    },
                                    child: Image.asset(
                                      'assets/icons/add_fav.png',
                                      height: 32,
                                      width: 32,
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(

                        padding: const EdgeInsets.symmetric(vertical: 20.0),

                        child: Row(
                          children: [
                            Expanded(

                              child: InkWell(

                                onTap: () {
                                  _paymentMethodDialog(
                                    context,
                                  );
                                },
                                child: buildDetails(
                                  title: controller.paymentMethodType.value,
                                  value: 'Payment'.tr,),
                              ),
                            ),

                            const SizedBox(
                              width: 10,

                            ),
                            Expanded(
                                child: buildDetails(
                                    title: controller.duration.value,
                                    value: 'Duration'.tr)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: buildDetails(
                                    title: Constant().amountShow(
                                        amount: tripPrice.toString()),
                                    value: 'Trip Price'.tr,
                                    txtColor: Colors.black)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "Cab Details:".tr,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),





                        ],
                      ),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.limeAccent,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: Colors.black,
                                txtColor: Colors.limeAccent, onPress: () async {
                                  await controller
                                      .getUserVehicleCategory()
                                      .then((value) {
                                    if (value != null) {
                                      if (value.success == "Success") {
                                        Get.back();
                                        List tripPrice = [];
                                        for (int i = 0;
                                        i < value.data!.length;
                                        i++) {
                                          tripPrice.add(0.0);
                                        }
                                        if (value.data!.isNotEmpty) {
                                          for (int i = 0;
                                          i < value.data!.length;
                                          i++) {
                                            if (controller.distance.value >
                                                double.parse(value.data![i]
                                                    .minimumDeliveryChargesWithin!)) {
                                              tripPrice.add((controller
                                                  .distance.value *
                                                  double.parse(value.data![i]
                                                      .deliveryCharges!))
                                                  .toDouble()
                                                  .toStringAsFixed(int.parse(
                                                  Constant.decimal ?? "2")));
                                            } else {
                                              tripPrice.add(double.parse(value
                                                  .data![i]
                                                  .minimumDeliveryCharges!)
                                                  .toStringAsFixed(int.parse(
                                                  Constant.decimal ?? "2")));
                                            }
                                          }
                                        }
                                        chooseVehicleBottomSheet(
                                          context,
                                          value as VehicleCategoryModel,
                                        );
                                      }
                                    }
                                  });
                                }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book now".tr,
                                btnColor: Colors.limeAccent,
                                txtColor: Colors.black, onPress: () {
                                  if (controller.paymentMethodType.value ==
                                      "Select Method") {
                                    ShowToastDialog.showToast(
                                        "Please select payment method".tr);
                                  } else {
                                    List stopsList = [];
                                    for (var i = 0;
                                    i < controller.multiStopListNew.length;
                                    i++) {
                                      stopsList.add({
                                        "latitude": controller
                                            .multiStopListNew[i].latitude
                                            .toString(),
                                        "longitude": controller
                                            .multiStopListNew[i].longitude
                                            .toString(),
                                        "location": controller.multiStopListNew[i]
                                            .editingController.text
                                            .toString()
                                      });
                                    }

                                    Map<String, dynamic> bodyParams = {
                                      'user_id':
                                      Preferences.getInt(Preferences.userId)
                                          .toString(),
                                      'lat1': departureLatLong!.latitude.toString(),
                                      'lng1':
                                      departureLatLong!.longitude.toString(),
                                      'lat2':
                                      destinationLatLong!.latitude.toString(),
                                      'lng2':
                                      destinationLatLong!.longitude.toString(),
                                      'cout': tripPrice.toString(),
                                      'distance': controller.distance.toString(),
                                      'distance_unit':
                                      Constant.distanceUnit.toString(),
                                      'duree': controller.duration.toString(),
                                      'id_conducteur': driverHiringModel.id.toString(),
                                      'id_payment':
                                      controller.paymentMethodId.value,
                                      'depart_name': departureController.text,
                                      'destination_name':
                                      destinationController.text,
                                      'stops': stopsList,
                                      'place': '',
                                      'number_poeple': passengerController.text,
                                      'image': '',
                                      'image_name': "",
                                      'statut_round': 'no',
                                      'trip_objective':
                                      controller.tripOptionCategory.value,
                                      'age_children1': controller
                                          .addChildList[0].editingController.text,
                                      'age_children2':
                                      controller.addChildList.length == 2
                                          ? controller.addChildList[1]
                                          .editingController.text
                                          : "",
                                      'age_children3':
                                      controller.addChildList.length == 3
                                          ? controller.addChildList[2]
                                          .editingController.text
                                          : "",
                                    };

                                    controller.bookRide(bodyParams).then((value) {
                                      if (value != null) {
                                        if (value['success'] == "success") {
                                          Get.back();
                                          departureController.clear();
                                          destinationController.clear();
                                          polyLines = {};
                                          departureLatLong = null;
                                          destinationLatLong = null;
                                          passengerController.clear();
                                          tripPrice = 0.0;
                                          _markers.clear();
                                          controller.clearData();
                                          getDirections();
                                          setIcons();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      CircularProgressIndicator(),
                                                      SizedBox(height: 10),
                                                      Text("Searching for a driver to accept..."),
                                                    ],
                                                  ),
                                                );
                                              });
                                        }
                                      }
                                    });
                                  }
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  final favouriteNameTextController = TextEditingController();

  _favouriteNameDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter Favourite Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldThem.buildTextField(
                  title: 'Favourite name'.tr,
                  labelText: 'Favourite name'.tr,
                  controller: favouriteNameTextController,
                  textInputType: TextInputType.text,
                  contentPadding: EdgeInsets.zero,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Text("cancel".tr)),
                      InkWell(
                          onTap: () {
                            Map<String, String> bodyParams = {
                              'id_user_app':
                              Preferences.getInt(Preferences.userId)
                                  .toString(),
                              'lat1': departureLatLong!.latitude.toString(),
                              'lng1': departureLatLong!.longitude.toString(),
                              'lat2': destinationLatLong!.latitude.toString(),
                              'lng2': destinationLatLong!.longitude.toString(),
                              'distance': controller.distance.value.toString(),
                              'distance_unit': Constant.distanceUnit.toString(),
                              'depart_name': departureController.text,
                              'destination_name': destinationController.text,
                              'fav_name': favouriteNameTextController.text,
                            };
                            controller
                                .setFavouriteRide(bodyParams)
                                .then((value) {
                              if (value['success'] == "Success") {
                                Get.back();
                              } else {
                                ShowToastDialog.showToast(value['error']);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text("Ok".tr),
                          )),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  _pendingPaymentDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Cab me"),
      content: Text(
          "You have pending payments. Please complete payment before book new trip."
              .tr),
      actions: [
        okButton,
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

  _paymentMethodDialog(
      BuildContext context,
      ) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Select Payment Method"),
                      Divider(
                        color: Colors.limeAccent,
                      ),
                      Visibility(
                        visible:
                        controller.paymentSettingModel.value.cash != null &&
                            controller.paymentSettingModel.value.cash!
                                .isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.cash.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.cash.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Cash",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = true.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId = controller
                                    .paymentSettingModel
                                    .value
                                    .cash!
                                    .idPaymentMethod
                                    .toString()
                                    .obs;
                                Get.back();
                              },
                              selected: controller.cash.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/cash.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Cash".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                        controller.paymentSettingModel.value.myWallet !=
                            null &&
                            controller.paymentSettingModel.value
                                .myWallet!.isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.wallet.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.wallet.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Wallet",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = true.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId = controller
                                    .paymentSettingModel
                                    .value
                                    .myWallet!
                                    .idPaymentMethod
                                    .toString()
                                    .obs;
                                Get.back();
                              },
                              selected: controller.wallet.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/icons/walltet_icons.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Wallet".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.strip !=
                            null &&
                            controller.paymentSettingModel.value.strip!
                                .isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.stripe.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.stripe.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Stripe",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = true.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId = controller
                                    .paymentSettingModel
                                    .value
                                    .strip!
                                    .idPaymentMethod
                                    .toString()
                                    .obs;
                                Get.back();
                              },
                              selected: controller.stripe.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/stripe.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Stripe".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                        controller.paymentSettingModel.value.payStack !=
                            null &&
                            controller.paymentSettingModel.value
                                .payStack!.isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.payStack.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.payStack.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayStack",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = true.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId = controller
                                    .paymentSettingModel
                                    .value
                                    .payStack!
                                    .idPaymentMethod
                                    .toString()
                                    .obs;
                                Get.back();
                              },
                              selected: controller.payStack.value,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/paystack.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayStack".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                        controller.paymentSettingModel.value.flutterWave !=
                            null &&
                            controller.paymentSettingModel.value
                                .flutterWave!.isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.flutterWave.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.flutterWave.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "FlutterWave",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = true.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value = controller
                                    .paymentSettingModel
                                    .value
                                    .flutterWave!
                                    .idPaymentMethod
                                    .toString();
                                Get.back();
                              },
                              selected: controller.flutterWave.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/flutterwave.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("FlutterWave".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                        controller.paymentSettingModel.value.razorpay !=
                            null &&
                            controller.paymentSettingModel.value
                                .razorpay!.isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.razorPay.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.razorPay.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "RazorPay",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = true.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value = controller
                                    .paymentSettingModel
                                    .value
                                    .razorpay!
                                    .idPaymentMethod
                                    .toString();
                                Get.back();
                              },
                              selected: controller.razorPay.value,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Image.asset(
                                                "assets/images/razorpay_@3x.png")),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("RazorPay".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payFast !=
                            null &&
                            controller.paymentSettingModel.value.payFast!
                                .isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.payFast.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.payFast.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayFast",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = true.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value = controller
                                    .paymentSettingModel
                                    .value
                                    .payFast!
                                    .idPaymentMethod
                                    .toString();
                                Get.back();
                              },
                              selected: controller.payFast.value,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/payfast.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Pay Fast".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.paytm !=
                            null &&
                            controller.paymentSettingModel.value.paytm!
                                .isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.payTm.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.payTm.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayTm",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = true.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value = controller
                                    .paymentSettingModel
                                    .value
                                    .paytm!
                                    .idPaymentMethod
                                    .toString();
                                Get.back();
                              },
                              selected: controller.payTm.value,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 3.0),
                                              child: Image.asset(
                                                "assets/images/paytm_@3x.png",
                                              ),
                                            )),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Paytm".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                        controller.paymentSettingModel.value.mercadopago !=
                            null &&
                            controller.paymentSettingModel.value
                                .mercadopago!.isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.mercadoPago.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.mercadoPago.value
                                          ? ConstantColors.primary
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "MercadoPago",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                // controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = true.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value = controller
                                    .paymentSettingModel
                                    .value
                                    .mercadopago!
                                    .idPaymentMethod
                                    .toString();
                                Get.back();
                              },
                              selected: controller.mercadoPago.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/mercadopago.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Mercado Pago".tr),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payPal !=
                            null &&
                            controller.paymentSettingModel.value.payPal!
                                .isEnabled ==
                                "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          // child: Card(
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   elevation: controller.paypal.value ? 0 : 2,
                          //   child: RadioListTile(
                          //     shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8),
                          //         side: BorderSide(
                          //             color: controller.paypal.value
                          //                 ? ConstantColors.primary
                          //                 : Colors.transparent)),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //       horizontal: 6,
                          //     ),
                          //     controlAffinity: ListTileControlAffinity.trailing,
                          //     value: "PayPal",
                          //     groupValue: controller.paymentMethodType.value,
                          //     onChanged: (String? value) {
                          //       controller.stripe = false.obs;
                          //       controller.wallet = false.obs;
                          //       controller.cash = false.obs;
                          //       controller.razorPay = false.obs;
                          //       controller.payTm = false.obs;
                          //       controller.paypal = true.obs;
                          //       controller.payStack = false.obs;
                          //       controller.flutterWave = false.obs;
                          //       controller.mercadoPago = false.obs;
                          //       controller.payFast = false.obs;
                          //       controller.paymentMethodType.value = value!;
                          //       controller.paymentMethodId.value = controller
                          //           .paymentSettingModel
                          //           .value
                          //           .payPal!
                          //           .idPaymentMethod
                          //           .toString();
                          //       Get.back();
                          //     },
                          //     selected: controller.paypal.value,
                          //     title: Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       children: [
                          //         Container(
                          //             decoration: BoxDecoration(
                          //               color: Colors.blueGrey.shade50,
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(
                          //                   vertical: 3.0),
                          //               child: SizedBox(
                          //                   width: 80,
                          //                   height: 35,
                          //                   child: Padding(
                          //                     padding:
                          //                     const EdgeInsets.symmetric(
                          //                         vertical: 3.0),
                          //                     child: Image.asset(
                          //                         "assets/images/paypal_@3x.png"),
                          //                   )),
                          //             )),
                          //         const SizedBox(
                          //           width: 20,
                          //         ),
                          //         Text("PayPal".tr),
                          //       ],
                          //     ),
                          //     //toggleable: true,
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  // _paymentMethodDialog(BuildContext context, List<PaymentMethodData>? data) {
  //   return showModalBottomSheet(
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(15), topLeft: Radius.circular(15))),
  //       context: context,
  //       isScrollControlled: true,
  //       isDismissible: false,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return Padding(
  //             padding:
  //                 const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text("Select Payment Method1"),
  //                 Divider(
  //                   color: Colors.grey.shade700,
  //                 ),
  //                 ListView.builder(
  //                   shrinkWrap: true,
  //                   itemCount: data!.length,
  //                   itemBuilder: (context, index) {
  //                     return InkWell(
  //                       onTap: () {
  //                         controller.paymentMethodData = data[index];
  //                         controller.paymentMethodType.value =
  //                             data[index].libelle.toString();
  //                         Get.back();
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                   vertical: 8, horizontal: 5),
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.blueGrey.shade50,
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       vertical: 4.0),
  //                                   child: SizedBox(
  //                                     width: 80,
  //                                     height: 35,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                           vertical: 6.0),
  //                                       child: CachedNetworkImage(
  //                                         imageUrl: data[index].image!,
  //                                         placeholder: (context, url) =>
  //                                             const CircularProgressIndicator(),
  //                                         errorWidget: (context, url, error) =>
  //                                             const Icon(Icons.error),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                             Padding(
  //                               padding: const EdgeInsets.only(left: 10),
  //                               child: Text(
  //                                 data[index].libelle.toString(),
  //                                 style: const TextStyle(color: Colors.black),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 )
  //               ],
  //             ),
  //           );
  //         });
  //       });
  // }

  buildDetails({title, value, Color txtColor = Colors.black}) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.9,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: txtColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// class ColorizeAnimatedTextKit {
// }

class Oneway {
}


