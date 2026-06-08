const String _photo = 'photo';
const String _governmentId = 'government_id';
const String _none = 'none';

/// Returns 'photo', 'government_id', or 'none'. Never null or an unknown value.
String normalizedVerificationLevel(String? level) {
  if (level == _photo || level == _governmentId) return level!;
  return _none;
}

/// True when [level] represents any verified state ('photo' or 'government_id').
bool isVerifiedLevel(String? level) {
  final l = normalizedVerificationLevel(level);
  return l == _photo || l == _governmentId;
}

/// True only for the 'photo' level.
bool isPhotoVerified(String? level) => normalizedVerificationLevel(level) == _photo;
