import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Urride/constant/show_toast_dialog.dart';
import 'package:Urride/model/ride_model.dart';
import 'package:Urride/service/api.dart';
import 'package:Urride/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CanceledController extends GetxController {
  var isLoading = true.obs;
  var rideList = <RideData>[].obs;

  @override
  void onInit() {
    getCanceledRide();
    super.onInit();
  }

  Future<dynamic> getCanceledRide() async {
    try {
      final response = await http.get(Uri.parse("${API.canceledRide}?id_user_app=${Preferences.getInt(Preferences.userId)}"), headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        isLoading.value = false;
        RideModel model = RideModel.fromJson(responseBody);
        rideList.value = model.data!;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
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
