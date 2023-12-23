// ignore_for_file: must_be_immutable

import 'package:Urride/constant/constant.dart';
import 'package:Urride/controller/dash_board_controller.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DashBoard extends StatelessWidget {
  DashBoard({Key? key}) : super(key: key);

  DateTime backPress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: ConstantColors.primary,
    ));
    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              final timeGap = DateTime.now().difference(backPress);
              final cantExit = timeGap >= const Duration(seconds: 2);
              backPress = DateTime.now();
              if (cantExit) {
                const snack = SnackBar(
                  content: Text(
                    'Press Back button again to Exit',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
                return false; // false will do nothing when back press
              } else {
                return true; // true will exit the app
              }
            },
            child: Scaffold(
              appBar: controller.selectedDrawerIndex.value != 0 && controller.selectedDrawerIndex.value != 15
                  ? AppBar(
                      backgroundColor: controller.selectedDrawerIndex.value == 7 ? Colors.limeAccent : Colors.limeAccent,
                      elevation: 0,
                      centerTitle: true,
                      title: controller.selectedDrawerIndex.value != 0 && controller.selectedDrawerIndex.value != 15
                          ? Text(
                              controller.drawerItems[controller.selectedDrawerIndex.value].title.tr,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            )
                          : const Text(""),
                      leading: Builder(builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: ConstantColors.primary.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/icons/ic_side_menu.png",
                                  color: Colors.black,
                                )),
                          ),
                        );
                      }),
                    )
                  : null,
              drawer: buildAppDrawer(context, controller),
              body: controller.getDrawerItemWidget(controller.selectedDrawerIndex.value),
            ),
          ),
        );
      },
    );
  }

  buildAppDrawer(BuildContext context, DashBoardController controller) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < controller.drawerItems.length; i++) {
      var d = controller.drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(d.title.tr),
        selected: i == controller.selectedDrawerIndex.value,
        onTap: () => controller.onSelectItem(i),
      ));
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          controller.userModel == null
              ? Center(
                  child: CircularProgressIndicator(color: Colors.limeAccent),
                )
              : UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  currentAccountPicture: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0040096),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: controller.userModel!.data!.photoPath.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  accountName: Text(
                    "${controller.userModel!.data!.prenom} ${controller.userModel!.data!.nom}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  accountEmail: Text(controller.userModel!.data!.email.toString(), style: const TextStyle(color: Colors.white)),
                ),
          Column(children: drawerOptions),
          Text(
            'V : ${Constant.appVersion}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}
