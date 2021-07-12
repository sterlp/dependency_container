library dependency_container;

/// Simple interface for a bean to mark a bean as close-able
/// called on each bean if the container is closed.
mixin Closeable {
  Future<dynamic> close();
}

typedef BeanFactory<T> = T Function(AppContainer container);

/// Simple application container.
class AppContainer with Closeable {

  /// stores all [BeanFactory]s that get registered by Type
  final _beanFactories = Map<Type, BeanFactory>();
  final _beans = Map<Type, dynamic>();

  /// The amount of beans and factories registered
  int get size => _beanFactories.length + _beans.length;

  T call<T> () {
    return get<T>();
  }

  /// Get the bean registered with the given type - will call any factory as needed.
  T get<T>() {
    var result = _beans[T];
    if (result == null) {
      final factory = _beanFactories[T];
      assert(() {
        if (factory == null) {
          throw StateError('No Bean nor Factory of type ${T.toString()} is registered.');
        }
        return true;
      }());
      result = factory!(this) as T;
      _beans[T] = result;
    }
    return result as T;
  }

  AppContainer add<T>(T bean) {
    _beans[T] = bean;
    return this;
  }

  AppContainer addFactory<T>(BeanFactory<T> beanFactory) {
    _beanFactories[T] = beanFactory;
    return this;
  }

  @override
  Future<void> close() async {
    print('app context is shutting down.');
    _beanFactories.clear();
    final toClean = _beans.values.toList();
    _beans.clear();

    for (int i = 0; i < toClean.length; ++i) {
      final value = toClean[i];
      try {
        if (value is Closeable) await value.close();
      } catch(e) {
        print('failed to close service name: ${value.toString()}, error: $e');
      }
    }
  }
}
