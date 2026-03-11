import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final key = ref.watch(appResetProvider);

    return KeyedSubtree(
      key: key,
      child: MaterialApp.router(
        title: 'Gen Motion AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}

final appResetProvider =
    NotifierProvider<AppResetNotifier, UniqueKey>(AppResetNotifier.new);

class AppResetNotifier extends Notifier<UniqueKey> {
  @override
  UniqueKey build() => UniqueKey();

  void reset() {
    state = UniqueKey();
  }
}
