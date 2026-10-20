import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../search/helpers/search_test_harness.dart';

void main() {
  group('"-" userReaction means no reaction (T-181)', () {
    test('regression: the real search fixture sends "-" for poems', () {
      final poem = (searchFixture('unified_search_dil_ur.json')['data']
          as Map<String, dynamic>)['poems'][0] as Map<String, dynamic>;
      final reactions = poem['reactions'] as Map<String, dynamic>;
      expect(reactions['userReaction'], '-');
      expect(userReactionIn(reactions), isNull);
    });

    test('userReactionIn: present, absent, null, blank, non-string', () {
      expect(userReactionIn({'userReaction': 'LIKE'}), 'LIKE');
      expect(userReactionIn(const {}), isNull);
      expect(userReactionIn(null), isNull);
      expect(userReactionIn({'userReaction': null}), isNull);
      expect(userReactionIn({'userReaction': ' '}), isNull);
      expect(userReactionIn({'userReaction': 3}), isNull);
    });

    test('ReactionSummary.fromJson', () {
      expect(
          ReactionSummary.fromJson(const {'total': 2, 'userReaction': '-'})
              .hasUserReacted,
          isFalse);
      expect(
          ReactionSummary.fromJson(const {'total': 2, 'userReaction': 'WAH'})
              .hasUserReacted,
          isTrue);
    });

    test('ReactionResponse.fromJson (un-react answers "-")', () {
      expect(
          ReactionResponse.fromJson(const {'userReaction': '-'}).userReaction,
          isNull);
    });
  });
}
