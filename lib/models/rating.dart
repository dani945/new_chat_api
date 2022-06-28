// ignore_for_file: non_constant_identifier_names, unnecessary_type_check, depend_on_referenced_packages

import 'dart:convert';

import 'package:bts/models/Apiconstant.dart';
import 'package:http/http.dart' as http;

class RatingChat {

  Future<ReturnSaveRating?> ratingChat(bodyParameters) async {
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
      return ReturnSaveRating.fromJson(dataList);
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

class ReturnSaveRating {
  final String response;
  final String message;

  const ReturnSaveRating({required this.response, required this.message});

  factory ReturnSaveRating.fromJson(Map<dynamic, dynamic> json) {
    return ReturnSaveRating(
      response: json['response'],
      message: json['message'],
    );
  }
}