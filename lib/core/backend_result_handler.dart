import 'package:flutter/material.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;

class BackendResultHandler {
  static void handle(BuildContext context, backmsg.ResultT result) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return;

    String? message;
    bool isSuccess = false;

    switch (result.errorCode) {
      case backmsg.ErrorCode.OK:
        if (result.success) {
          isSuccess = true;
          // For generic OK, we only show a snackbar if there is an explicit message
          // or if it's a known success case. Otherwise it might be too noisy.
          if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
            message = result.errorMessage;
          }
        }
        break;
      case backmsg.ErrorCode.UNKNOWN_ERROR:
        message = loc.errorUnknown;
        break;
      case backmsg.ErrorCode.INVALID_CREDENTIALS:
        message = loc.errorInvalidCredentials;
        break;
      case backmsg.ErrorCode.CONFIG_ERROR:
        message = loc.errorConfigError;
        break;
      case backmsg.ErrorCode.INVALID_MESSAGE:
        message = loc.errorInvalidMessage;
        break;
      case backmsg.ErrorCode.ADD_TOKEN:
        if (result.success) {
          message = loc.adminTokenAddSuccess;
          isSuccess = true;
        } else {
          message = loc.errorAddToken;
        }
        break;
      case backmsg.ErrorCode.FACE_TRAINING_SUCCESS:
        message = loc.errorFaceTrainingSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.FACE_TRAINING_FAILED:
        message = loc.errorFaceTrainingFailed;
        break;
      case backmsg.ErrorCode.ADD_CREATE_USER_SUCCESS:
        message = loc.errorAddCreateUserSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.ADD_CREATE_USER_FAILED:
        message = loc.errorAddCreateUserFailed;
        break;
      case backmsg.ErrorCode.UNAUTHORIZED:
        message = loc.errorUnauthorized;
        break;
      case backmsg.ErrorCode.SERVICE_NOT_AVAILABLE:
        message = loc.errorServiceNotAvailable;
        break;
      case backmsg.ErrorCode.PASSWORD_CHANGE_SUCCESS:
        message = loc.passwordChangeSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.PASSWORD_CHANGE_FAIL:
        message = loc.passwordChangeError;
        break;
      case backmsg.ErrorCode.FRONTEND_UPDATED:
        message = loc.errorFrontendUpdated;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.BACKEND_UPDATED:
        message = loc.errorBackendUpdated;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.UPDATED_FAILED:
        message = loc.errorUpdateFailed;
        break;
      case backmsg.ErrorCode.DASHBOARD_OK:
        message = loc.dashboardUploadSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.DASHBOARD_ERROR:
        message = loc.dashboardUploadError;
        break;
      case backmsg.ErrorCode.VIEW_OK:
        message = loc.viewUploadSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.VIEW_ERROR:
        message = loc.viewUploadError;
        break;
      default:
        break;
    }

    if (message != null) {
      final showSubtitle = result.errorMessage != null &&
          result.errorMessage!.isNotEmpty &&
          result.errorMessage != message;

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showSubtitle)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    result.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
