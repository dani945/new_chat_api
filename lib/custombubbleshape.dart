import 'package:flutter/material.dart';

 
class CustomBubbleShape extends CustomPainter {
final Color bgColor;

CustomBubbleShape(this.bgColor);

@override
void paint(Canvas canvas, Size size) {
var paint = Paint()..color = bgColor;


 
var path = Path();
path.lineTo(-20, 0);
path.lineTo(-10, 15);
canvas.drawPath(path, paint);
}

@override
bool shouldRepaint(CustomPainter oldDelegate) {
return false;
}
}