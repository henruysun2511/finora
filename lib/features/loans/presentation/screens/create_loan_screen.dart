import 'package:flutter/material.dart';
import 'loan_form_screen.dart';

/// Màn hình thêm khoản nợ (wrapper trỏ về LoanFormScreen theo chuẩn Clean Architecture)
class CreateLoanScreen extends StatelessWidget {
  const CreateLoanScreen({super.key});

  @override
  Widget build(BuildContext context) => const LoanFormScreen();
}
