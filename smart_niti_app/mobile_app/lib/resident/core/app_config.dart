class AppConfig {
  // เปลี่ยนเป็น IP จริงของ Backend เมื่อ Deploy
  // ถ้ารันบน Android Emulator ใช้ 10.0.2.2 แทน localhost
  // ถ้ารันบน iOS Simulator หรือ Physical Device ใช้ IP ของเครื่อง
  // static const String baseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl =
      'https://smart-niti-backend-3d8k8.ondigitalocean.app';
}
