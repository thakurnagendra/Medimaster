import 'package:flutter/material.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class ModuleConfig {
  static const Map<String, ModuleInfo> modules = {
    'lab': ModuleInfo(
      name: 'Lab',
      icon: Icons.science,
      color: AppConstantColors.labAccent,
      backgroundColor: AppConstantColors.labBackground,
    ),
    'pharmacy': ModuleInfo(
      name: 'Pharmacy',
      icon: Icons.medication,
      color: AppConstantColors.pharmacyAccent,
      backgroundColor: AppConstantColors.pharmacyBackground,
    ),
    'opd': ModuleInfo(
      name: 'OPD',
      icon: Icons.people,
      color: AppConstantColors.opdAccent,
      backgroundColor: AppConstantColors.opdBackground,
    ),
    'ipd': ModuleInfo(
      name: 'IPD',
      icon: Icons.local_hospital,
      color: AppConstantColors.ipdAccent,
      backgroundColor: AppConstantColors.ipdBackground,
    ),
    'accounts': ModuleInfo(
      name: 'Accounts',
      icon: Icons.account_balance,
      color: AppConstantColors.accountsAccent,
      backgroundColor: AppConstantColors.accountsBackground,
    ),
    'billing': ModuleInfo(
      name: 'Billing',
      icon: Icons.receipt_long,
      color: AppConstantColors.billingAccent,
      backgroundColor: AppConstantColors.billingBackground,
    ),
  };

  static ModuleInfo getModuleInfo(String module) {
    return modules[module] ?? modules['lab']!;
  }

  static List<String> getModuleNames() {
    return modules.keys.toList();
  }
}

class ModuleInfo {
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const ModuleInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
