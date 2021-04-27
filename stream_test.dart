import 'dart:async';

main(List<String> args) async {
  final c = StreamController<int>();

  for (int i = 0; i < 100; i++) {
    c.add(i);
  }

  await Future.delayed(Duration(seconds: 3));

  c.stream.listen((event) => print(event));

  c.done;
}
