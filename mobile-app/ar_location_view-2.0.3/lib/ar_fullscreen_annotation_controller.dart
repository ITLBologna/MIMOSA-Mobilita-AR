import 'package:ar_location_view/ar_annotation.dart';
import 'package:get/get.dart';

class ArFullscreenAnnotationController extends GetxController {
  final annotationUid = ''.obs;

  List<ArAnnotation> calculateAnnotationsToShow(List<ArAnnotation> annotations) {
    final fullscreens = annotations.where((a) => a.uid == annotationUid.value).toList();
    if(fullscreens.isNotEmpty) {
      return fullscreens;
    }

    return annotations;
  }
}
