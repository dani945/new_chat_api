// ignore_for_file: non_constant_identifier_names, unnecessary_type_check, depend_on_referenced_packages

import 'dart:convert';

import 'package:bts/models/Apiconstant.dart';
import 'package:http/http.dart' as http;

class ListChat {

  Future<List?> listChat(bodyParameters) async {
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
      
      final result = dataList['Data'];
      
      if (result is List) {
        List list = result;
        return list;
      }
      // return Data.fromJson(result);
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