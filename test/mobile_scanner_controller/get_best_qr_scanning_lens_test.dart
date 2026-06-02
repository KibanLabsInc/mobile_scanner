import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/src/enums/camera_facing.dart';
import 'package:mobile_scanner/src/enums/camera_lens_type.dart';
import 'package:mobile_scanner/src/enums/mobile_scanner_error_code.dart';
import 'package:mobile_scanner/src/mobile_scanner_controller.dart';
import 'package:mobile_scanner/src/mobile_scanner_exception.dart';
import 'package:mobile_scanner/src/mobile_scanner_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getBestQrScanningLens', () {
    test('throws when controller is disposed', () async {
      MobileScannerPlatform.instance = FakeMobileScannerPlatform(
        CameraLensType.normal,
      );

      final controller = MobileScannerController(autoStart: false);

      await controller.dispose();

      expect(
        controller.getBestQrScanningLens,
        throwsA(
          isA<MobileScannerException>().having(
            (e) => e.errorCode,
            'errorCode',
            MobileScannerErrorCode.controllerDisposed,
          ),
        ),
      );
    });

    test('returns best lens from platform', () async {
      MobileScannerPlatform.instance = FakeMobileScannerPlatform(
        CameraLensType.wide,
      );

      final controller = MobileScannerController(autoStart: false);

      final lens = await controller.getBestQrScanningLens();

      expect(lens, CameraLensType.wide);
    });

    test('returns normal lens as default from platform', () async {
      MobileScannerPlatform.instance = FakeMobileScannerPlatform(
        CameraLensType.normal,
      );

      final controller = MobileScannerController(autoStart: false);

      final lens = await controller.getBestQrScanningLens();

      expect(lens, CameraLensType.normal);
    });

    test('passes facing parameter to platform', () async {
      final fakePlatform = FakeMobileScannerPlatformWithFacingCapture(
        CameraLensType.wide,
      );
      MobileScannerPlatform.instance = fakePlatform;

      final controller = MobileScannerController(autoStart: false);

      await controller.getBestQrScanningLens(facing: CameraFacing.front);

      expect(fakePlatform.capturedFacing, CameraFacing.front);
    });
  });
}

class FakeMobileScannerPlatform extends MobileScannerPlatform {
  FakeMobileScannerPlatform(CameraLensType bestLens) : _bestLens = bestLens;

  final CameraLensType _bestLens;

  @override
  Future<CameraLensType> getBestQrScanningLens({
    CameraFacing facing = CameraFacing.back,
  }) {
    return Future.value(_bestLens);
  }

  @override
  Future<Set<CameraLensType>> getSupportedLenses({CameraFacing? facing}) {
    return Future.value(const <CameraLensType>{});
  }

  @override
  Future<void> dispose() {
    // No-op.
    return Future.value();
  }
}

class FakeMobileScannerPlatformWithFacingCapture extends MobileScannerPlatform {
  FakeMobileScannerPlatformWithFacingCapture(CameraLensType bestLens)
    : _bestLens = bestLens;

  final CameraLensType _bestLens;
  CameraFacing? capturedFacing;

  @override
  Future<CameraLensType> getBestQrScanningLens({
    CameraFacing facing = CameraFacing.back,
  }) {
    capturedFacing = facing;
    return Future.value(_bestLens);
  }

  @override
  Future<Set<CameraLensType>> getSupportedLenses({CameraFacing? facing}) {
    return Future.value(const <CameraLensType>{});
  }

  @override
  Future<void> dispose() {
    // No-op.
    return Future.value();
  }
}
