class ApiRoutes {
  static const String baseUrl = "https://api.senjayer.com/api";

  // Authentication
  static const String loginUrl = "$baseUrl/auth/login";
  static const String registerUrl = "$baseUrl/auth/register";
  static const String logoutUrl = "$baseUrl/auth/logout";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";

  // User
  static const String getUserProfile = "$baseUrl/v1/users";
  static const String updateUserProfile = "$baseUrl/v1/users";

  // Products
  static const String getProducts = "$baseUrl/products";
  static const String getProductDetails = "$baseUrl/products/{id}";

  // Orders
  static const String createOrder = "$baseUrl/orders/create";
  static const String getOrderDetails = "$baseUrl/orders/{id}";
  static const String cancelOrder = "$baseUrl/orders/{id}/cancel";

  // Example API Routes from OpenAPI Spec
  static const String getCategories = "$baseUrl/v1/categories-by-type?type=évènement";
  static const String getCategoryDetails = "$baseUrl/v1/categories/{id}";
  static const String createCategory = "$baseUrl/v1/categories/create";

  static const String getTransactions = "$baseUrl/transactions";
  static const String getTransactionDetails = "$baseUrl/transactions/{id}";
  static const String createTransaction = "$baseUrl/transactions/create";

  // eventes
  static const String getEventsDetails = "$baseUrl/v1/agent/liste-event";
  static const String getEvents = "$baseUrl/v1/events-list/promotor?private=1";
  // static const String getEvents = "$baseUrl/v1/events";
  static const String createEvent = "$baseUrl/v1/events/";
  // static const String createEvent = "$baseUrl/v1/events/";


  static const String getPackages = "$baseUrl/v1/packages";
  static const String subscribtions = "$baseUrl/v1/subscriptions"; 
  // (  "user_id" , "package_id", "event_limit") 
  static const String transactions  = "$baseUrl/v1/transactions";
}
