class Environment {
  static String apiUrl = 'http://192.168.0.17:5001/waste-dev/us-central1/';
  // static String apiUrl = 'https://us-central1-waste-dev.cloudfunctions.net/';

  static Map<String, String> headersRequest = {
    "Accept": "application/json",
    "content-type": "application/json"
  };
}
