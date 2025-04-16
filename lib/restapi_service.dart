
import 'dart:convert';

import 'package:http/http.dart' as http;

class RestapiService {
Future<dynamic> postRequest(
      {required String url,
    required var header,
      dynamic body,
      bool? map
      }) async {

    try {
      var request = http.Request('POST', Uri.parse(url));
 
      if(map==false){
        request.body= jsonEncode(body);
      }
      else{
      request.bodyFields = (body);
      }
 
      request.headers.addAll(header);
 
      http.StreamedResponse response = await request.send();
      print('status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        if(responseBody.isNotEmpty) {
          return responseBody;
        } else {
          return response;
        }
      } 
    } catch (e) {
      print('Error: $e');
    }
  }
}

