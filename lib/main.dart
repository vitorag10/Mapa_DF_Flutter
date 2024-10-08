import 'package:flutter/material.dart';
import '../page/qgis.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/qgis',
      routes: {
        '/qgis' : (context) => QgisPage()
      },
    );
  }
}