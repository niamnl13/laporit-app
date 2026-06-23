class AppConstants {
  // Pilih salah satu:
  // Chrome  → http://localhost:8000/api
  // HP Fisik → http://192.168.100.39:8000/api

  //static const String baseUrl = 'http://192.168.100.39:8000/api';
  static const String baseUrl = 'http://localhost:8000/api';

  // Base URL untuk file storage (tanpa /api di akhir)
    static String get storageUrl {
      return baseUrl.replaceAll('/api', '') + '/storage';
  }
}
