import 'dart:html';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keycloak_flutter/keycloak_flutter.dart';
import 'package:ufms_web_test/login_page.dart';

late KeycloakService keycloakService;

void main() async {
  keycloakService = KeycloakService(KeycloakConfig(
    url: 'https://homolog.ufms.br/keycloak-homolog',
    //url:'https://homolog.ufms.br/keycloak21',
    realm: 'ufms',
    clientId: 'sou-ufms-flutter',
  ));
  keycloakService.init(
    initOptions: KeycloakInitOptions(
      onLoad: 'check-sso',
      pkceMethod: 'S256',
      responseMode: 'query',
      silentCheckSsoRedirectUri:
          '${window.location.origin}/silent-check-sso.html',
    ),
  );
  runApp(MyApp(keycloakService: keycloakService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.keycloakService});
  final KeycloakService keycloakService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Keycloak Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}


final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginPage(keycloakService: keycloakService),
    ),
  ],
);
