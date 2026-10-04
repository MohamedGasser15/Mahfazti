import 'package:flutter/material.dart';

enum TransactionType { all, income, expense, transfer }

class TransactionFilter {
  final TransactionType type;
  final String label;

  TransactionFilter({
    required this.type,
    required this.label,
  });
}

class AccountItem {
  final String id;
  final String name;
  final String type; // 'all', 'cash', 'bank', 'ewallet', 'savings'
  final double balance;
  final double income;
  final double expense;
  final IconData icon;
  final bool isAll;
  final bool isMain;
  final String? accountNumber;
  final String currency;

  const AccountItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.income = 0.0,
    this.expense = 0.0,
    required this.icon,
    this.isAll = false,
    this.isMain = false,
    this.accountNumber,
    this.currency = 'EGP',
  });
}
