import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/theme/tile_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ConfigUiContainerState> pumpContainer(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      ConfigUiContainer(
        child: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return ConfigUiContainer.of(capturedContext)!;
  }

  group('new settings default to the documented values', () {
    testWidgets('sound is enabled, tutorial unseen, Classic theme, no photo',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final ui = await pumpContainer(tester);

      expect(ui.isSoundEnabled, isTrue);
      expect(ui.hasSeenTutorial, isFalse);
      expect(ui.selectedTileThemeId, TileThemeId.classic);
      expect(ui.isPhotoModeEnabled, isFalse);
      expect(ui.photoFilename, isNull);
    });
  });

  group('persistence round-trips through SharedPreferences', () {
    testWidgets('setSoundEnabled persists when save is true', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final ui = await pumpContainer(tester);

      ui.setSoundEnabled(false, save: true);
      await tester.pump();
      expect(ui.isSoundEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ui::sound_enabled'), isFalse);
    });

    testWidgets('setHasSeenTutorial persists when save is true',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final ui = await pumpContainer(tester);

      ui.setHasSeenTutorial(true, save: true);
      await tester.pump();
      expect(ui.hasSeenTutorial, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ui::has_seen_tutorial'), isTrue);
    });

    testWidgets(
      'setSelectedTileTheme persists the id and turns off photo mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'ui::photo_mode_enabled': true,
        });
        final ui = await pumpContainer(tester);
        expect(ui.isPhotoModeEnabled, isTrue);

        ui.setSelectedTileTheme(TileThemeId.midnight, save: true);
        await tester.pump();

        expect(ui.selectedTileThemeId, TileThemeId.midnight);
        expect(ui.isPhotoModeEnabled, isFalse);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('ui::tile_theme_id'), 'midnight');
        expect(prefs.getBool('ui::photo_mode_enabled'), isFalse);
      },
    );

    testWidgets('setPhotoMode persists the enabled flag and filename',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final ui = await pumpContainer(tester);

      ui.setPhotoMode(true, filename: 'theme_pack_photo.jpg', save: true);
      await tester.pump();

      expect(ui.isPhotoModeEnabled, isTrue);
      expect(ui.photoFilename, 'theme_pack_photo.jpg');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ui::photo_mode_enabled'), isTrue);
      expect(prefs.getString('ui::photo_mode_filename'), 'theme_pack_photo.jpg');
    });

    testWidgets(
      'disabling photo mode keeps the filename so it can be re-enabled later',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final ui = await pumpContainer(tester);

        ui.setPhotoMode(true, filename: 'theme_pack_photo.jpg', save: true);
        await tester.pump();
        ui.setPhotoMode(false, save: true);
        await tester.pump();

        expect(ui.isPhotoModeEnabled, isFalse);
        expect(ui.photoFilename, 'theme_pack_photo.jpg');
      },
    );
  });

  group('preferences already on disk are loaded on startup', () {
    testWidgets('restores previously persisted values', (tester) async {
      SharedPreferences.setMockInitialValues({
        'ui::sound_enabled': false,
        'ui::has_seen_tutorial': true,
        'ui::tile_theme_id': 'sunset',
        'ui::photo_mode_enabled': false,
        'ui::photo_mode_filename': 'theme_pack_photo.jpg',
      });
      final ui = await pumpContainer(tester);

      expect(ui.isSoundEnabled, isFalse);
      expect(ui.hasSeenTutorial, isTrue);
      expect(ui.selectedTileThemeId, TileThemeId.sunset);
      expect(ui.isPhotoModeEnabled, isFalse);
      expect(ui.photoFilename, 'theme_pack_photo.jpg');
    });

    testWidgets('falls back to Classic for an unrecognized stored theme id',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'ui::tile_theme_id': 'not_a_real_theme',
      });
      final ui = await pumpContainer(tester);

      expect(ui.selectedTileThemeId, TileThemeId.classic);
    });
  });
}
