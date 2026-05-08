import 'package:dio/dio.dart';

/// What the user is doing when an error happens — drives copy.
enum CreatorAction {
  composePoem,
  updatePoem,
  deletePoem,
  createPoetProfile,
  updatePoetProfile,
  claimPoet,
  uploadImage,
  updateImage,
  deleteImage,
  uploadBook,
  updateBook,
  deleteBook,
  addFact,
  deleteFact,
  addTranslation,
  updateTranslation,
}

/// Surface the backend's `message` field with a friendly override for
/// known status codes — the raw DioException text is never shown.
///
/// Keep messages short, actionable, and unambiguous. The default fallback
/// trusts the backend's `message` because the server already authored a
/// per-endpoint sentence (e.g. "Poem already exists: ...").
String friendlyApiMessage(Object error, CreatorAction action) {
  if (error is! DioException) {
    return _genericFor(action);
  }
  final status = error.response?.statusCode;
  final body = error.response?.data;
  final apiMessage = body is Map<String, dynamic>
      ? body['message']?.toString()
      : null;

  // Network-layer / no-response cases first.
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Slow connection — please try again.';
    case DioExceptionType.connectionError:
      return "Can't reach Sukhan right now. Check your connection.";
    case DioExceptionType.cancel:
      return 'Cancelled.';
    case DioExceptionType.badCertificate:
      return 'Could not establish a secure connection.';
    case DioExceptionType.unknown:
      if (error.response == null) {
        return "Something went wrong. Please try again.";
      }
      break;
    case DioExceptionType.badResponse:
      break;
  }

  // Auth + universal cases.
  if (status == 401 || status == 403) {
    return 'Your session expired — please sign in again.';
  }
  if (status == 500 || status == 502 || status == 503 || status == 504) {
    return 'Sukhan is having a moment. Try again in a few seconds.';
  }

  // Per-action overrides for known business cases.
  final actionSpecific = _actionSpecific(action, status, apiMessage);
  if (actionSpecific != null) return actionSpecific;

  // Fall back to the backend's own message if it's user-friendly enough,
  // otherwise to a per-action generic.
  if (apiMessage != null && apiMessage.isNotEmpty && !_looksLikeStackTrace(apiMessage)) {
    return apiMessage;
  }
  return _genericFor(action);
}

String? _actionSpecific(CreatorAction action, int? status, String? apiMessage) {
  switch (action) {
    case CreatorAction.composePoem:
      if (status == 409) {
        return "You've already published a poem with this title. "
            'Edit the existing one or change the title.';
      }
      if (status == 400) {
        return apiMessage ??
            "Some fields didn't pass validation. Check title and content.";
      }
      if (status == 404) {
        return 'Your poet profile is not set up yet.';
      }
      if (status == 413) {
        return 'The poem is too long to submit in one go.';
      }
      return null;

    case CreatorAction.updatePoem:
      if (status == 403) return "You can only edit your own poems.";
      if (status == 404) return 'Poem not found — it may have been deleted.';
      return null;

    case CreatorAction.deletePoem:
      if (status == 403) return "You can only delete your own poems.";
      if (status == 404) return 'Poem already removed.';
      return null;

    case CreatorAction.createPoetProfile:
      if (status == 409) {
        return 'You already have a poet profile. Open your dashboard from the profile tab.';
      }
      if (status == 400) {
        return apiMessage ?? 'Please fill in name and primary language.';
      }
      return null;

    case CreatorAction.updatePoetProfile:
      if (status == 404) return 'Your poet profile is not set up yet.';
      if (status == 400) return apiMessage ?? "Please check your inputs.";
      return null;

    case CreatorAction.claimPoet:
      if (status == 404) return 'That poet no longer exists.';
      if (status == 409) {
        if (apiMessage != null && apiMessage.toLowerCase().contains('already claimed')) {
          return 'This poet has already been claimed by someone else.';
        }
        return 'You already own a poet profile — only one claim per account.';
      }
      if (status == 400) {
        return apiMessage ?? 'Please paste a valid http(s) URL as proof.';
      }
      return null;

    case CreatorAction.uploadImage:
      if (status == 413) return 'Image is too large. Try one under 10 MB.';
      if (status == 415) return 'Only JPG, PNG, or WebP images are accepted.';
      if (status == 404) return 'Your poet profile is not set up yet.';
      return null;

    case CreatorAction.updateImage:
      if (status == 403) return "You can only edit images on your own page.";
      if (status == 404) return 'Image already removed.';
      return null;

    case CreatorAction.deleteImage:
      if (status == 403) return "You can only delete images on your own page.";
      if (status == 404) return 'Image already removed.';
      return null;

    case CreatorAction.uploadBook:
      if (status == 413) {
        return 'File is too large. Try a smaller PDF or EPUB.';
      }
      if (status == 415) {
        return 'Only PDF or EPUB files are accepted for the book file.';
      }
      if (status == 404) return 'Your poet profile is not set up yet.';
      return null;

    case CreatorAction.updateBook:
      if (status == 403) return "You can only edit your own books.";
      if (status == 404) return 'Book already removed.';
      return null;

    case CreatorAction.deleteBook:
      if (status == 403) return "You can only delete your own books.";
      if (status == 404) return 'Book already removed.';
      return null;

    case CreatorAction.addFact:
      if (status == 400) return apiMessage ?? 'Please write a non-empty fact.';
      if (status == 404) return 'Your poet profile is not set up yet.';
      return null;

    case CreatorAction.deleteFact:
      if (status == 403) return "You can only delete your own facts.";
      if (status == 404) return 'Fact already removed.';
      return null;

    case CreatorAction.addTranslation:
      if (status == 409) {
        return 'You already have a translation for this language. '
            'Edit it instead of adding a new one.';
      }
      if (status == 400) return apiMessage ?? 'Please check the language and name fields.';
      return null;

    case CreatorAction.updateTranslation:
      if (status == 404) {
        return 'Add this language first before editing it.';
      }
      return null;
  }
}

String _genericFor(CreatorAction action) {
  switch (action) {
    case CreatorAction.composePoem:
      return "Couldn't publish — please try again.";
    case CreatorAction.updatePoem:
      return "Couldn't save changes to your poem.";
    case CreatorAction.deletePoem:
      return "Couldn't delete this poem.";
    case CreatorAction.createPoetProfile:
      return "Couldn't create your poet profile.";
    case CreatorAction.updatePoetProfile:
      return "Couldn't save your profile changes.";
    case CreatorAction.claimPoet:
      return "Couldn't submit your claim.";
    case CreatorAction.uploadImage:
      return "Couldn't upload the image.";
    case CreatorAction.updateImage:
      return "Couldn't update the image.";
    case CreatorAction.deleteImage:
      return "Couldn't delete the image.";
    case CreatorAction.uploadBook:
      return "Couldn't upload the book.";
    case CreatorAction.updateBook:
      return "Couldn't update the book.";
    case CreatorAction.deleteBook:
      return "Couldn't delete the book.";
    case CreatorAction.addFact:
      return "Couldn't add this fact.";
    case CreatorAction.deleteFact:
      return "Couldn't delete this fact.";
    case CreatorAction.addTranslation:
      return "Couldn't add this translation.";
    case CreatorAction.updateTranslation:
      return "Couldn't save the translation.";
  }
}

/// A loose heuristic for backend messages that look like internal traces
/// rather than user-facing copy (we never want to show those).
bool _looksLikeStackTrace(String s) {
  final lower = s.toLowerCase();
  return lower.contains('exception:') ||
      lower.contains('java.') ||
      lower.contains('at com.') ||
      lower.contains('null pointer') ||
      lower.contains('sql') ||
      lower.length > 240;
}
