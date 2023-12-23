// ignore_for_file: library_prefixes, must_be_immutable, unused_local_variable, constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:Urride/constant/constant.dart';
import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/controller/wallet_controller.dart';
import 'package:Urride/model/get_payment_txt_token_model.dart';
import 'package:Urride/model/payStackURLModel.dart';
import 'package:Urride/model/razorpay_gen_orderid_model.dart';
import 'package:Urride/model/stripe_failed_model.dart';
import 'package:Urride/model/transaction_model.dart';
import 'package:Urride/page/wallet/payStackScreen.dart';
import 'package:Urride/service/api.dart';
import 'package:Urride/themes/constant_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:flutter_paypal_native/flutter_paypal_native.dart';
// import 'package:flutter_paypal_native/models/custom/currency_code.dart';
// import 'package:flutter_paypal_native/models/custom/environment.dart';
// import 'package:flutter_paypal_native/models/custom/order_callback.dart';
// import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
// import 'package:flutter_paypal_native/models/custom/user_action.dart';
// import 'package:flutter_paypal_native/str_helper.dart';
import '../../model/payment_setting_model.dart';
import '../../utils/Preferences.dart';
import 'MercadoPagoScreen.dart';
import 'PayFastScreen.dart';
import 'paystack_url_genrater.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({Key? key}) : super(key: key);

  final walletController = Get.put(WalletController());

  final Razorpay razorPayController = Razorpay();

  static final GlobalKey<FormState> _walletFormKey = GlobalKey<FormState>();
  static final amountController = TextEditingController();

  Future<void> _refreshAPI() async {
    walletController.getAmount();
    walletController.getTransaction();
    amountController.clear();
    // initPayPal();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<WalletController>(
      init: WalletController(),
      initState: (state) {
        _refreshAPI();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          body: Column(
            children: [
              Container(

                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),

                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Balance",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 20.0),
                                child: Text(
                                  Constant().amountShow(
                                      amount: walletController.walletAmount
                                          .toString()),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 28.0, right: 15),
                          child: GestureDetector(
                            onTap: () {
                              addToWalletAmount(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.limeAccent,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 10),
                                child: Text(
                                  "TOPUP WALLET",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.isLoading.value
                    ? Constant.loader()
                    : controller.walletList.isEmpty
                        ? Constant.emptyView(
                            context, "Transaction not found.", false)
                        : RefreshIndicator(
                            onRefresh: () => _refreshAPI(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: ListView.builder(
                                  itemCount: controller.walletList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return buildTransactionCard(
                                        context, controller.walletList[index]);
                                  }),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTransactionCard(BuildContext context, TransactionData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () {
            showTransactionDetails(context, data);
            // _paymentHistoryDialog(data);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/walltet_history.png",
                height: 62,
                width: 62,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.creer.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          data.deductionType.toString() == "1"
                              ? "Wallet Topup"
                              : "Payment for Trip",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.deductionType.toString() == "1"
                        ? "+${Constant().amountShow(amount: data.amount.toString())}"
                        : "(${"-${Constant().amountShow(amount: data.amount.toString())}"})",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: data.deductionType.toString() == "1"
                            ? Colors.green
                            : Colors.red,
                        fontSize: 16),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  showTransactionDetails(BuildContext context, TransactionData data) {
    final size = MediaQuery.of(context).size;
    int decimal = 0;
    return showModalBottomSheet(
        elevation: 5,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: size.height * 0.80,
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 25.0),
                      child: Text(
                        "Transaction Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Transaction ID",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Opacity(
                                    opacity: 0.8,
                                    child: Text(
                                      data.id.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 30),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    "assets/images/walltet_history.png",
                                    height: 62,
                                    width: 62,
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.48,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.creer.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          data.deductionType.toString() == "1"
                                              ? "Wallet Topup"
                                              : "Payment for Trip",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      data.deductionType.toString() == "1"
                                          ? "+${Constant().amountShow(amount: data.amount.toString())}"
                                          : "(${"-${Constant().amountShow(amount: data.amount.toString())}"})",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            data.deductionType.toString() == "1"
                                                ? Colors.green
                                                : Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25.0, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Payment Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          "Pay Via",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        data.paymentMethod!.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: ConstantColors.primary,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Date in UTC Format",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          data.creer.toString().toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  // _paymentHistoryDialog(TransactionData data) async {
  //   return Get.defaultDialog(
  //       title: 'Tranction Details',
  //       content: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               children: [
  //                 const Text(
  //                   "Payment Method :- ",
  //                   style: TextStyle(
  //                       fontWeight: FontWeight.w500, color: Colors.grey),
  //                 ),
  //                 Text(
  //                   data.paymentMethod.toString(),
  //                   style: const TextStyle(
  //                       fontWeight: FontWeight.w900, color: Colors.black),
  //                 ),
  //               ],
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 8.0),
  //               child: Row(
  //                 children: [
  //                   const Text(
  //                     "Amount :- ",
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.w500, color: Colors.grey),
  //                   ),
  //                   Text(
  //                     "\$${data.amount.toString()}",
  //                     style: const TextStyle(
  //                         fontWeight: FontWeight.w900, color: Colors.black),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 8.0),
  //               child: Row(
  //                 children: [
  //                   const Text(
  //                     "Deduction type :- ",
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.w500, color: Colors.grey),
  //                   ),
  //                   Text(
  //                     data.deductionType == 0 ? "Debit" : "Credit",
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.w900,
  //                         color: data.deductionType == 0
  //                             ? Colors.red
  //                             : Colors.green),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       radius: 10.0);
  // }

  addToWalletAmount(BuildContext context) {
    return showModalBottomSheet(
        elevation: 5,
        useRootNavigator: true,
        isScrollControlled: true,
        // useSafeArea: true,
        // anchorPoint: Offset(900.0, 1000.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        backgroundColor: ConstantColors.background,
        builder: (context) {
          return GetX<WalletController>(
              init: WalletController(),
              initState: (controller) {
                razorPayController.on(
                    Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
                razorPayController.on(
                    Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
                razorPayController.on(
                    Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
              },
              builder: (controller) {
                return SizedBox(
                  height: Get.height / 1.2,
                  child: SingleChildScrollView(
                    // physics: const BouncingScrollPhysics(),
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Topup Wallet".tr,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: Text("Add Topup Amount".tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                          Form(
                            key: _walletFormKey,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10),
                              child: TextFormField(
                                validator: (String? value) {
                                  if (value!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return "required".tr;
                                  }
                                },
                                keyboardType: TextInputType.number,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: amountController,
                                maxLength: 13,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  counterText: "",
                                  hintText: "enter_amount".tr,
                                  contentPadding:
                                      const EdgeInsets.only(top: 10, left: 0),
                                  prefix: Text(Constant.currency.toString()),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Select Payment Option".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Visibility(
                            visible: walletController.paymentSettingModel.value
                                        .strip!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    walletController.stripe.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: walletController.stripe.value
                                              ? ConstantColors.primary
                                              : Colors.transparent)),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "Stripe",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = true.obs;
                                    walletController.razorPay = false.obs;
                                    walletController.payTm = false.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = false.obs;
                                    walletController.flutterWave = false.obs;
                                    walletController.mercadoPago = false.obs;
                                    walletController.payFast = false.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.stripe.value,
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 10),
                                            child: SizedBox(
                                              width: 80,
                                              height: 35,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                            visible: walletController.paymentSettingModel.value
                                        .payStack!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    walletController.payStack.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: walletController.payStack.value
                                              ? ConstantColors.primary
                                              : Colors.transparent)),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "PayStack",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = false.obs;
                                    walletController.razorPay = false.obs;
                                    walletController.payTm = false.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = true.obs;
                                    walletController.flutterWave = false.obs;
                                    walletController.mercadoPago = false.obs;
                                    walletController.payFast = false.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.payStack.value,
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 10),
                                            child: SizedBox(
                                              width: 80,
                                              height: 35,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                      const Text("PayStack"),
                                    ],
                                  ),
                                  //toggleable: true,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: walletController.paymentSettingModel.value
                                        .flutterWave!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    walletController.flutterWave.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color:
                                              walletController.flutterWave.value
                                                  ? ConstantColors.primary
                                                  : Colors.transparent)),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "FlutterWave",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = false.obs;
                                    walletController.razorPay = false.obs;
                                    walletController.payTm = false.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = false.obs;
                                    walletController.flutterWave = true.obs;
                                    walletController.mercadoPago = false.obs;
                                    walletController.payFast = false.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.flutterWave.value,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 10),
                                            child: SizedBox(
                                              width: 80,
                                              height: 35,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                      const Text("FlutterWave"),
                                    ],
                                  ),
                                  //toggleable: true,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: walletController.paymentSettingModel.value
                                        .razorpay!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    walletController.razorPay.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: walletController.razorPay.value
                                              ? ConstantColors.primary
                                              : Colors.transparent)),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "RazorPay",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = false.obs;
                                    walletController.razorPay = true.obs;
                                    walletController.payTm = false.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = false.obs;
                                    walletController.flutterWave = false.obs;
                                    walletController.mercadoPago = false.obs;
                                    walletController.payFast = false.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.razorPay.value,
                                  //selectedRadioTile == "strip" ? true : false,
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3.0, horizontal: 10),
                                            child: SizedBox(
                                                width: 80,
                                                height: 35,
                                                child: Image.asset(
                                                    "assets/images/razorpay_@3x.png")),
                                          )),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      const Text("RazorPay"),
                                    ],
                                  ),
                                  //toggleable: true,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: walletController.paymentSettingModel.value
                                        .payFast!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    walletController.payFast.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: walletController.payFast.value
                                              ? ConstantColors.primary
                                              : Colors.transparent)),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "PayFast",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = false.obs;
                                    walletController.razorPay = false.obs;
                                    walletController.payTm = false.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = false.obs;
                                    walletController.flutterWave = false.obs;
                                    walletController.mercadoPago = false.obs;
                                    walletController.payFast = true.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.payFast.value,
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 10),
                                            child: SizedBox(
                                              width: 80,
                                              height: 35,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                      const Text("Pay Fast"),
                                    ],
                                  ),
                                  //toggleable: true,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: walletController.paymentSettingModel.value
                                        .paytm!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: walletController.payTm.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: walletController.payTm.value
                                              ? ConstantColors.primary
                                              : Colors.transparent)),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "PayTm",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = false.obs;
                                    walletController.razorPay = false.obs;
                                    walletController.payTm = true.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = false.obs;
                                    walletController.flutterWave = false.obs;
                                    walletController.mercadoPago = false.obs;
                                    walletController.payFast = false.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.payTm.value,
                                  //selectedRadioTile == "strip" ? true : false,
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3.0, horizontal: 10),
                                            child: SizedBox(
                                                width: 80,
                                                height: 35,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3.0),
                                                  child: Image.asset(
                                                    "assets/images/paytm_@3x.png",
                                                  ),
                                                )),
                                          )),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      const Text("Paytm"),
                                    ],
                                  ),
                                  //toggleable: true,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: walletController.paymentSettingModel.value
                                        .mercadopago!.isEnabled ==
                                    "true"
                                ? true
                                : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    walletController.mercadoPago.value ? 0 : 2,
                                child: RadioListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color:
                                              walletController.mercadoPago.value
                                                  ? ConstantColors.primary
                                                  : Colors.transparent)),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: "MercadoPago",
                                  groupValue:
                                      walletController.selectedRadioTile!.value,
                                  onChanged: (String? value) {
                                    walletController.stripe = false.obs;
                                    walletController.razorPay = false.obs;
                                    walletController.payTm = false.obs;
                                    // walletController.paypal = false.obs;
                                    walletController.payStack = false.obs;
                                    walletController.flutterWave = false.obs;
                                    walletController.mercadoPago = true.obs;
                                    walletController.payFast = false.obs;
                                    walletController.selectedRadioTile!.value =
                                        value!;
                                  },
                                  selected: walletController.mercadoPago.value,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 10),
                                            child: SizedBox(
                                              width: 80,
                                              height: 35,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                      const Text("Mercado Pago"),
                                    ],
                                  ),
                                  //toggleable: true,
                                ),
                              ),
                            ),
                          ),
                          // Visibility(
                          //   visible: walletController.paymentSettingModel.value
                          //               .payPal!.isEnabled ==
                          //           "true"
                          //       ? true
                          //       : false,
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 3.0, horizontal: 20),
                          //     child: Card(
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8),
                          //       ),
                          //       elevation:
                          //           walletController.paypal.value ? 0 : 2,
                          //       child: RadioListTile(
                          //         shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(8),
                          //             side: BorderSide(
                          //                 color: walletController.paypal.value
                          //                     ? ConstantColors.primary
                          //                     : Colors.transparent)),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //           horizontal: 6,
                          //         ),
                          //         controlAffinity:
                          //             ListTileControlAffinity.trailing,
                          //         value: "PayPal",
                          //         groupValue:
                          //             walletController.selectedRadioTile!.value,
                          //         onChanged: (String? value) {
                          //           walletController.stripe = false.obs;
                          //           walletController.razorPay = false.obs;
                          //           walletController.payTm = false.obs;
                          //           walletController.paypal = true.obs;
                          //           walletController.payStack = false.obs;
                          //           walletController.flutterWave = false.obs;
                          //           walletController.mercadoPago = false.obs;
                          //           walletController.payFast = false.obs;
                          //           walletController.selectedRadioTile!.value =
                          //               value!;
                          //         },
                          //         selected: walletController.paypal.value,
                          //         title: Row(
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           children: [
                          //             Container(
                          //                 decoration: BoxDecoration(
                          //                   color: Colors.blueGrey.shade50,
                          //                   borderRadius:
                          //                       BorderRadius.circular(8),
                          //                 ),
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.symmetric(
                          //                       vertical: 3.0, horizontal: 10),
                          //                   child: SizedBox(
                          //                       width: 80,
                          //                       height: 35,
                          //                       child: Padding(
                          //                         padding: const EdgeInsets
                          //                             .symmetric(vertical: 3.0),
                          //                         child: Image.asset(
                          //                             "assets/images/paypal_@3x.png"),
                          //                       )),
                          //                 )),
                          //             const SizedBox(
                          //               width: 20,
                          //             ),
                          //             const Text("PayPal"),
                          //           ],
                          //         ),
                          //         //toggleable: true,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // controller.isLoading.value
                          //     ? Constant.loader()
                          //     : controller.paymentMethodList.isEmpty
                          //         ? Constant.emptyView(context, "Payment method not found please contact administrator", false)
                          //         : ListView.builder(
                          //             itemCount: controller.paymentMethodList.length,
                          //             shrinkWrap: true,
                          //             itemBuilder: (context, index) {
                          //               return Obx(
                          //                 () => controller.paymentMethodList[index].libelle != "Cash" &&
                          //                         controller.paymentMethodList[index].libelle != "My Wallet"
                          //                     ? Visibility(
                          //                         visible: controller.paymentMethodList[index].statut == "yes",
                          //                         child: Padding(
                          //                           padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 15),
                          //                           child: Card(
                          //                               shape: RoundedRectangleBorder(
                          //                                 borderRadius: BorderRadius.circular(8),
                          //                               ),
                          //                               elevation: controller.selectedRadioTile!.value ==
                          //                                       controller.paymentMethodList[index].libelle.toString()
                          //                                   ? 0
                          //                                   : 2,
                          //                               child: RadioListTile(
                          //                                 shape: RoundedRectangleBorder(
                          //                                     borderRadius: BorderRadius.circular(8),
                          //                                     side: BorderSide(
                          //                                         color: controller.selectedRadioTile!.value ==
                          //                                                 controller.paymentMethodList[index].libelle.toString()
                          //                                             ? ConstantColors.primary
                          //                                             : Colors.transparent)),
                          //                                 controlAffinity: ListTileControlAffinity.trailing,
                          //                                 value: controller.paymentMethodList[index].libelle.toString(),
                          //                                 groupValue: controller.selectedRadioTile!.value,
                          //                                 onChanged: (newValue) {
                          //                                   controller.selectedRadioTile!.value = newValue.toString();
                          //                                 },
                          //                                 title: Row(
                          //                                   children: [
                          //                                     Padding(
                          //                                       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          //                                       child: Container(
                          //                                         decoration: BoxDecoration(
                          //                                           color: Colors.grey.withOpacity(0.10),
                          //                                           borderRadius: BorderRadius.circular(8),
                          //                                         ),
                          //                                         child: Padding(
                          //                                           padding:
                          //                                               const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                          //                                           child: SizedBox(
                          //                                             width: 80,
                          //                                             height: 35,
                          //                                             child: Padding(
                          //                                               padding: const EdgeInsets.symmetric(vertical: 6.0),
                          //                                               child: CachedNetworkImage(
                          //                                                 imageUrl: controller.paymentMethodList[index].image!,
                          //                                                 placeholder: (context, url) => Constant.loader(),
                          //                                                 errorWidget: (context, url, error) =>
                          //                                                     const Icon(Icons.error),
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                     Padding(
                          //                                       padding: const EdgeInsets.only(left: 10),
                          //                                       child: Text(
                          //                                         controller.paymentMethodList[index].libelle.toString(),
                          //                                         style: const TextStyle(color: Colors.black),
                          //                                       ),
                          //                                     ),
                          //                                   ],
                          //                                 ),
                          //                               )),
                          //                         ),
                          //                       )
                          //                     : Container(),
                          //               );
                          //             }),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 15),
                            child: GestureDetector(
                              onTap: () async {
                                if (_walletFormKey.currentState!.validate()) {
                                  Get.back();
                                  showLoadingAlert(context);
                                  if (walletController
                                          .selectedRadioTile!.value ==
                                      "Stripe") {
                                    stripeMakePayment(
                                        amount: amountController.text);
                                  } else if (walletController
                                          .selectedRadioTile!.value ==
                                      "RazorPay") {
                                    startRazorpayPayment();
                                  } else if (walletController
                                          .selectedRadioTile!.value ==
                                      "PayTm") {
                                    getPaytmCheckSum(context,
                                        amount: double.parse(
                                            amountController.text));
                                  }  else if (walletController
                                          .selectedRadioTile!.value ==
                                      "PayStack") {
                                    payStackPayment(context);
                                  } else if (walletController
                                          .selectedRadioTile!.value ==
                                      "FlutterWave") {
                                    flutterWaveInitiatePayment(context);
                                  } else if (walletController
                                          .selectedRadioTile!.value ==
                                      "PayFast") {
                                    payFastPayment(context);
                                  } else if (walletController
                                          .selectedRadioTile!.value ==
                                      "MercadoPago") {
                                    mercadoPagoMakePayment(context);
                                  } else {
                                    Get.back();
                                    ShowToastDialog.showToast(
                                        "Please select payment method");
                                  }
                                }
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.limeAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                    child: Text(
                                  "CONTINUE",
                                  style: TextStyle(color: Colors.black),
                                )),
                              ),
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

  /// Paytm Payment Gateway
  bool isStaging = true;
  bool enableAssist = true;
  String result = "";

  getPaytmCheckSum(
    context, {
    required double amount,
  }) async {
    String orderId = DateTime.now().microsecondsSinceEpoch.toString();
    String getChecksum = "${API.baseUrl}payments/getpaytmchecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {
          'apikey': API.apiKey,
          'accesstoken': Preferences.getString(Preferences.accesstoken),
        },
        body: {
          "mid": walletController.paymentSettingModel.value.paytm!.merchantId,
          "order_id": orderId,
          "key_secret":
              walletController.paymentSettingModel.value.paytm!.merchantKey,
        });

    final data = jsonDecode(response.body);

    await walletController
        .verifyCheckSum(
            checkSum: data["code"], amount: amount, orderId: orderId)
        .then((value) {
      initiatePayment(context, amount: amount, orderId: orderId).then((value) {
        GetPaymentTxtTokenModel result = value;
        String callback = "";
        if (walletController
                .paymentSettingModel.value.paytm!.isSandboxEnabled ==
            "true") {
          callback =
              "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback =
              "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        _startTransaction(
          context,
          txnTokenBy: result.body.txnToken,
          orderId: orderId,
          amount: amount,
        );
      });
    });
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(BuildContext context,
      {required double amount, required orderId}) async {
    String initiateURL = "${API.baseUrl}payments/initiatepaytmpayment";
    String callback = "";
    if (walletController.paymentSettingModel.value.paytm!.isSandboxEnabled ==
        "true") {
      callback =
          "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback =
          "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(
        Uri.parse(
          initiateURL,
        ),
        headers: {
          'apikey': API.apiKey,
          'accesstoken': Preferences.getString(Preferences.accesstoken),
        },
        body: {
          "mid": walletController.paymentSettingModel.value.paytm!.merchantId,
          "order_id": orderId,
          "key_secret":
              walletController.paymentSettingModel.value.paytm!.merchantKey,
          "amount": amount.toString(),
          "currency": "INR",
          "callback_url": callback,
          "custId": "30",
          "issandbox": walletController
                      .paymentSettingModel.value.paytm!.isSandboxEnabled ==
                  "true"
              ? "1"
              : "2",
        });
    final data = jsonDecode(response.body);

    if (data["body"]["txnToken"] == null ||
        data["body"]["txnToken"].toString().isEmpty) {
      Get.back();
      showSnackBarAlert(
        message: "Something went wrong, please contact admin.",
        color: Colors.red.shade400,
      );
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  Future<void> _startTransaction(
    context, {
    required String txnTokenBy,
    required orderId,
    required double amount,
  }) async {
    try {
      var response = AllInOneSdk.startTransaction(
        walletController.paymentSettingModel.value.paytm!.merchantId.toString(),
        orderId,
        amount.toString(),
        txnTokenBy,
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          walletController.setAmount(amountController.text).then((value) {
            if (value != null) {
              Get.back();
              showSnackBarAlert(
                message: "Payment Successful!!",
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          Get.back();

          result = "${onError.message} \n  ${onError.code}";
          showSnackBarAlert(
            message: "Something went wrong, please contact admin.",
            color: Colors.red.shade400,
          );
        } else {
          result = onError.toString();
          Get.back();
          showSnackBarAlert(
            message: "Something went wrong, please contact admin.",
            color: Colors.red.shade400,
          );
        }
      });
    } catch (err) {
      result = err.toString();
      Get.back();
      showSnackBarAlert(
        message: "Something went wrong, please contact admin.",
        color: Colors.red.shade400,
      );
    }
  }

  ///paypal

  // final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  // void initPayPal() async {
  //  //set debugMode for error logging
  //   FlutterPaypalNative.isDebugMode =
  //       walletController.paymentSettingModel.value.payPal!.isLive.toString() ==
  //               "false"
  //           ? true
  //           : false;
  //
  //   //initiate payPal plugin
  //   await _flutterPaypalNativePlugin.init(
  //     //your app id !!! No Underscore!!! see readme.md for help
  //     returnUrl: "com.digigrow.urride://paypalpay",
  //     //client id from developer dashboard
  //     clientID:
  //         walletController.paymentSettingModel.value.payPal!.appId!,
  //     //sandbox, staging, live etc
  //     payPalEnvironment: walletController
  //                 .paymentSettingModel.value.payPal!.isLive
  //                 .toString() ==
  //             "true"
  //         ? FPayPalEnvironment.live
  //         : FPayPalEnvironment.sandbox,
  //     //what currency do you plan to use? default is US dollars
  //     currencyCode: FPayPalCurrencyCode.usd,
  //     //action paynow?
  //     action: FPayPalUserAction.payNow,
  //   );
  //
  // }

  // paypalPaymentSheet(String amount) {
  //   //add 1 item to cart. Max is 4!
  //   if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
  //     _flutterPaypalNativePlugin.addPurchaseUnit(
  //       FPayPalPurchaseUnit(
  //         // random prices
  //         amount: double.parse(amount),
  //
  //         ///please use your own algorithm for referenceId. Maybe ProductID?
  //         referenceId: FPayPalStrHelper.getRandomString(16),
  //       ),
  //     );
  //   }
  //   // initPayPal();
  //   _flutterPaypalNativePlugin.makeOrder(
  //     action: FPayPalUserAction.payNow,
  //   );
  //
  //   //call backs for payment
  //   _flutterPaypalNativePlugin.setPayPalOrderCallback(
  //     callback: FPayPalOrderCallback(
  //       onCancel: () {
  //         //user canceled the payment
  //         Get.back();
  //         ShowToastDialog.showToast("Payment canceled".tr);
  //       },
  //       onSuccess: (data) {
  //         //successfully paid
  //         //remove all items from queue
  //         // _flutterPaypalNativePlugin.removeAllPurchaseItems();
  //
  //         walletController.setAmount(amountController.text).then((value) {
  //           if (value != null) {
  //             showSnackBarAlert(
  //               message: "Payment Successful!!".tr,
  //               color: Colors.green.shade400,
  //             );
  //             _refreshAPI();
  //           }
  //         });
  //              Get.back();
  //         ShowToastDialog.showToast("Payment Successful!!".tr);
  //         // transactionAPI();
  //         // walletTopUp();
  //       },
  //       onError: (data) {
  //         //an error occured
  //         Get.back();
  //         ShowToastDialog.showToast("error: ${data.reason}");
  //       },
  //       onShippingChange: (data) {
  //         //the user updated the shipping address
  //            Get.back();
  //         ShowToastDialog.showToast(
  //             "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
  //       },
  //     ),
  //   );
  // }
  // _paypalPayment() async {
  //   PayPalClientTokenGen.paypalClientToken(
  //           walletController.paymentSettingModel.value.payPal)
  //       .then((value) async {
  //     final String tokenizationKey = walletController
  //         .paymentSettingModel.value.payPal!.tokenizationKey
  //         .toString();

  //     var request = BraintreePayPalRequest(
  //         amount: amountController.text,
  //         currencyCode: "USD",
  //         billingAgreementDescription: "djsghxghf",
  //         displayName: 'Cab company');
  //     BraintreePaymentMethodNonce? resultData;
  //     try {
  //       resultData =
  //           await Braintree.requestPaypalNonce(tokenizationKey, request);
  //     } on Exception catch (ex) {
  //       showSnackBarAlert(
  //         message: "Something went wrong, please contact admin. $ex",
  //         color: Colors.red.shade400,
  //       );
  //     }

  //     if (resultData?.nonce != null) {
  //       PayPalClientTokenGen.paypalSettleAmount(
  //         payPal: walletController.paymentSettingModel.value.payPal,
  //         nonceFromTheClient: resultData?.nonce,
  //         amount: amountController.text,
  //         deviceDataFromTheClient: resultData?.typeLabel,
  //       ).then((value) {
  //         if (value['success'] == "true" || value['success'] == true) {
  //           if (value['data']['success'] == "true" ||
  //               value['data']['success'] == true) {
  //             payPalSettel.PayPalClientSettleModel settleResult =
  //                 payPalSettel.PayPalClientSettleModel.fromJson(value);
  //             if (settleResult.data.success) {
  //               Get.back();

  //               Get.back();
  //               walletController.setAmount(amountController.text).then((value) {
  //                 if (value != null) {
  //                   showSnackBarAlert(
  //                     message: "Payment Successful!!",
  //                     color: Colors.green.shade400,
  //                   );
  //                   _refreshAPI();
  //                 }
  //               });
  //             }
  //           } else {
  //             payPalCurrModel.PayPalCurrencyCodeErrorModel settleResult =
  //                 payPalCurrModel.PayPalCurrencyCodeErrorModel.fromJson(value);
  //             Get.back();
  //             showSnackBarAlert(
  //               message: "Status : ${settleResult.data.message}",
  //               color: Colors.red.shade400,
  //             );
  //           }
  //         } else {
  //           PayPalErrorSettleModel settleResult =
  //               PayPalErrorSettleModel.fromJson(value);
  //           Get.back();
  //           showSnackBarAlert(
  //             message: "Status : ${settleResult.data.message}",
  //             color: Colors.red.shade400,
  //           );
  //         }
  //       });
  //     } else {
  //       Get.back();
  //       showSnackBarAlert(
  //         message: "Status : Payment Incomplete!!",
  //         color: Colors.red.shade400,
  //       );
  //     }
  //   });
  // }

  /// RazorPay Payment Gateway
  startRazorpayPayment() {
    try {
      walletController
          .createOrderRazorPay(
              amount: double.parse(amountController.text).round())
          .then((value) {
        if (value != null) {
          CreateRazorPayOrderModel result = value;
          openCheckout(
            amount: amountController.text,
            orderId: result.id,
          );
        } else {
          Get.back();
          showSnackBarAlert(
            message: "Something went wrong, please contact admin.",
            color: Colors.red.shade400,
          );
        }
      });
    } catch (e) {
      Get.back();
      showSnackBarAlert(
        message: e.toString(),
        color: Colors.red.shade400,
      );
    }
  }

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': walletController.paymentSettingModel.value.razorpay!.key,
      'amount': amount * 100,
      'name': 'Foodies',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': "8888888888", 'email': "demo@demo.com"},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPayController.open(options);
    } catch (e) {
      log('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.back();
    walletController.setAmount(amountController.text).then((value) {
      if (value != null) {
        showSnackBarAlert(
          message: "Payment Successful!!",
          color: Colors.green.shade400,
        );
        _refreshAPI();
      }
    });
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Get.back();
    showSnackBarAlert(
      message: "Payment Processing Via\n${response.walletName!}",
      color: Colors.blue.shade400,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.back();
    showSnackBarAlert(
      message: "Payment Failed!!\n "
          "${jsonDecode(response.message!)['error']['description']}",
      color: Colors.red.shade400,
    );
  }

  /// Stripe Payment Gateway
  Map<String, dynamic>? paymentIntentData;

  Future<void> stripeMakePayment({required String amount}) async {
    try {
      paymentIntentData =
          await walletController.createStripeIntent(amount: amount);
      if (paymentIntentData!.containsKey("error")) {
        Get.back();
        showSnackBarAlert(
          message: "Something went wrong, please contact admin.",
          color: Colors.red.shade400,
        );
      } else {
        await stripe1.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              allowsDelayedPaymentMethods: false,
              googlePay: stripe1.PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: walletController.paymentSettingModel.value.strip!
                            .isSandboxEnabled ==
                        'true'
                    ? true
                    : false,
                currencyCode: "USD",
              ),
              style: ThemeMode.system,
              appearance: stripe1.PaymentSheetAppearance(
                colors: stripe1.PaymentSheetAppearanceColors(
                  primary: ConstantColors.primary,
                ),
              ),
              merchantDisplayName: 'Urride',
            ))
            .then((value) {});
        displayStripePaymentSheet();
      }
    } catch (e, s) {
      showSnackBarAlert(
        message: 'exception:$e \n$s',
        color: Colors.red,
      );
    }
  }

  displayStripePaymentSheet() async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
        Get.back();
        walletController.setAmount(amountController.text).then((value) {
          if (value != null) {
            _refreshAPI();
          }
        });
        paymentIntentData = null;
      });
    } on stripe1.StripeException catch (e) {
      Get.back();
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      showSnackBarAlert(
        message: lom.error.message,
        color: Colors.green,
      );
    } catch (e) {
      Get.back();
      showSnackBarAlert(
        message: e.toString(),
        color: Colors.green,
      );
    }
  }

  ///PayStack Payment Method
  payStackPayment(BuildContext context) async {
    var secretKey = walletController
        .paymentSettingModel.value.payStack!.secretKey
        .toString();
    await walletController
        .payStackURLGen(
      amount: amountController.text,
      secretKey: secretKey,
    )
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        bool isDone = await Get.to(() => PayStackScreen(
              walletController: walletController,
              secretKey: secretKey,
              initialURl: payStackModel.data.authorizationUrl,
              amount: amountController.text,
              reference: payStackModel.data.reference,
              callBackUrl: walletController
                  .paymentSettingModel.value.payStack!.callbackUrl
                  .toString(),
            ));
        Get.back();

        if (isDone) {
          walletController.setAmount(amountController.text).then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!",
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        } else {
          showSnackBarAlert(
              message: "Payment UnSuccessful!! \n", color: Colors.red);
        }
      } else {
        showSnackBarAlert(
            message: "Error while transaction! \n", color: Colors.red);
      }
    });
  }

  showSnackBarAlert({required String message, Color color = Colors.green}) {
    return Get.showSnackbar(GetSnackBar(
      isDismissible: true,
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 8),
    ));
  }

  ///FlutterWave Payment Method

  flutterWaveInitiatePayment(
    BuildContext context,
  ) async {
    final style = FlutterwaveStyle(
      appBarText: "Urride",
      buttonColor: const Color(0xff4774FF),
      buttonTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      appBarColor: const Color(0xff4774FF),
      dialogCancelTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      dialogContinueTextStyle: const TextStyle(
        color: Color(0xff4774FF),
        fontSize: 18,
      ),
      mainTextStyle:
          const TextStyle(color: Colors.black, fontSize: 19, letterSpacing: 2),
      dialogBackgroundColor: Colors.white,
      appBarTitleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );
    final flutterwave = Flutterwave(
      amount: amountController.text.toString().trim(),
      currency: "NGN",
      style: style,
      customer: Customer(
        name: "demo",
        phoneNumber: "1234567890",
        email: "demo@gamil.com",
      ),
      context: context,
      publicKey: walletController
          .paymentSettingModel.value.flutterWave!.publicKey
          .toString(),
      paymentOptions: "ussd, card, barter, payattitude",
      customization: Customization(
        title: "Urride",
      ),
      txRef: walletController.ref.value,
      isTestMode: walletController
                  .paymentSettingModel.value.flutterWave!.isSandboxEnabled ==
              'true'
          ? true
          : false,
      redirectUrl: '${API.baseUrl}success',
    );
    try {
      final ChargeResponse response = await flutterwave.charge();
      if (response.toString().isNotEmpty) {
        if (response.success!) {
          Get.back();
          walletController.setAmount(amountController.text).then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!",
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        } else {
          Get.back();
          showSnackBarAlert(
            message: response.status!,
            color: Colors.red,
          );
        }
      } else {
        Get.back();
        showSnackBarAlert(
          message: "No Response!",
          color: Colors.red,
        );
      }
    } catch (e) {
      Get.back();
      showSnackBarAlert(
        message: e.toString(),
        color: Colors.red,
      );
    }
  }

  ///payFast

  payFastPayment(context) {
    PayFast? payfast = walletController.paymentSettingModel.value.payFast;
    PayStackURLGen.getPayHTML(
            payFastSettingData: payfast!,
            amount: double.parse(amountController.text.toString())
                .round()
                .toString())
        .then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(
        htmlData: value!,
        payFastSettingData: payfast,
      ));
      if (isDone) {
        Get.back();
        walletController.setAmount(amountController.text).then((value) {
          if (value != null) {
            showSnackBarAlert(
              message: "Payment Successful!!",
              color: Colors.green.shade400,
            );
            _refreshAPI();
          }
        });
      } else {
        Get.back();
        showSnackBarAlert(
          message: "Payment UnSuccessful!!",
          color: Colors.red,
        );
      }
    });
  }

  ///MercadoPago Payment Method

  mercadoPagoMakePayment(BuildContext context) {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var clientId = result['response']['client_id'];
        var preferenceId = result['response']['id'];
        String initPoint = result['response']['init_point'];
        final bool isDone =
            await Get.to(MercadoPagoScreen(initialURl: initPoint));

        if (isDone) {
          Get.back();
          walletController.setAmount(amountController.text).then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!",
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        } else {
          Get.back();
          showSnackBarAlert(
            message: "Payment UnSuccessful!!",
            color: Colors.red,
          );
        }
      } else {
        Get.back();
        showSnackBarAlert(
          message: "Error while transaction!",
          color: Colors.red,
        );
      }
    });
  }

  Future<Map<String, dynamic>> makePreference() async {
    final mp = MP.fromAccessToken(
        walletController.paymentSettingModel.value.mercadopago!.accesstoken);
    var pref = {
      "items": [
        {
          "title": "Wallet TopUp",
          "quantity": 1,
          "unit_price": double.parse(amountController.text)
        }
      ],
      "auto_return": "all",
      "back_urls": {
        "failure": "${API.baseUrl}payment/failure",
        "pending": "${API.baseUrl}payment/pending",
        "success": "${API.baseUrl}payment/success"
      },
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  showLoadingAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              Text('Please wait!!'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Please wait!! while completing Transaction',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum PaymentOption {
  Stripe,
  PayTM,
  RazorPay,
  PayFast,
  PayStack,
  MercadoPago,
  PayPal,
  FlutterWave,
}
