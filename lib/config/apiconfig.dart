




// mark isprod to true for production
class ApiConfig {
  static const bool isProd = true;

  static String get baseUrl => isProd
      ? "https://fitmetrics-3m07.onrender.com/api"
      : "http://10.89.149.156:5000/api";
}
