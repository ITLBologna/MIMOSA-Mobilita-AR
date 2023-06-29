/*
 * Copyright 2022-2023 bitApp S.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Mimosa APP
 *
 *
 * Contact: info@bitapp.it
 *
 */

import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keymap/keymap.dart';
import 'package:mimosa/business_logic/services/interfaces/i_error_handler.dart';
import 'package:mimosa/ui/extensions/color_extensions.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

const kDialogBarrierColor = Color(0x88444444);

enum DialogExType {
  noActions,
  ok,
  okCancel,
  okCancelDestructive,
  retry,
  exitRetry
}

Future<bool?> showAlertDialogEx(
    BuildContext context,
    {
      required String progressIndicatorTag,
      DialogExType type = DialogExType.ok,
      required String title,
      required String message,
      IErrorHandler? errorFormatter,
      String? cancelText,
      String? confirmText,
      bool? animateProgressOnStart = false,
      Future<Validation> Function()? confirmAction,
      Future<Validation> Function()? cancelAction,
      Widget Function(BuildContext context)? getBodyWidget
    })
{
  final alert = AlertDialogEx(
    type: type,
    title: title,
    message: message,
    errorFormatter: errorFormatter,
    cancelText: cancelText ?? (type == DialogExType.exitRetry ? 'Esci' : 'Annulla'),
    confirmText: confirmText ?? ((type == DialogExType.retry || type == DialogExType.exitRetry) ? 'Riprova' : 'OK'),
    actionConfirmed: confirmAction,
    actionCancelled: cancelAction,
    animateProgressOnStart: animateProgressOnStart,
    getBodyWidget: getBodyWidget,
    progressIndicatorTag: progressIndicatorTag,);

  return _showDialog(context, alert);
}


Future<bool?> _showDialog (BuildContext context, Widget widget) {
  return showDialog<bool>(
    barrierDismissible: false,
    barrierColor: kDialogBarrierColor,
    context: context,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

void _onCancel(DialogExType type)
{
  if(type == DialogExType.exitRetry)
  {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
  else
  {
    Get.back(result: false);
  }
}

void _onOKPressed(
    BuildContext context,
    {
      IErrorHandler? errorFormatter,
      GlobalKey<FormState>? formKey,
      Future<Validation> Function()? actionConfirmed,
      required String progressIndicatorTag
    })
{
  _onAction(
      context,
      result: true,
      errorFormatter: errorFormatter,
      formKey: formKey,
      action: actionConfirmed,
      progressIndicatorTag: progressIndicatorTag
  );
}

void _onCancelPressed(
    BuildContext context,
    {
      IErrorHandler? errorFormatter,
      GlobalKey<FormState>? formKey,
      Future<Validation> Function()? actionCancelled,
      required String progressIndicatorTag
    })
{
  _onAction(
      context,
      errorFormatter: errorFormatter,
      result: false,
      formKey: formKey,
      action: actionCancelled,
      progressIndicatorTag: progressIndicatorTag
  );
}

void _onAction(
    BuildContext context,
    {
      required bool result,
      required String progressIndicatorTag,
      IErrorHandler? errorFormatter,
      GlobalKey<FormState>? formKey,
      Future<Validation> Function()? action,
    })
{
  if(formKey == null || formKey.currentState!.validate())
  {
    if(action != null)
    {
      final ProgressIndicatorController controller = Get.find(tag: progressIndicatorTag);
      controller.animating.value = true;
      action()
          .fold(
              (failures) {
                controller.animating.value = false;
                showAlertDialogEx(
                    context,
                    progressIndicatorTag: '$progressIndicatorTag error',
                    type: DialogExType.ok,
                    title: 'Error',
                    message: errorFormatter != null
                        ? errorFormatter.failsFormatError(failures)
                        : failures.first.toString()
                );
              },
            (val) => Get.back(result: true));
    }
    else {
      Get.back(result: result);
    }
  }
}

class ProgressIndicatorController extends GetxController {
  final animating = false.obs;
}

const kAlertGray = Color(0xFF4d4d4d);

const kDefaultAlertFontSize = 16.0;
const kTitlePadding = 15.0;
const kTitleBottomPadding = 5.0;
const kLitePaddingLR = 10.0;
const kDefaultMessageFontSize = 14.0;

class DialogEx<T> extends StatelessWidget {
  final ProgressIndicatorController progressController;
  final DialogExType type;
  final String title;
  final String confirmText;
  final String cancelText;
  final String? progressIndicatorTag;
  final bool? animateProgressOnStart;
  final Color? destructiveColor;
  final Color? desiredActionColor;
  final Widget Function(BuildContext) getBodyWidget;
  final void Function()? onOKPressed;
  final void Function()? onCancelPressed;

  DialogEx({
    Key? key,
    required this.type,
    required this.title,
    required this.getBodyWidget,
    this.destructiveColor,
    this.desiredActionColor,
    this.progressIndicatorTag,
    this.animateProgressOnStart = false,
    this.confirmText = 'OK',
    this.cancelText = 'Annulla',
    this.onOKPressed,
    this.onCancelPressed}) :
        progressController = Get.put(ProgressIndicatorController(), tag: progressIndicatorTag),
        super(key: key) {
    progressController.animating.value = animateProgressOnStart!;
  }

  void onCancel() {
    if(!progressController.animating.value) {
      onCancelPressed ?? () => _onCancel(type);
    }
  }

  void onConfirm() {
    if(!progressController.animating.value) {
      onOKPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dColor = destructiveColor ?? Theme.of(context).errorColor;
    bool okIsDestructive = type == DialogExType.okCancelDestructive;
    final okButtonBackgroundColor = okIsDestructive
        ? dColor
        : (desiredActionColor ?? Theme.of(context).primaryColor);

    final okButtonOverlayColor = okIsDestructive ? Colors.red[700]! : Theme.of(context).primaryColorLight;

    final okBorderRadius = type == DialogExType.ok || type == DialogExType.retry
        ? const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
        : const BorderRadius.only(bottomRight: Radius.circular(15));

    final cancelButtonBackgroundColor = Theme.of(context).disabledColor;
    final cancelButtonOverlayColor = Colors.grey[300]!;

    Widget okButton = Expanded(
      child: Obx(()
      => TextButton(
          style:
          ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: okBorderRadius,
                  )
              ),
              backgroundColor: okButtonBackgroundColor.toMaterialState(),
              overlayColor: okButtonOverlayColor.toMaterialState()
          ),
          onPressed: progressController.animating.value ? null : onOKPressed,
          child: AutoSizeText(confirmText,
            style: const TextStyle(
              // fontSize: kDefaultAlertFontSize,
              color: Colors.white
            ),
            maxLines: 2,
          )
      )
      ),
    );

    Widget cancelButton = Expanded(
      child: Obx(()
      => TextButton(
          style:
          ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15)),
                  )
              ),
              backgroundColor: cancelButtonBackgroundColor.toMaterialState(),
              overlayColor: cancelButtonOverlayColor.toMaterialState()
          ),
          onPressed: progressController.animating.value ? null : onCancelPressed ?? () => _onCancel(type),
          child: AutoSizeText(cancelText,
              style: const TextStyle(
                // fontSize: kDefaultAlertFontSize,
                color: Colors.white
              )
          )
      )
      ),
    );

    List<Widget> actions = [];

    if(type == DialogExType.ok || type == DialogExType.retry)
    {
      actions = [okButton];
    }
    else if(type != DialogExType.noActions)
    {
      actions = [cancelButton, const VerticalDivider(width: 3, thickness: 3, color: Colors.white), okButton];
    }

    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      insetPadding: const EdgeInsets.all(60),
      elevation: 0,
      content:
      KeyboardWidget(
        bindings: [
          KeyAction(LogicalKeyboardKey.escape, '', () {
            onCancel();
          }),
          KeyAction(LogicalKeyboardKey.backspace, '', () {
            onCancel();
          }),
          KeyAction(LogicalKeyboardKey.enter, '', () {
            onConfirm();
          })
        ],
          child: SizedBox(
            width: min(400, MediaQuery.of(context).size.width),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: kTitlePadding,
                      left: kTitlePadding,
                      right: kTitlePadding,
                      bottom: kTitleBottomPadding),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        // color: kAlertGray,
                        fontWeight: FontWeight.bold,
                        // fontSize: kDefaultAlertFontSize
                    ),
                  ),
                ),

                Obx(() => progressController.animating.value
                    ? LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(okButtonBackgroundColor),
                )
                    : LinearProgressIndicator(
                  minHeight: 3,
                  value: 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(okButtonBackgroundColor),)
                ),

                Padding(
                  padding: const EdgeInsets.all(kTitlePadding),
                  child: getBodyWidget(context),
                ),
                Container(
                  margin: const EdgeInsets.only(top: kLitePaddingLR),
                  height: 40,
                  decoration: const BoxDecoration(
                    backgroundBlendMode: BlendMode.dstOver,
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0)),
                  ),
                  // Il pointer interceptor serve per il web, qualora i pulsanti si sovrapponessero
                  // a un HtmlElement che altrimenti catturerebbe l'input del mouse
                  child: PointerInterceptor(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: actions,
                    ),
                  ),
                ),
              ]
      ),
          ),
        ),
      // actions: actions,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }
}

class AlertDialogEx extends StatelessWidget {
  final String dialogId;
  final String message;
  final DialogExType type;
  final String title;
  final Color destructiveColor;
  final Color? desiredActionColor;
  final String? confirmText;
  final String? cancelText;
  final String progressIndicatorTag;
  final bool? animateProgressOnStart;
  final IErrorHandler? errorFormatter;
  final Future<Validation> Function()? actionConfirmed;
  final Future<Validation> Function()? actionCancelled;
  final Widget Function(BuildContext context)? getBodyWidget;

  const AlertDialogEx({
    Key? key,
    required this.message,
    required this.type,
    required this.title,
    required this.progressIndicatorTag,
    this.errorFormatter,
    this.dialogId = '',
    this.destructiveColor = Colors.red,
    this.desiredActionColor,
    this.confirmText = 'OK',
    this.cancelText = 'Annulla',
    this.actionConfirmed,
    this.actionCancelled,
    this.animateProgressOnStart = false,
    this.getBodyWidget
  }
      ) : super (key: key);

  @override Widget build(BuildContext context) {
    return DialogEx<bool>(
      animateProgressOnStart: animateProgressOnStart,
      type: type,
      title: title,
      destructiveColor: destructiveColor,
      desiredActionColor: desiredActionColor,
      confirmText: confirmText!,
      cancelText: cancelText!,
      progressIndicatorTag: progressIndicatorTag,
      onOKPressed: () => _onOKPressed(
            context,
            errorFormatter: errorFormatter,
            actionConfirmed: actionConfirmed,
            progressIndicatorTag: progressIndicatorTag),
      onCancelPressed:() => _onCancelPressed(
          context,
          errorFormatter: errorFormatter,
          actionCancelled: actionCancelled,
          progressIndicatorTag: progressIndicatorTag),
      getBodyWidget: getBodyWidget ?? (context)
      =>  Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
          // style: const TextStyle(
          //     color: kAlertGray,
          //     fontSize: kDefaultMessageFontSize
          // )
      ),
    );
  }
}