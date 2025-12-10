import '../../../../utils/extension_functions.dart';

class RedirectUrls {
  RedirectUrls({required this.returnUrl, required this.cancelUrl});

  final String returnUrl;
  final String cancelUrl;

  RedirectUrls copy({String? returnUrl, String? cancelUrl}) {
    return RedirectUrls(
      returnUrl: returnUrl ?? this.returnUrl,
      cancelUrl: cancelUrl ?? this.cancelUrl,
    );
  }

  factory RedirectUrls.fromJson(Map<String, dynamic> json) {
    return RedirectUrls(
      returnUrl: json["return_url"],
      cancelUrl: json["cancel_url"],
    );
  }

  Map<String, dynamic> toJson() =>
      {"return_url": returnUrl, "cancel_url": cancelUrl}.filterNotNull();
}

/*
{
	"return_url": "https://example.com/return",
	"cancel_url": "https://example.com/cancel"
}*/
