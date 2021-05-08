import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const API = 'ppg-app-api.herokuapp.com';

main(List<String> args) async {
  final url = Uri.https(API, 'ppg');
  final response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'ppgPoints': [{"timestamp": 1, "value": 1} ,{"timestamp": 2, "value": 2}],
    }),);
  print(response.body);
}
