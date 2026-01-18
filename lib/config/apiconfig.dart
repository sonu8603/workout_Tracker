




// mark isprod to true for production
class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl => isProd
      ? "https://yourapp.onrender.com/api"
      : "http://192.168.31.176:3000/api";
}
