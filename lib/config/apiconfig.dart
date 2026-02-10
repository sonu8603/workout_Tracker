




// mark isprod to true for production
class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl => isProd
      ? "https://yourapp.onrender.com/api"
      : "http://10.247.30.156:5000/api";
}
