import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/utils/couplet_deep_link.dart';
import 'package:flutter_test/flutter_test.dart';

CoupletModel _couplet(int number) => CoupletModel(
      publicId: 'c$number',
      coupletNumber: number,
      coupletType: 'REGULAR',
      verses: [VerseModel(text: 'misra $number')],
    );

void main() {
  group('CoupletDeepLink.targetIndex (scroll target selection)', () {
    final ghazal = [for (var n = 1; n <= 9; n++) _couplet(n)];

    test('finds the couplet by its number, not by position', () {
      expect(CoupletDeepLink.targetIndex(ghazal, 1), 0);
      expect(CoupletDeepLink.targetIndex(ghazal, 7), 6);
      // Numbers with a gap (a couplet missing from the response).
      final gapped = [_couplet(1), _couplet(2), _couplet(5), _couplet(6)];
      expect(CoupletDeepLink.targetIndex(gapped, 5), 2);
    });

    test('no number, an unknown number or no couplets: no target', () {
      expect(CoupletDeepLink.targetIndex(ghazal, null), isNull);
      expect(CoupletDeepLink.targetIndex(ghazal, 0), isNull);
      expect(CoupletDeepLink.targetIndex(ghazal, -1), isNull);
      expect(CoupletDeepLink.targetIndex(ghazal, 10), isNull);
      expect(CoupletDeepLink.targetIndex(null, 3), isNull);
      expect(CoupletDeepLink.targetIndex(const [], 3), isNull);
    });

    test('a nazm stored whole as couplet 1 opens at its start', () {
      expect(CoupletDeepLink.targetIndex([_couplet(1)], 1), 0);
    });
  });
}
