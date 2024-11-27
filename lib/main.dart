import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';
import 'package:solana_likhart/pages/config.dart';
import 'package:solana_likhart/pages/create_nft.dart';
import 'package:solana_likhart/pages/generatePhrase.dart';
import 'package:solana_likhart/pages/home.dart';
import 'package:solana_likhart/pages/inputPhrase.dart';
import 'package:solana_likhart/pages/login.dart';
import 'package:solana_likhart/pages/setupAccount.dart';
import 'package:solana_likhart/pages/setupPassword.dart';


void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(routes: <GoRoute>[
  GoRoute(
      path: '/',
      builder: (context, state) {
        return const LoginScreen();
      }),
  GoRoute(
      path: '/setup',
      builder: (context, state) {
        return const SetUpScreen();
      }),
  GoRoute(
      path: '/inputPhrase',
      builder: (context, state) {
        return const InputPhraseScreen();
      }),
  GoRoute(
      path: '/generatePhrase',
      builder: (context, state) {
        return const GeneratePhraseScreen();
      }),
  GoRoute(
      path: '/passwordSetup/:mnemonic',
      builder: (context, state) {
        return SetupPasswordScreen(mnemonic: state.pathParameters["mnemonic"]);
      }),
  GoRoute(
      path: '/home',
      builder: (context, state) {
        return const HomeScreen();
      }),
  GoRoute(
      path: '/createNft',
      builder: (context, state) {
        SolanaClient client = state.extra as SolanaClient;
        return CreateNftPage(client: client);
      }),
  GoRoute(
      path: '/config',
      builder: (context, state) {
        return const ConfigPage();
      }),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[500],
            )),
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[850],
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}