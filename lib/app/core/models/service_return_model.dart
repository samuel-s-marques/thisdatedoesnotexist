class ServiceReturn {
  ServiceReturn({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final dynamic data;
}
