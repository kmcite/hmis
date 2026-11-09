import 'dart:math';

/// Opaque client-side id for marks before a PocketBase record exists.
String localClientId() {
  final r = Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
