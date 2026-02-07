




// mark isprod to true for production
class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl => isProd
      ? "https://yourapp.onrender.com/api"
      : "http://172.16.100.194:3000/api";
}
