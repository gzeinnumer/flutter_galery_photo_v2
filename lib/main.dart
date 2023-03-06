import 'package:flutter/material.dart';
import 'package:flutter_galery_photo_v2/gzn_dynamic_photo_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DynamicPhoto> res = [
    // DynamicPhoto("/data/user/0/com.example.flutter_galery_photo_v2/cache/c585bcd6-a64e-498c-ba6e-8894d13d1a6a2048387513829356888.jpg", "base64"),
    // DynamicPhoto("/data/user/0/com.example.flutter_galery_photo_v2/cache/24f43a52-3903-4c9f-9fb6-cff01dbae8731152124621162338820.jpg", "base64"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DynamicPhotoWidget(
              (res) {
                this.res = res;
                // print("zein_${this.res.length}");
                for (int i = 0; i < res.length; i++) {
                  print("zein_" + res[i].path);
                }
              },
              centerWidget: true,
              max: 3,
              // max: this.res.length,
              askBeforeDelete: true,
              showDebug: true,
              resLastData: res,
            ),
          ],
        ),
      ),
    );
  }
}
