import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_item.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_response.dart';
import 'package:flutter_poetry_app/features/feed/widgets/poem_feed_card.dart';

import '../../../helpers/feed_card_harness.dart';
import '../../../helpers/fixture_dio_client.dart';
import '../../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('PoemFeedCard guest excerpt', () {
    testWidgets('regression: a guest poem card shows its couplet lines',
        (tester) async {
      final body = loadJsonFixture('guest/discover_ur.json');
      final apiPoem = ((body['data'] as Map<String, dynamic>)['featuredPoems']
              as List)
          .first as Map<String, dynamic>;
      final bundle = await tester.runAsync(() =>
          GuestService(FixtureDioClient(body)).getDiscoverBundle(lang: 'ur'));
      final item = FeedResponse.fromGuestBundle(bundle!)
          .items
          .firstWhere((i) => i.type == 'POEM');

      // Drop the CloudFront avatar URL so the test never opens an HttpClient.
      final data = (item.contentData as PoemContentData)
          .copyWith(poetProfileImageUrl: null);
      await pumpFeedCard(
        tester,
        PoemFeedCard(item: item, data: data),
        appLang: 'ur',
      );

      final lines = (apiPoem['excerpt'] as String).split('\n');
      // A ghazal's title is its opening misra, so it shows as the title and
      // again as the first verse line; before the fix only the title showed.
      expect(lines.first, apiPoem['title']);
      expect(find.text(lines.first), findsNWidgets(2));
      expect(find.text(lines[1]), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a poem with no excerpt shows only its title', (tester) async {
      const item = FeedItem(
        type: 'POEM',
        publicId: 'p1',
        lang: 'en',
        contentData: PoemContentData(title: 'The Rain', poetName: 'Faiz'),
      );
      await pumpFeedCard(
        tester,
        PoemFeedCard(item: item, data: item.contentData as PoemContentData),
      );
      expect(find.text('The Rain'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
