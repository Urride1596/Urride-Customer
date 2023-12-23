class UserModel {
  UserModel({
    this.success,
    this.error,
    this.message,
    this.data,
  });

  String? success;
  dynamic error;
  String? message;
  User? data;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        success: json["success"],
        error: json["error"],
        message: json["message"],
        data: User.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "error": error,
        "message": message,
        "data": data!.toJson(),
      };
}

class User {
  User({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.phone,
    this.loginType,
    this.photo,
    this.photoPath,
    this.photoNic,
    this.photoNicPath,
    this.statut,
    this.statutNic,
    this.tonotify,
    this.deviceId,
    this.fcmId,
    this.creer,
    this.updatedAt,
    this.modifier,
    this.amount,
    this.resetPasswordOtp,
    this.resetPasswordOtpModifier,
    this.age,
    this.gender,
    this.deletedAt,
    this.createdAt,
    this.userCat,
    this.online,
    this.country,
    this.accesstoken,
    this.adminCommission,
  });

  String? id;
  String? nom;
  String? prenom;
  String? email;
  String? phone;
  String? loginType;
  dynamic photo;
  String? photoPath;
  dynamic photoNic;
  dynamic photoNicPath;
  String? statut;
  dynamic statutNic;
  String? tonotify;
  dynamic deviceId;
  dynamic fcmId;

  DateTime? creer;
  DateTime? updatedAt;
  DateTime? modifier;
  dynamic amount;
  dynamic resetPasswordOtp;
  dynamic resetPasswordOtpModifier;
  String? age;
  String? gender;
  dynamic deletedAt;
  dynamic createdAt;
  String? userCat;
  String? online;
  String? country;
  String? accesstoken;
  String? adminCommission;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"].toString(),
        nom: json["nom"].toString() ?? '',
        prenom: json["prenom"].toString() ?? '',
        email: json["email"].toString(),
        phone: json["phone"].toString(),
        loginType: json["login_type"].toString(),
        photo: json["photo"].toString(),
        photoPath: json["photo_path"].toString() ?? '',
        photoNic: json["photo_nic"].toString(),
        photoNicPath: json["photo_nic_path"].toString(),
        statut: json["statut"].toString(),
        statutNic: json["statut_nic"].toString(),
        tonotify: json["tonotify"].toString(),
        deviceId: json["device_id"].toString(),
        fcmId: json["fcm_id"].toString(),
        creer: DateTime.parse(json["creer"].toString()),
        updatedAt: DateTime.parse(json["updated_at"].toString()),
        modifier: DateTime.parse(json["modifier"].toString()),
        amount: json["amount"].toString(),
        resetPasswordOtp: json["reset_password_otp"].toString(),
        resetPasswordOtpModifier: json["reset_password_otp_modifier"].toString(),
        age: json["age"].toString(),
        gender: json["gender"].toString(),
        deletedAt: json["deleted_at"].toString(),
        createdAt: json["created_at"].toString(),
        userCat: json["user_cat"].toString(),
        online: json["online"].toString(),
        country: json["country"].toString(),
        accesstoken: json["accesstoken"].toString(),
        adminCommission: json["admin_commission"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nom": nom,
        "prenom": prenom,
        "email": email,
        "phone": phone,
        "login_type": loginType,
        "photo": photo,
        "photo_path": photoPath,
        "photo_nic": photoNic,
        "photo_nic_path": photoNicPath,
        "statut": statut,
        "statut_nic": statutNic,
        "tonotify": tonotify,
        "device_id": deviceId,
        "fcm_id": fcmId,
        "creer": creer!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "modifier": modifier!.toIso8601String(),
        "amount": amount,
        "reset_password_otp": resetPasswordOtp,
        "reset_password_otp_modifier": resetPasswordOtpModifier,
        "age": age,
        "gender": gender,
        "deleted_at": deletedAt,
        "created_at": createdAt,
        "user_cat": userCat,
        "online": online,
        "country": country,
        "accesstoken": accesstoken,
        "admin_commission": adminCommission,
      };
}
