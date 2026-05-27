import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- SCREEN 2: CONFIRMATION ---
class EmailConfirmationScreen extends StatelessWidget {
  const EmailConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: const Center(
        child: Text('Check your Inbox!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}