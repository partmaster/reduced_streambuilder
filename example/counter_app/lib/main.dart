// main.dart

import 'package:flutter/material.dart';
import 'package:reduced_streambuilder/reduced_streambuilder.dart';

import 'logic.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => wrapWithProvider(
        initialState: 0,
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Builder(
            builder: (context) => wrapWithConsumer(
              transformer: transformProps,
              builder: MyHomePage.new,
            ),
          ),
        ),
      );
}
