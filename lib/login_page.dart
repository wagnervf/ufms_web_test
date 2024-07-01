import 'dart:convert';
import 'dart:developer';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:keycloak_flutter/keycloak_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.keycloakService});
  final KeycloakService keycloakService;

  @override

  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  KeycloakProfile? _keycloakProfile;

  void _login() {
    widget.keycloakService.login(KeycloakLoginOptions(
      redirectUri: window.location.origin,
    ));
  }

  @override
  void initState() {
    log('initState');
    super.initState();

    //
    checklogin();
    //
  }

  checklogin() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        widget.keycloakService.keycloakEventsStream.listen((event) async {
          log(event.toString());
          if (event.type == KeycloakEventType.onAuthSuccess) {
            log('onAuthSuccess');
            _keycloakProfile = await widget.keycloakService.loadUserProfile();
            _saveToken();
          } else {
            _keycloakProfile = null;
            log('_keycloakProfile = null;');
          }
          setState(() {});
        });
        var isLoggedIn = await widget.keycloakService.isLoggedIn();

        if (isLoggedIn) {
          log('Sucesso: isLoggedIn');
        } else {
          log('Usuário não: isLoggedIn');
        }

        if (widget.keycloakService.authenticated) {
          _saveToken();
          _keycloakProfile =
              await widget.keycloakService.loadUserProfile(false);
          log('Logado com sucesso');
        } else {
          log('Usuário não logado');
        }

        setState(() {});
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void _saveToken() async {
    try {
      String token = await widget.keycloakService.getToken();

      KeycloakProfile? user = await widget.keycloakService.loadUserProfile();
      window.localStorage['keycloak_token'] = token;

      Map<String, dynamic> tokenParsed = _parseIdToken(token);

      log(tokenParsed.toString());

      window.localStorage['data_user'] = {
        'id': user!.id,
        'name': user.username,
        'createdTimestamp': user.createdTimestamp
      }.toString();
    } catch (e) {
      log('_saveToken');
      log(e.toString());
    }
  }

  _parseIdToken(String idToken) {
    log('_parseIdToken');
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    var json = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );

    Map<String, dynamic> tokenObj = _parseIdToken(json.idToken!);

    log(tokenObj.toString());

    return tokenObj;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sou-ufms-flutter-web'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                widget.keycloakService.init(
                  initOptions: KeycloakInitOptions(
                    redirectUri: 'http://localhost:8080',
                  ),
                );
                await widget.keycloakService.logout();
              }),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: const Text(
                'Ensure you use the sample client included in this example app.',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Welcome ${_keycloakProfile?.username ?? 'Guest'}',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 20,
            ),
            if (_keycloakProfile?.username == null)
              ElevatedButton(
                onPressed: _login,
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            if (_keycloakProfile?.username != null)
              ElevatedButton(
                onPressed: () async {
                  log('refreshing token');
                  await widget.keycloakService.updateToken(1000).then((value) {
                    log(value.toString());
                  }).catchError((onError) {
                    log(onError);
                  });
                },
                child: Text(
                  'Refresh token',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        tooltip: 'Login',
        child: const Icon(Icons.login),
      ),
    );
  }
}
