// Copyright 2013, the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'options.dart';

///
/// A convenient class wraps all api functions of **ImageCropper** plugin
///
class ImageCropper {
  static const MethodChannel _channel =
      const MethodChannel('plugins.hunghd.vn/image_cropper');

  ///
  /// Launch cropper UI for an image.
  ///
  ///
  /// **parameters:**
  ///
  /// * sourcePath: the absolute path of an image file.
  ///
  /// * maxWidth: maximum cropped image width.
  ///
  /// * maxHeight: maximum cropped image height.
  ///
  /// * aspectRatio: controls the aspect ratio of crop bounds. If this values is set,
  /// the cropper is locked and user can't change the aspect ratio of crop bounds.
  ///
  /// * aspectRatioPresets: controls the list of aspect ratios in the crop menu view.
  /// In Android, you can set the initialized aspect ratio when starting the cropper
  /// by setting the value of [AndroidUiSettings.initAspectRatio]. Default is a list of
  /// [CropAspectRatioPreset.original], [CropAspectRatioPreset.square],
  /// [CropAspectRatioPreset.ratio3x2], [CropAspectRatioPreset.ratio4x3] and
  /// [CropAspectRatioPreset.ratio16x9].
  ///
  /// * cropStyle: controls the style of crop bounds, it can be rectangle or
  /// circle style (default is [CropStyle.rectangle]).
  ///
  /// * compressFormat: the format of result image, png or jpg (default is [ImageCompressFormat.jpg])
  ///
  /// * compressQuality: the value [0 - 100] to control the quality of image compression
  ///
  /// * androidUiSettings: controls UI customization on Android. See [AndroidUiSettings].
  ///
  /// * iosUiSettings: controls UI customization on iOS. See [IOSUiSettings].
  ///
  ///
  /// **return:**
  ///
  /// A result file of the cropped image.
  ///
  /// Note: The result file is saved in NSTemporaryDirectory on iOS and application Cache directory
  /// on Android, so it can be lost later, you are responsible for storing it somewhere
  /// permanent (if needed).
  ///
  static Future<CropInfo?> cropImageWithCoordinates({
    required String sourcePath,
    int? maxWidth,
    int? maxHeight,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset> aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    AndroidUiSettings? androidUiSettings,
    IOSUiSettings? iosUiSettings,
  }) async {
    assert(await File(sourcePath).exists());
    assert(maxWidth == null || maxWidth > 0);
    assert(maxHeight == null || maxHeight > 0);
    assert(compressQuality >= 0 && compressQuality <= 100);

    final arguments = <String, dynamic>{
      'source_path': sourcePath,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'ratio_x': aspectRatio?.ratioX,
      'ratio_y': aspectRatio?.ratioY,
      'aspect_ratio_presets':
          aspectRatioPresets.map<String>(aspectRatioPresetName).toList(),
      'crop_style': cropStyleName(cropStyle),
      'compress_format': compressFormatName(compressFormat),
      'compress_quality': compressQuality,
    }
      ..addAll(androidUiSettings?.toMap() ?? {})
      ..addAll(iosUiSettings?.toMap() ?? {});

    final String? resultPath =
        await _channel.invokeMethod('cropImage', arguments);

    if (resultPath == null) return null;

    var splitResult = resultPath.split("|\\|");
    
    print('Mariano.py - resultPath: ' + resultPath);
    
    print('Mariano.py - width: ' + splitResult[3]);
    print('Mariano.py - cropper.dart angle: ' + splitResult[5]);

    return CropInfo(
      path: splitResult[0],
      x: int.parse(splitResult[1]),
      y: int.parse(splitResult[2]),
      width: int.parse(splitResult[3]),
      height: int.parse(splitResult[4]),
      angle: int.parse(splitResult[5]),
    );
  }
}

class CropInfo {
  final String path;
  final int x, y, width, height;
  final int angle;
  
  get minX => x;
  get minY => y;

  get maxX => x + width;
  get maxY => y + height;

  CropInfo(
      {required this.path,
      required this.x,
      required this.y,
      required this.width,
      required this.height,
      required this.angle});
}
