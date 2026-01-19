import 'package:flutter/material.dart';
import 'app/app.dart';

void main() async{
  runApp(const App());
  await Supabase.initialize(
   url:'https://lbhpntmxvqfmlszwqnrc.supabase.co' ,
   anonKey:'sb_publishable_mPJ_kM_nJX1oc89UdHh_yQ_Kc_RFjC5'
   authOptions: const FlutterAuthClientOptions(
   authFlowType: AuthFlowType.pkce,
  ),
  realtimeClientOptions: const RealtimeClientOptions(
    logLevel: RealtimeLogLevel.info,
  ),
  storageOptions: const StorageClientOptions(
    retryAttempts: 10,
  ),
  );
  runApp(MyApp());

}
final supabase = Supabase.instance.client;
