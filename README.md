# Flutter

## Installation

Telecharger et installer Flutter et android studio.
Telecharger a l'aide d'andoid studio le SDK et Android SDK Command-line Tools
Set variable environnement :

* ANDROID_HOME
* Path: ajout "C:\Users\ruffi\AppData\Local\Android\Sdk\platform-tools"
* Tapez "Activer ou désactiver des fonctionnalités Windows" dans votre barre de recherche.
  * Assurez-vous que les cases suivantes sont cochées :
  * Plateforme de l'hyperviseur Windows
  * Plateforme de machine virtuelle

Vérification installation :

```sh
flutter --version
dart --version
flutter doctor
flutter config --android-sdk "C:\Users\ruffi\AppData\Local\Android\Sdk"
flutter doctor --android-licenses
# Voir les devices de disponibles
flutter devices
```

### Ajout d'un emulateur

![Ajout d'un emulateur](<documents/Capture d'écran 2026-05-14 142214.png>)

## Create application (exemple nom d'application birdle)

```sh
flutter create birdle --empty
```

## Run application

```sh
cd birdle
flutter run -d <YOUR_DEVICES>
# Exemple:
# flutter devices
# Found 3 connected devices:
#   sdk gphone16k x86 64 (mobile) • emulator-5554 • android-x64    • Android 17 (API 37) (emulator)
#   Windows (desktop)             • windows       • windows-x64    • Microsoft Windows [version 10.0.26200.8457]
#   Chrome (web)                  • chrome        • web-javascript • Google Chrome 148.0.7778.96
flutter run -d emulator-5554
```

## Utiliser le rechargement à chaud

Modifier le code :

```dart
child: Text('Hello World!'),
```

Cliquer dans le terminal ou l'application est en cours d'execution (flutter run -d emulator-5554), Puis appuyer sur la touche  _r_.

## Création et ajout de widgets

Ajout widget birdle\lib\game.dart puis incorporer dans le main.dart.

main.dart

```sh
import 'package:flutter/material.dart';
import 'game.dart';
...
class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
...
```

### Utilisation du widget dans l'application

main.dart

```sh
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Tile('A', HitType.hit), // NEW
        ),
      ),
    );
  }
}
```

### Le container Widget
