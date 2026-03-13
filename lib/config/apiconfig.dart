




// mark isprod to true for production
class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl => isProd
      ? "https://fitmetrics-3m07.onrender.com/api"
      : "http://10.0.2.2:5000/api";
}
