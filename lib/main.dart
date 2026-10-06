import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/supabase/supabase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  await configureDependencies();
  runApp(const HireSignalApp());
}
