import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/model/CoupanCodeModel.dart';
import 'package:Urride/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CouponCodeController extends GetxController {
  var isLoading = true.obs;
  var coupanCodeList = <CoupanCodeData>[].obs;

  @override
  void onInit() {
    getCoupanCodeData();
    super.onInit();
  }

  Future<dynamic> getCoupanCodeData() async {
    try {
      final response = await http.get(Uri.parse(API.discountList), headers: API.header);
      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        CoupanCodeModel model = CoupanCodeModel.fromJson(responseBody);
        coupanCodeList.value = model.data!;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        coupanCodeList.clear();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
