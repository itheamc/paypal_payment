import '../../models/amount.dart';

class PurchaseUnit {
  PurchaseUnit({required this.referenceId, required this.amount});

  final String referenceId;
  final Amount amount;

  PurchaseUnit copy({String? referenceId, Amount? amount}) {
    return PurchaseUnit(
      referenceId: referenceId ?? this.referenceId,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() => {
    "reference_id": referenceId,
    "amount": amount.toJson(),
  };
}

/*
{
	"reference_id": "d9f80740-38f0-11e8-b467-0ed5f89f718b",
	"amount": {
		"currency_code": "USD",
		"value": "100.00"
	}
}*/
