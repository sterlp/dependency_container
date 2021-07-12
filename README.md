[![Dart](https://github.com/sterlp/dependency_container/actions/workflows/dart.yml/badge.svg)](https://github.com/sterlp/dependency_container/actions/workflows/dart.yml)

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# dependency container

A simple flutter dependency container which is more or less a map and brings support
for factory methods and lazy building of services.

## Main goals

- be simple
- support for easy testing and mocking

## Getting Started

## Flutter InheritedWidget 
Share app container deeper in the widget tree?

https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html

## Example apps

https://github.com/sterlp/solvis-app/tree/master/solvis_v2_app
https://github.com/sterlp/daily-challenge

### Async app_config.dart to init the AppContainer
```dart
/// optional parameters for testing
/// enables the re-usage of this function for test and mocking
/// of the infrastructure dependencies
Future<AppContainer> buildContext([Future<SharedPreferences>?  pref]) async {
  pref ??= SharedPreferences.getInstance();
  final f = await pref;
  return AppContainer()
      .add(f)
      .add(YourPrefService(f))
      .addFactory((container) => YourOtherService(container.get<YourPrefService>()));
}
```

### Async init in the main.dart
```dart
class MyHomePage extends StatefulWidget {
  /// Enable setting of the container for testing
  MyHomePage({Key? key, required this.title,
      Future<AppContainer>? container}) :
        _container = container ?? buildContext(),
        super(key: key);

  final String title;
  final Future<AppContainer> _container;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void dispose() {
    // dispose all beans
    widget._container.then((value) => value.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppContainer>(
      future: widget._container,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // your main screen
          return _buildMain(snapshot.requireData);
        } else {
          // your splash screen
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: const Center(child: CircularProgressIndicator())
          );
        }
      });
  }

  Widget _buildMain(AppContainer container) {
    final yourOtherService = container.get<YourOtherService>();
    final yourPrefService = container.get<YourPrefService>();
    return Scaffold(
        // your code
      );
    }
}
```
