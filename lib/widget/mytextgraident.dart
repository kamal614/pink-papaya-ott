import 'dart:math';
import 'dart:ui';

import 'package:dtlive/utils/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:dtlive/utils/constant.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextwo extends StatelessWidget {
  String text;
  double? fontsizeNormal, fontsizeWeb;
  int? maxline;
   Color color;
  FontStyle? fontstyle;
  FontWeight? fontweight;
  TextAlign? textalign;
  bool? multilanguage;
  TextOverflow? overflow;

  MyTextwo({
    Key? key,
    required this.color,
    required this.text,
    this.fontsizeNormal,
    this.fontsizeWeb,
    this.maxline,
    this.multilanguage,
    this.overflow,
    this.textalign,
    this.fontweight,
    this.fontstyle,
  }) : super(key: key);

  static getAdaptiveTextSize(BuildContext context, dynamic value) {
    if (kIsWeb || Constant.isTV) {
      return (value / 650) *
          min(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width);
    } else {
      return (value / 720 * MediaQuery.of(context).size.height);
    }
  }

  final Shader linearGradient = LinearGradient(
  colors: <Color>[colorGraidentLeft,colorGraidentRight],
).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    if (multilanguage == true) {
      return LocaleText(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: GoogleFonts.outfit(
          textStyle: TextStyle(
            foreground: Paint()..shader = linearGradient,
            fontSize: getAdaptiveTextSize(
              context,
              (kIsWeb || Constant.isTV) ? fontsizeWeb : fontsizeNormal,
            ),
            fontStyle: fontstyle,
            fontWeight: fontweight,

           
          ),
        ),
      );
    } else {
      return Text(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: GoogleFonts.outfit(
          textStyle: TextStyle(
            foreground: Paint()..shader = linearGradient ,
            fontSize: getAdaptiveTextSize(
              context,
              (kIsWeb || Constant.isTV) ? fontsizeWeb : fontsizeNormal,
            ),
            fontStyle: fontstyle,
            fontWeight: fontweight,
           
          ),
        ),
      );
    }
  }
}
