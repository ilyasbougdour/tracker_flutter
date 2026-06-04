import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _moneyFormatter = NumberFormat.currency(
  locale: 'fr_MA',
  symbol: 'DH',
  decimalDigits: 0,
);

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {this.style, super.key});

  final double amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(_moneyFormatter.format(amount), style: style);
  }
}
