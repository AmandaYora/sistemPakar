import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../crypto.dart';

class Address {
  static final String footer =
      "Pe9ZF/66vzthHR9MFWcIAOAXx0xlZLxobDRZ1Z1kNbZGGhJad4gJs6yOp+xkduge";
}

class Excellent extends StatelessWidget {
  final body = decryptAES('${name.body}', '${key.Crypto}');
  final title = decryptAES('${name.title}', '${key.Crypto}');

  Excellent() {
    print(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          body,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
