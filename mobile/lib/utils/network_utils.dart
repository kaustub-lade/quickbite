import 'dart:async';
import 'dart:io';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

/// Utility class for network operations with retry logic
class NetworkUtils {
  /// Check if device has internet connectivity
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Execute a function with retry logic
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delayBetweenRetries = const Duration(seconds: 2),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        final isLastAttempt = attempts >= maxRetries;
        final shouldRetryError = shouldRetry?.call(e) ?? true;
        
        if (isLastAttempt || !shouldRetryError) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(delayBetweenRetries);
      }
    }
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
           error is NetworkException ||
           error is TimeoutException ||
           (error is Exception && error.toString().contains('network'));
  }

  /// Get user-friendly error message
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    }
    
    if (error is TimeoutException || error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (error is ApiException) {
      if (error.statusCode == 404) {
        return 'Resource not found.';
      } else if (error.statusCode == 500) {
        return 'Server error. Please try again later.';
      } else if (error.statusCode == 401 || error.statusCode == 403) {
        return 'Authentication failed. Please login again.';
      }
      return error.message;
    }
    
    // Generic error message
    return 'Something went wrong. Please try again.';
  }
}
