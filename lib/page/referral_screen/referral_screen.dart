import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/referral_controller.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<ReferralController>(
          init: ReferralController(),
          builder: (referralController) {
            return referralController.isLoading.value == true
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/background_image_referral.png'), fit: BoxFit.cover)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/earn_icon.png',
                                width: 160,
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Text(
                                "Refer your friends and".tr,
                                style: const TextStyle(color: Colors.white, letterSpacing: 1.5),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${"Earn".tr}${Constant().amountShow(amount: referralController.referralAmount.toString())} ${"each".tr}",
                                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Invite Friend & Businesses".tr,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, letterSpacing: 2.0, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${"Invite your friend to sign up using your code and you’ll get".tr} ${Constant.currency}${double.parse(referralController.referralAmount.toString()).toStringAsFixed(int.parse(Constant.decimal.toString()))} ${"after successfully ride complete.".tr}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0XFF666666), fontWeight: FontWeight.w500, letterSpacing: 2.0),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: () {
                              FlutterClipboard.copy(
                                referralController.referralCode.toString(),
                              ).then((value) {
                                SnackBar snackBar = SnackBar(
                                  content: Text(
                                    "Coupon code copied".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              });
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(2),
                              padding: const EdgeInsets.all(15),
                              color: ConstantColors.couponDashColor,
                              strokeWidth: 2,
                              dashPattern: const [5],
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Container(
                                    height: 25,
                                    width: MediaQuery.of(context).size.width * 0.30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: ConstantColors.couponBgColor,
                                    ),
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      referralController.referralCode.toString(),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.black),
                                    )),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 60),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.limeAccent,
                                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: BorderSide(
                                      color: ConstantColors.primary,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  await ShowToastDialog.showLoader("Please wait".tr);
                                  share(referralController);
                                },
                                child: Text(
                                  "Refer Friend".tr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
          }),
    );
  }

  Future<void> share(ReferralController referralController) async {
    ShowToastDialog.closeLoader();
    await FlutterShare.share(
      title: 'Urride',
      text:
          'Hey there, thanks for choosing Urride. Hope you love our product. If you do, share it with your friends using code ${referralController.referralCode.toString()} and get ${Constant().amountShow(amount: referralController.referralAmount.toString())} when ride completed',
    );
  }
}
