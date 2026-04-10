import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import './resident/features/repair_request/provider/repair_request_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '825941701407-2blehanidnkegfvfg0s72u7310o9topj.apps.googleusercontent.com',
  );
  runApp(
    MultiProvider(
      providers: [
        // เพิ่ม Provider ตรงนี้
        ChangeNotifierProvider(create: (_) => RepairRequestProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
