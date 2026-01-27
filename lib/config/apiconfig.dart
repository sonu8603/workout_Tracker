




// mark isprod to true for production
class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl => isProd
      ? "https://yourapp.onrender.com/api"
      : "http://10.166.203.156:3000/api";
}
