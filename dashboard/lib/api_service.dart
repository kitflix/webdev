import 'dart:convert';

import 'package:http/http.dart' as http;


Future<dynamic> ffetchLatestRecord() async {
   final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if(response.statusCode == 200)
  {
    var jsonData = jsonDecode(response.body);
    return jsonData;
  }
  else{
    throw Exception('Failed to load data');
  }
}