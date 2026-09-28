import '../../core/controllers/panic_controller.dart';
import '../../core/models/panic_event.dart';
import '../../core/util/latest_value_stream.dart';

/// In-memory only — Preview Mode never persists a panic event anywhere real
/// (SEC-11). Exposed as a stream too so a Preview UI can show "recent activity"
/// without touching Firestore.
class PreviewPanicEventRepository implements PanicEventRepository {
  final List<PanicEvent> _events = [];
  final _stream = LatestValueStreamController<List<PanicEvent>>();

  @override
  Stream<List<PanicEvent>> watchAll() => _stream.stream;

  @override
  Future<void> save(PanicEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      _events.add(event);
    } else {
      _events[index] = event;
    }
    _stream.add(List.unmodifiable(_events));
  }

  @override
  Future<PanicEvent?> findUnresolvedForUser(String userId) async {
    for (final event in _events.reversed) {
      if (event.userId == userId && !event.isTerminal) return event;
    }
    return null;
  }
}
