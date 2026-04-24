import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/faith/providers/faith_provider.dart';
import 'features/grace/providers/grace_provider.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final faithProvider = FaithProvider();
  await faithProvider.initialize();
  final graceProvider = GraceProvider();
  await graceProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FaithProvider>.value(value: faithProvider),
        ChangeNotifierProvider<GraceProvider>.value(value: graceProvider),
      ],
      child: const HisSoldierApp(),
    ),
  );
}
