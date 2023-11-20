import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestHelper {
  static Future<dynamic> getRequest(String url) async {
    var urL = Uri.parse('$url');
    print(urL);
    http.Response response = await http.get(Uri.parse(url));
    print('her is the response');
    print('${response.body}');
    try {
      if (response.statusCode == 200) {
        print('successfully get response');
        String data = response.body;
        var decodedData = jsonDecode(data);
        return decodedData;
      } else {
        print('failed get response');
        return 'failed';
      }
    } catch (error) {
      print('failed get response');
      return 'failed';
    }
  }
}
