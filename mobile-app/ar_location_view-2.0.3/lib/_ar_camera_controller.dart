import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraControllerState {
  disposed,
  initializing,
  initialized
}

class ArCameraController {
  CameraController? controller;
  CameraControllerState controllerState = CameraControllerState.disposed;


  Future<Validation<CameraController>> init() {
    controllerState = CameraControllerState.initializing;
    controller?.dispose();
    return _initializeCamera();
  }

  void dispose() {
    controllerState = CameraControllerState.disposed;
    controller?.dispose();
    controller = null;
  }

  Future<void>? pausePreview() {
    return controller?.pausePreview();
  }

  Future<void>? resumePreview() {
    return controller?.resumePreview();
  }

  Future<Validation<bool>> _requestCameraAuthorization() {
    return Permission
            .camera
            .isGranted
            .then(
              (value) => Valid(value)
            )
            .mapFuture((isGranted) =>
              isGranted
                ? Future(() => isGranted)
                : Permission.camera.request().then((_) => Permission.camera.isGranted)
            )
            .bind((isGranted) =>
              isGranted
                ? Valid(isGranted)
                : Fail.withError(Error()).toInvalid()
            );
  }

  Future<Validation<CameraController>> _initializeCamera() async {
    return _requestCameraAuthorization()
        .mapFuture((_) => availableCameras())
        .mapFuture((cameras) {
          controller = CameraController(
            cameras[0],
            ResolutionPreset.max,
            enableAudio: false,
          );

          return controller!
                    .initialize()
                    .then((value) {
                      controllerState = CameraControllerState.initialized;
                      return controller!;
                    });
        })
        .map((_)
          => controller!)
        .tryCatch();
  }
}