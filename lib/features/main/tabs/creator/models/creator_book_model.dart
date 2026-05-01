import '_json_helpers.dart';

class CreatorBook {
  const CreatorBook({
    required this.publicId,
    required this.title,
    this.yearPublished,
    this.description,
    this.publisher,
    this.languageCode = 'ur',
    this.coverUrl,
    this.pdfUrl,
    this.epubUrl,
    this.hasPdf = false,
    this.hasEpub = false,
    this.isDownloadable = false,
    this.pdfDownloads = 0,
    this.epubDownloads = 0,
  });

  final String publicId;
  final String title;
  final int? yearPublished;
  final String? description;
  final String? publisher;
  final String languageCode;
  final String? coverUrl;
  final String? pdfUrl;
  final String? epubUrl;
  final bool hasPdf;
  final bool hasEpub;
  final bool isDownloadable;
  final int pdfDownloads;
  final int epubDownloads;

  factory CreatorBook.fromJson(Map<String, dynamic> json) {
    return CreatorBook(
      publicId: json['publicId'] as String,
      title: (json['title'] as String?) ?? '',
      yearPublished: (json['yearPublished'] as num?)?.toInt(),
      description: nullableStr(json['description']),
      publisher: nullableStr(json['publisher']),
      languageCode: (json['languageCode'] as String?) ?? 'ur',
      coverUrl: nullableStr(json['coverUrl']),
      pdfUrl: nullableStr(json['pdfUrl']),
      epubUrl: nullableStr(json['epubUrl']),
      hasPdf: json['hasPdf'] as bool? ?? false,
      hasEpub: json['hasEpub'] as bool? ?? false,
      isDownloadable: json['isDownloadable'] as bool? ?? false,
      pdfDownloads: (json['pdfDownloads'] as num?)?.toInt() ?? 0,
      epubDownloads: (json['epubDownloads'] as num?)?.toInt() ?? 0,
    );
  }
}
