import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';
import '../../common/response_viewer.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _status = '';
  List<TransactionDetail> _transactions = [];
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  void _showTransactionDetails(TransactionDetail item) {
    String formattedResponse;
    try {
      final map = item.toJson();
      formattedResponse = const JsonEncoder.withIndent('  ').convert(map);
    } catch (e) {
      formattedResponse = item.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            ResponseViewer(text: formattedResponse, constraints: null),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Status: $_status",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(
                    "Start: ${_start.toIso8601String().split('T')[0]}",
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text("End: ${_end.toIso8601String().split('T')[0]}"),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              _updateStatus("Listing Transactions...");
              setState(() {
                _transactions = [];
              });
              PaypalPayment.instance.transactions.listTransactions(
                startDate: _start,
                endDate: _end,
                onSuccess: (res) {
                  _updateStatus(
                    "Found ${res.transactionDetails.length} transactions",
                  );
                  setState(() {
                    _transactions = res.transactionDetails;
                  });
                },
                onError: (error) =>
                    _updateStatus("List Transactions Error: $error"),
              );
            },
            child: const Text("List Transactions"),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: _transactions.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final item = _transactions[index];
                final info = item.transactionInfo;
                return ListTile(
                  title: Text(info?.transactionId ?? "Unknown ID"),
                  subtitle: Text(
                    "Date: ${info?.transactionInitiationDate}\nStatus: ${info?.transactionStatus}",
                  ),
                  trailing: Text(
                    "${info?.transactionAmount?.value ?? '0.00'} ${info?.transactionAmount?.currencyCode ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                  onTap: () => _showTransactionDetails(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
