import '../../../core/utils/api_placeholder.dart';

/// A name picked for display, with the language it is written in, so the
/// caller can style it in that language's script (Nastaliq for `ur`,
/// Devanagari for `hi`) even when it is a fallback from another language.
typedef LocalizedLabel = ({String text, String languageCode});

/// The name to show in app language [appLanguage]: the name in that language,
/// else the Urdu name, else the English one. Blank and `"-"` names are
/// absent. Returns null when there is no name at all — callers never fall
/// back to a slug.
LocalizedLabel? pickLocalizedName(
  String appLanguage, {
  String? ur,
  String? en,
  String? hi,
}) {
  final names = <String, String?>{
    'ur': presentOrNull(ur),
    'en': presentOrNull(en),
    'hi': presentOrNull(hi),
  };
  for (final lang in [appLanguage.toLowerCase(), 'ur', 'en']) {
    final name = names[lang];
    if (name != null) return (text: name, languageCode: lang);
  }
  return null;
}
