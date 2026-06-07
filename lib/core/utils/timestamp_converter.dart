import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts [Timestamp] (Firestore wire format) to/from [DateTime] (Dart).
///
/// The JSON-side type is [dynamic] so json_serializable generates no
/// compile-time cast. The converter checks at runtime whether the raw value
/// is a [Timestamp] (Firestore read) or a [String]/[int] fallback.
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is String) return DateTime.parse(json);
    throw ArgumentError('TimestampConverter: cannot convert $json to DateTime');
  }

  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}
