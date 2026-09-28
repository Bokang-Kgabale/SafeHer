/// A logged "would-have-sent" action from Preview Mode's simulated dispatcher
/// (SRS FR-PREV-3, SEC-11). Never a real call/WhatsApp send — Preview Mode's
/// telephony/WhatsApp gateways record here instead of touching a real channel.
class SimulatedDispatchEntry {
  final DateTime at;
  final String contactName;
  final String channel; // "call" | "whatsapp"
  final String summary;

  const SimulatedDispatchEntry({
    required this.at,
    required this.contactName,
    required this.channel,
    required this.summary,
  });
}
