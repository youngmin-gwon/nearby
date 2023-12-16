import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poc/src/core/presentation/routes/app_router_delegate.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/infrastructure/datastore/asset_dao.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late AppRouterDelegate _routerDelegate;
  Isar? _isarDatabase;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _initializeDatabase();
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    _isarDatabase!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isarDatabase == null) {
      return _defaultAppWidget;
    } else {
      /// riverpod 설정을 위해 필요함!
      return ProviderScope(
        overrides: [isarDatabaseProvider.overrideWithValue(_isarDatabase!)],
        child: _defaultAppWidget,
      );
    }
  }

  Future<void> _initializeDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    await dotenv.load(fileName: '.envrc');
    Isar.open([AssetDaoSchema], directory: dir.path).then(
      (isar) {
        setState(() {
          _isarDatabase = isar;
        });
      },
    );
  }

  Widget get _defaultAppWidget {
    return SafeArea(
      child: MaterialApp.router(
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.system,
        routerDelegate: _routerDelegate,
      ),
    );
  }
}
