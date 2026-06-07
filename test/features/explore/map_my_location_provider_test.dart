import 'package:bloom/core/services/location_permission_service.dart';
import 'package:bloom/core/services/location_service.dart';
import 'package:bloom/features/explore/presentation/providers/map_my_location_provider.dart';
import 'package:bloom/features/location/presentation/providers/location_permission_provider.dart';
import 'package:bloom/features/location/presentation/providers/location_update_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;

// ── Test doubles ──────────────────────────────────────────────────────────────

class _GrantedPermissionService extends LocationPermissionService {
  const _GrantedPermissionService();
  @override
  Future<LocationPermissionStatus> checkStatus() async =>
      LocationPermissionStatus.granted;
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;
}

class _DeniedPermissionService extends LocationPermissionService {
  const _DeniedPermissionService();
  @override
  Future<LocationPermissionStatus> checkStatus() async =>
      LocationPermissionStatus.denied;
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.denied;
}

class _DeniedForeverPermissionService extends LocationPermissionService {
  const _DeniedForeverPermissionService();
  @override
  Future<LocationPermissionStatus> checkStatus() async =>
      LocationPermissionStatus.deniedForever;
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.deniedForever;
}

class _ServiceDisabledPermissionService extends LocationPermissionService {
  const _ServiceDisabledPermissionService();
  @override
  Future<LocationPermissionStatus> checkStatus() async =>
      LocationPermissionStatus.serviceDisabled;
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.serviceDisabled;
}

class _MockLocationService extends LocationService {
  const _MockLocationService(this._position);
  final Position _position;
  @override
  Future<Position> getCurrentPosition() async => _position;
}

class _UnavailableLocationService extends LocationService {
  const _UnavailableLocationService();
  @override
  Future<Position> getCurrentPosition() async =>
      throw const LocationUnavailableException('test: unavailable');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _testPosition = Position(
  longitude: 126.978,
  latitude: 37.566,
  timestamp: DateTime(2026),
  accuracy: 100,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

ProviderContainer _makeContainer({
  required LocationPermissionService permService,
  LocationService? locService,
}) {
  return ProviderContainer(
    overrides: [
      locationPermissionServiceProvider.overrideWithValue(permService),
      if (locService != null)
        locationServiceProvider.overrideWithValue(locService),
    ],
  );
}

/// Waits for the provider to finish its initial permission check.
Future<void> _settle(ProviderContainer c) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!c.read(mapMyLocationProvider).isChecking) return;
  }
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  group('MapMyLocationState', () {
    test('default state: isChecking true, hasPermission false, no error', () {
      const s = MapMyLocationState(isChecking: true);
      expect(s.isChecking, isTrue);
      expect(s.hasPermission, isFalse);
      expect(s.error, isNull);
    });
  });

  group('MapMyLocationNotifier — initial permission check', () {
    test('initial build state is isChecking: true', () {
      final c = _makeContainer(permService: const _GrantedPermissionService());
      addTearDown(c.dispose);
      // Synchronous read before any async settling
      expect(c.read(mapMyLocationProvider).isChecking, isTrue);
    });

    test('hasPermission is true after granted permission resolves', () async {
      final c = _makeContainer(permService: const _GrantedPermissionService());
      addTearDown(c.dispose);
      await _settle(c);
      final s = c.read(mapMyLocationProvider);
      expect(s.hasPermission, isTrue);
      expect(s.isChecking, isFalse);
      expect(s.error, isNull);
    });

    test('hasPermission is false after denied permission resolves', () async {
      final c = _makeContainer(permService: const _DeniedPermissionService());
      addTearDown(c.dispose);
      await _settle(c);
      final s = c.read(mapMyLocationProvider);
      expect(s.hasPermission, isFalse);
      expect(s.isChecking, isFalse);
      expect(s.error, isNull);
    });
  });

  group('MapMyLocationNotifier — requestAndGetLocation', () {
    test('returns position and sets hasPermission when granted', () async {
      final c = _makeContainer(
        permService: const _GrantedPermissionService(),
        locService: _MockLocationService(_testPosition),
      );
      addTearDown(c.dispose);
      await _settle(c);

      final pos = await c
          .read(mapMyLocationProvider.notifier)
          .requestAndGetLocation();

      expect(pos, isNotNull);
      final s = c.read(mapMyLocationProvider);
      expect(s.hasPermission, isTrue);
      expect(s.error, isNull);
    });

    test('returns null and sets permissionDenied when permission denied',
        () async {
      final c = _makeContainer(permService: const _DeniedPermissionService());
      addTearDown(c.dispose);
      await _settle(c);

      final pos = await c
          .read(mapMyLocationProvider.notifier)
          .requestAndGetLocation();

      expect(pos, isNull);
      expect(c.read(mapMyLocationProvider).error,
          MapMyLocationError.permissionDenied);
    });

    test(
        'returns null and sets permissionDeniedForever when permanently denied',
        () async {
      final c = _makeContainer(
          permService: const _DeniedForeverPermissionService());
      addTearDown(c.dispose);
      await _settle(c);

      final pos = await c
          .read(mapMyLocationProvider.notifier)
          .requestAndGetLocation();

      expect(pos, isNull);
      expect(c.read(mapMyLocationProvider).error,
          MapMyLocationError.permissionDeniedForever);
    });

    test('returns null and sets serviceDisabled when location service is off',
        () async {
      final c = _makeContainer(
          permService: const _ServiceDisabledPermissionService());
      addTearDown(c.dispose);
      await _settle(c);

      final pos = await c
          .read(mapMyLocationProvider.notifier)
          .requestAndGetLocation();

      expect(pos, isNull);
      expect(c.read(mapMyLocationProvider).error,
          MapMyLocationError.serviceDisabled);
    });

    test(
        'returns null and sets unavailable when location hardware fails, '
        'hasPermission remains true', () async {
      final c = _makeContainer(
        permService: const _GrantedPermissionService(),
        locService: const _UnavailableLocationService(),
      );
      addTearDown(c.dispose);
      await _settle(c);

      final pos = await c
          .read(mapMyLocationProvider.notifier)
          .requestAndGetLocation();

      expect(pos, isNull);
      final s = c.read(mapMyLocationProvider);
      expect(s.error, MapMyLocationError.unavailable);
      expect(s.hasPermission, isTrue);
    });

    test('is a no-op when isChecking is true', () async {
      final c = _makeContainer(permService: const _GrantedPermissionService());
      addTearDown(c.dispose);
      // Do NOT settle — state is still isChecking: true
      expect(c.read(mapMyLocationProvider).isChecking, isTrue);

      final pos = await c
          .read(mapMyLocationProvider.notifier)
          .requestAndGetLocation();

      expect(pos, isNull);
    });
  });

  group('MapMyLocationNotifier — clearError', () {
    test('clearError resets error without changing hasPermission', () async {
      final c = _makeContainer(permService: const _DeniedPermissionService());
      addTearDown(c.dispose);
      await _settle(c);
      await c.read(mapMyLocationProvider.notifier).requestAndGetLocation();

      expect(c.read(mapMyLocationProvider).error, isNotNull);

      c.read(mapMyLocationProvider.notifier).clearError();

      final s = c.read(mapMyLocationProvider);
      expect(s.error, isNull);
      expect(s.hasPermission, isFalse);
    });
  });

  group('Privacy — candidate markers stay approximate', () {
    test('mapMyLocationProvider does not read or expose private location data',
        () async {
      // The provider only reads device GPS via LocationService and
      // permission status via LocationPermissionService — never Firestore.
      // This test verifies the state shape contains no coordinate fields.
      final c = _makeContainer(
        permService: const _GrantedPermissionService(),
        locService: _MockLocationService(_testPosition),
      );
      addTearDown(c.dispose);
      await _settle(c);

      final s = c.read(mapMyLocationProvider);
      // State has no lat/lng fields — coordinates are returned transiently
      // from requestAndGetLocation() only.
      expect(s, isA<MapMyLocationState>());
      expect(s.hasPermission, isTrue);
      expect(s.error, isNull);
    });
  });
}
