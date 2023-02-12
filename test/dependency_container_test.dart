import 'package:dependency_container/dependency_container.dart';
import 'package:test/test.dart';

class CloseableBean with Closeable<bool> {
  bool closed = false;
  @override
  Future<bool> close() {
    closed = true;
    return Future.value(closed);
  }
}

class SimpleBean {
  bool closed = false;
  void close() {
    closed = true;
  }
}

void main() {
  var subject = AppContainer();
  var bean = SimpleBean();
  var closeableBean = CloseableBean();

  setUp(() {
    subject = AppContainer();
    bean = SimpleBean();
    closeableBean = CloseableBean();
  });

  test('Test get beans', () {
    subject.add(bean).add(closeableBean);
    expect(subject.get<SimpleBean>(), bean);
    expect(subject.get<CloseableBean>(), closeableBean);
  });

  test('Test get beans directly', () {
    subject.add("String 1").add(bean);

    expect(subject<String>(), "String 1");
    expect(subject<SimpleBean>(), bean);
  });

  test('Test factory support, lazy bean initialization', () {
    subject.addFactory((_) => SimpleBean()).addFactory((_) => "Hallo");
    expect(subject.get<SimpleBean>(), isA<SimpleBean>());
    expect(subject.get<String>(), "Hallo");
  });

  test('Test close support', () {
    subject.add(bean).add(closeableBean);
    subject.addFactory((_) => CloseableBean());
    expect(subject.size, 3);

    subject.close();

    expect(bean.closed, false);
    expect(closeableBean.closed, true);
    expect(subject.size, 0);
  });
}
