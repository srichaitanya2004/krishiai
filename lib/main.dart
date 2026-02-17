import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dontknyzwzvwdmugqacy.supabase.co',
    anonKey: 'sb_publishable_nNBramxj6bOcEhIt7DFESQ_XyaLqzZK',
  );

  runApp(const App());
}
