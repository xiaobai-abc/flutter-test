class ErrorMessageModel {
  int? statusCode;
  String? error;
  String? message;

  ErrorMessageModel({this.statusCode, this.error, this.message});

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    return ErrorMessageModel(
        statusCode: json["StatusCode"],
        error: json["error"],
        message: json["message"]);
  }

  Map<String, dynamic> toJson() =>
      {"StatusCode": statusCode, "error": error, "message": message};
}
