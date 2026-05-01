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
      description: json['description'] as String?,
      publisher: json['publisher'] as String?,
      languageCode: (json['languageCode'] as String?) ?? 'ur',
      coverUrl: json['coverUrl'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      epubUrl: json['epubUrl'] as String?,
      hasPdf: json['hasPdf'] as bool? ?? false,
      hasEpub: json['hasEpub'] as bool? ?? false,
      isDownloadable: json['isDownloadable'] as bool? ?? false,
      pdfDownloads: (json['pdfDownloads'] as num?)?.toInt() ?? 0,
      epubDownloads: (json['epubDownloads'] as num?)?.toInt() ?? 0,
    );
  }
}
