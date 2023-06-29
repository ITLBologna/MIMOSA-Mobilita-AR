import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Used to determine when a annotation is highlighted
enum HighlightMode {
  never,
  nearest,
  always
}

class ArAnnotation<T> {
  ArAnnotation({
    required this.data,
    required this.uid,
    required this.position,
    required this.angle,
    this.azimuth = 0,
    this.distanceFromUserInMeters = 0,
    this.maxVisibleDistance,
    this.scaleWithDistance,
    this.canOverlayOtherAnnotations = false,
    this.highlightMode = HighlightMode.never,
    this.highlighted = false,
    this.isGrayed = false,
    this.isPinned = false,
    this.isVisible = true,
    this.arPosition = const Offset(0, 0),
    this.radarMarkerColorHex = 0xFFFF0000,
    this.customPositioned = false
  });

  final T data;
  final String uid;
  final HighlightMode highlightMode;
  Position position;
  double azimuth;
  double angle;
  double distanceFromUserInMeters;
  double? maxVisibleDistance;
  bool? scaleWithDistance;
  bool canOverlayOtherAnnotations;
  bool isVisible;
  bool isGrayed;
  bool isPinned;
  Offset arPosition;
  int radarMarkerColorHex;
  bool highlighted;
  bool customPositioned;

  ArAnnotation<T> copyWith({
    HighlightMode? highlightMode,
    Position? position,
    double? angle,
    double? azimuth,
    double? distanceFromUserInMeters,
    double? maxVisibleDistance,
    bool? isVisible,
    bool? isGrayed,
    bool? isPinned,
    bool? scaleWithDistance,
    bool? canOverlayOtherAnnotations,
    Offset? arPosition,
    int? radarMarkerColorHex,
    bool? highlighted,
    String? text,
    T? data}) {
    return ArAnnotation<T>(
        uid: uid,
        highlightMode: highlightMode ?? this.highlightMode,
        position: position ?? this.position,
        angle: angle ?? this.angle,
        azimuth: azimuth ?? this.azimuth,
        distanceFromUserInMeters: distanceFromUserInMeters ?? this.distanceFromUserInMeters,
        maxVisibleDistance: maxVisibleDistance ?? this.maxVisibleDistance,
        isVisible: isVisible ?? this.isVisible,
        isGrayed: isGrayed ?? this.isGrayed,
        isPinned: isPinned ?? this.isPinned,
        scaleWithDistance: scaleWithDistance ?? this.scaleWithDistance,
        canOverlayOtherAnnotations: canOverlayOtherAnnotations ?? this.canOverlayOtherAnnotations,
        arPosition: arPosition ?? this.arPosition,
        radarMarkerColorHex: radarMarkerColorHex ?? this.radarMarkerColorHex,
        highlighted: highlighted ?? this.highlighted,
        data: data ?? this.data
    );
  }


  @override
  String toString() {
    return 'Annotation{position: $position, azimuth: $azimuth, distanceFromUser: $distanceFromUserInMeters, isVisible: $isVisible, highlighted: $highlighted, arPosition: $arPosition}';
  }
}
