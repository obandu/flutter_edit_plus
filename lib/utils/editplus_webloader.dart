part of edit_plus;

class EditplusWebLoader {
  static var statetext_text = """{
  "ERROR":"ERROR WITH WEB REQUEST - WEB SITE CANNOT BE REACHED"
  }""";

  static Future<Map<String, dynamic>> httpGET(authority, unencodedPath) async {
    late String returned;
    try {
      var response = await http.get(Uri.https(authority, unencodedPath));
      returned = response.body;
    } catch (ex) {
      EditplusLogger.doConsoleLog("\n\nError at Webloader.httpGET is $ex");
      returned = statetext_text;
    }

    return jsonDecode(returned);
  }

  static Future<Map<String, dynamic>> httpPOST(authority, unencodedPath,
      {otherParams}) async {
    late String returned;
    late http.Response response;
    print("OTHER PARAMS ARE " + otherParams.toString());
    try {
      // print ("OTHER PARAMS ARE " + otherParams.toString());
      response = await http.post(Uri.http(authority, unencodedPath),
          body: otherParams);
      returned = response.body;
      print("\n" + response.body);
    } catch (ex) {
      // String responsebody = response.body;
      EditplusLogger.doConsoleLog("\n\nError at Webloader.httpPOST is $ex");
      returned = statetext_text;
    }

    print(returned);
    return {};
  }

  static Future<Map<String, dynamic>> httpsPOST(authority, unencodedPath,
      {otherParams}) async {
    late String returned;
    late http.Response response;
    print("OTHER PARAMS ARE " + otherParams.toString());
    try {
      // print ("OTHER PARAMS ARE " + otherParams.toString());
      response = await http.post(Uri.https(authority, unencodedPath),
          body: otherParams);
      returned = response.body.toString();
      print("\n THe resp body is " + response.body);
    } catch (ex) {
      // String responsebody = response.body;
      EditplusLogger.doConsoleLog("\n\nError at Webloader.httpsPOST is $ex");
      returned = statetext_text;
    }

    return jsonDecode(returned);
  }

  // URL can be of the form protocol://servername[:port]/service.do eg (https://servername/service.do or https://servername:port/servicename.do
  // or servername/service.do
  // or just servername

  static List<String> splitURL(String urlAsString) {
    var urlParts = <String>[];
    // check if there is a protocol beginning
    int indexOfProtocol = urlAsString.indexOf("://");
    if (indexOfProtocol > 0) {
      var protocolName = urlAsString.substring(0, indexOfProtocol);
      if (protocolName == "http" || protocolName == "https") {
        urlParts.add(urlAsString.substring(0, indexOfProtocol));
        urlAsString = urlAsString.substring(indexOfProtocol + 3);
      } else {
        urlParts.add("ERROR");
        urlParts.add("Only the http or https protocols are allowed");
        return urlParts;
      }
    }

    int indexOfFirstSlash = urlAsString.indexOf("/");

    if (indexOfFirstSlash < 0) {
      urlParts.add(urlAsString);
      urlParts.add("/");
    } else {
      urlParts.add(urlAsString.substring(0, indexOfFirstSlash));
      urlParts.add(urlAsString.substring(indexOfFirstSlash + 1));
    }

    EditplusLogger.doConsoleLog("The URL parts are $urlParts");
    return urlParts;
  }
}
