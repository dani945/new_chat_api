// ignore_for_file: non_constant_identifier_names, unnecessary_type_check

import 'dart:convert';

import 'package:bts/models/Apiconstant.dart';
import 'package:http/http.dart' as http;

class CreateConsultation {

  Future<ReturnCreateConsultation?> createConsultation(bodyParameters) async {
    final response = await http.post(
      Uri.parse(urlApi),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: bodyParameters,
    );
    
    if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    Map dataList = await jsonDecode(response.body);
    if (dataList is Map) {
      return ReturnCreateConsultation.fromJson(dataList);
    }
    return null;
    // return ReturnCreateConsultation.fromJson(dataList);
  
    
  } else {
    // If the server did not return a 200 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create Customer.');
  }

  }
}

class ReturnCreateConsultation {
  final String response;
  final String message;
  final int ConsultationID;

  const ReturnCreateConsultation({required this.response, required this.message, required this.ConsultationID});

  factory ReturnCreateConsultation.fromJson(Map<dynamic, dynamic> json) {
    return ReturnCreateConsultation(
      response: json['response'],
      message: json['message'],
      ConsultationID: json['ConsultationID'],
    );
  }
}

