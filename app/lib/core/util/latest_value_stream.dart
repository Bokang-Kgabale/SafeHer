import 'dart:async';

/// A broadcast stream that replays its latest value to any new listener —
/// enough for repositories to expose `Stream<List<T>>` without a full
/// state-management dependency at the data layer.
class LatestValueStreamController<T> {
  T? _latest;
  final _controller = StreamController<T>.broadcast();

  void add(T value) {
    _latest = value;
    _controller.add(value);
  }

  Stream<T> get stream async* {
    final latest = _latest;
    if (latest != null) yield latest;
    yield* _controller.stream;
  }

  void dispose() => _controller.close();
}
