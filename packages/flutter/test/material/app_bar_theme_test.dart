// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const AppBarThemeData appBarTheme = AppBarThemeData(
    backgroundColor: Color(0xff00ff00),
    foregroundColor: Color(0xff00ffff),
    elevation: 4.0,
    scrolledUnderElevation: 6.0,
    shadowColor: Color(0xff1212ff),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
    iconTheme: IconThemeData(color: Color(0xffff0000)),
    actionsIconTheme: IconThemeData(color: Color(0xff0000ff)),
    centerTitle: false,
    titleSpacing: 10.0,
    titleTextStyle: TextStyle(fontSize: 22.0, fontStyle: FontStyle.italic),
  );

  ScrollController primaryScrollController(WidgetTester tester) {
    return PrimaryScrollController.of(tester.element(find.byType(CustomScrollView)));
  }

  test('AppBarThemeData copyWith, ==, hashCode basics', () {
    expect(const AppBarThemeData(), const AppBarThemeData().copyWith());
    expect(const AppBarThemeData().hashCode, const AppBarThemeData().copyWith().hashCode);

    expect(const AppBarThemeData().backgroundColor, null);
    expect(const AppBarThemeData().foregroundColor, null);
    expect(const AppBarThemeData().elevation, null);
    expect(const AppBarThemeData().scrolledUnderElevation, null);
    expect(const AppBarThemeData().shadowColor, null);
    expect(const AppBarThemeData().surfaceTintColor, null);
    expect(const AppBarThemeData().shape, null);
    expect(const AppBarThemeData().iconTheme, null);
    expect(const AppBarThemeData().actionsIconTheme, null);
    expect(const AppBarThemeData().centerTitle, null);
    expect(const AppBarThemeData().titleSpacing, null);
    expect(const AppBarThemeData().leadingWidth, null);
    expect(const AppBarThemeData().toolbarHeight, null);
    expect(const AppBarThemeData().toolbarTextStyle, null);
    expect(const AppBarThemeData().titleTextStyle, null);
    expect(const AppBarThemeData().systemOverlayStyle, null);
    expect(const AppBarThemeData().actionsPadding, null);
  });

  test('AppBarTheme lerp special cases', () {
    const AppBarTheme data = AppBarTheme();
    expect(identical(AppBarTheme.lerp(data, data, 0.5), data), true);
  });

  testWidgets('Material2 - Passing no AppBarTheme returns defaults', (WidgetTester tester) async {
    final ThemeData theme = ThemeData(useMaterial3: false);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
          ),
        ),
      ),
    );

    final Material widget = _getAppBarMaterial(tester);
    final IconTheme iconTheme = _getAppBarIconTheme(tester);
    final IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    final RichText actionIconText = _getAppBarIconRichText(tester);
    final DefaultTextStyle text = _getAppBarText(tester);

    expect(
      SystemChrome.latestStyle!.statusBarBrightness,
      SystemUiOverlayStyle.light.statusBarBrightness,
    );
    expect(widget.color, Colors.blue);
    expect(widget.elevation, 4.0);
    expect(widget.shadowColor, Colors.black);
    expect(widget.surfaceTintColor, null);
    expect(widget.shape, null);
    expect(iconTheme.data, const IconThemeData(color: Colors.white));
    expect(actionsIconTheme.data, const IconThemeData(color: Colors.white));
    expect(actionIconText.text.style!.color, Colors.white);
    expect(
      text.style,
      Typography.material2014().englishLike.bodyMedium!.merge(
        Typography.material2014().white.bodyMedium,
      ),
    );
    expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
    expect(tester.getSize(find.byType(AppBar)).width, 800);
  });

  testWidgets('Material3 - Passing no AppBarTheme returns defaults', (WidgetTester tester) async {
    final ThemeData theme = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
          ),
        ),
      ),
    );

    final Material widget = _getAppBarMaterial(tester);
    final IconTheme iconTheme = _getAppBarIconTheme(tester);
    final IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    final RichText actionIconText = _getAppBarIconRichText(tester);
    final DefaultTextStyle text = _getAppBarText(tester);

    expect(SystemChrome.latestStyle!.statusBarBrightness, Brightness.light);
    expect(widget.color, theme.colorScheme.surface);
    expect(widget.elevation, 0);
    expect(widget.shadowColor, Colors.transparent);
    expect(widget.surfaceTintColor, theme.colorScheme.surfaceTint);
    expect(widget.shape, null);
    expect(iconTheme.data, IconThemeData(color: theme.colorScheme.onSurface, size: 24));
    expect(
      actionsIconTheme.data,
      IconThemeData(color: theme.colorScheme.onSurfaceVariant, size: 24),
    );
    expect(actionIconText.text.style!.color, theme.colorScheme.onSurfaceVariant);
    expect(
      text.style,
      Typography.material2021().englishLike.bodyMedium!
          .merge(Typography.material2021().black.bodyMedium)
          .copyWith(
            color: theme.colorScheme.onSurface,
            decorationColor: theme.colorScheme.onSurface,
          ),
    );
    expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
    expect(tester.getSize(find.byType(AppBar)).width, 800);
  });

  testWidgets('AppBar uses values from AppBarTheme', (WidgetTester tester) async {
    final AppBarThemeData appBarTheme = _appBarTheme();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: appBarTheme),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('App Bar Title'),
            actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
          ),
        ),
      ),
    );

    final Material widget = _getAppBarMaterial(tester);
    final IconTheme iconTheme = _getAppBarIconTheme(tester);
    final IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    final RichText actionIconText = _getAppBarIconRichText(tester);
    final DefaultTextStyle text = _getAppBarText(tester);

    expect(SystemChrome.latestStyle!.statusBarBrightness, Brightness.light);
    expect(widget.color, appBarTheme.backgroundColor);
    expect(widget.elevation, appBarTheme.elevation);
    expect(widget.shadowColor, appBarTheme.shadowColor);
    expect(widget.surfaceTintColor, appBarTheme.surfaceTintColor);
    expect(widget.shape, const StadiumBorder());
    expect(iconTheme.data, appBarTheme.iconTheme);
    expect(actionsIconTheme.data, appBarTheme.actionsIconTheme);
    expect(actionIconText.text.style!.color, appBarTheme.actionsIconTheme!.color);
    expect(text.style, appBarTheme.toolbarTextStyle);
    expect(tester.getSize(find.byType(AppBar)).height, appBarTheme.toolbarHeight);
    expect(tester.getSize(find.byType(AppBar)).width, 800);
  });

  testWidgets('AppBar widget properties take priority over theme', (WidgetTester tester) async {
    const Brightness brightness = Brightness.dark;
    const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.light;
    const Color color = Colors.orange;
    const double elevation = 3.0;
    const Color shadowColor = Colors.purple;
    const Color surfaceTintColor = Colors.brown;
    const ShapeBorder shape = RoundedRectangleBorder();
    const IconThemeData iconThemeData = IconThemeData(color: Colors.green);
    const IconThemeData actionsIconThemeData = IconThemeData(color: Colors.lightBlue);
    const TextStyle toolbarTextStyle = TextStyle(color: Colors.pink);
    const TextStyle titleTextStyle = TextStyle(color: Colors.orange);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.from(
          colorScheme: const ColorScheme.light(),
        ).copyWith(appBarTheme: _appBarTheme()),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: color,
            systemOverlayStyle: systemOverlayStyle,
            elevation: elevation,
            shadowColor: shadowColor,
            surfaceTintColor: surfaceTintColor,
            shape: shape,
            iconTheme: iconThemeData,
            actionsIconTheme: actionsIconThemeData,
            toolbarTextStyle: toolbarTextStyle,
            titleTextStyle: titleTextStyle,
            actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
          ),
        ),
      ),
    );

    final Material widget = _getAppBarMaterial(tester);
    final IconTheme iconTheme = _getAppBarIconTheme(tester);
    final IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    final RichText actionIconText = _getAppBarIconRichText(tester);
    final DefaultTextStyle text = _getAppBarText(tester);

    expect(SystemChrome.latestStyle!.statusBarBrightness, brightness);
    expect(widget.color, color);
    expect(widget.elevation, elevation);
    expect(widget.shadowColor, shadowColor);
    expect(widget.surfaceTintColor, surfaceTintColor);
    expect(widget.shape, shape);
    expect(iconTheme.data, iconThemeData);
    expect(actionsIconTheme.data, actionsIconThemeData);
    expect(actionIconText.text.style!.color, actionsIconThemeData.color);
    expect(text.style, toolbarTextStyle);
  });

  testWidgets('AppBar icon color takes priority over everything', (WidgetTester tester) async {
    const Color color = Colors.lime;
    const IconThemeData iconThemeData = IconThemeData(color: Colors.green);
    const IconThemeData actionsIconThemeData = IconThemeData(color: Colors.lightBlue);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.from(colorScheme: const ColorScheme.light()),
        home: Scaffold(
          appBar: AppBar(
            iconTheme: iconThemeData,
            actionsIconTheme: actionsIconThemeData,
            actions: <Widget>[
              IconButton(icon: const Icon(Icons.share), color: color, onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    final RichText actionIconText = _getAppBarIconRichText(tester);
    expect(actionIconText.text.style!.color, color);
  });

  testWidgets('AppBarTheme properties take priority over ThemeData properties', (
    WidgetTester tester,
  ) async {
    final AppBarThemeData appBarTheme = _appBarTheme();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.from(
          colorScheme: const ColorScheme.light(),
        ).copyWith(appBarTheme: _appBarTheme()),
        home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
          ),
        ),
      ),
    );

    final Material widget = _getAppBarMaterial(tester);
    final IconTheme iconTheme = _getAppBarIconTheme(tester);
    final IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    final RichText actionIconText = _getAppBarIconRichText(tester);
    final DefaultTextStyle text = _getAppBarText(tester);

    expect(SystemChrome.latestStyle!.statusBarBrightness, Brightness.light);
    expect(widget.color, appBarTheme.backgroundColor);
    expect(widget.elevation, appBarTheme.elevation);
    expect(widget.shadowColor, appBarTheme.shadowColor);
    expect(widget.surfaceTintColor, appBarTheme.surfaceTintColor);
    expect(iconTheme.data, appBarTheme.iconTheme);
    expect(actionsIconTheme.data, appBarTheme.actionsIconTheme);
    expect(actionIconText.text.style!.color, appBarTheme.actionsIconTheme!.color);
    expect(text.style, appBarTheme.toolbarTextStyle);
  });

  testWidgets('Material2 - ThemeData colorScheme is used when no AppBarTheme is set', (
    WidgetTester tester,
  ) async {
    final ThemeData lightTheme = ThemeData.from(
      colorScheme: const ColorScheme.light(),
      useMaterial3: false,
    );
    final ThemeData darkTheme = ThemeData.from(
      colorScheme: const ColorScheme.dark(),
      useMaterial3: false,
    );
    Widget buildFrame(ThemeData appTheme) {
      return MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
              ),
            );
          },
        ),
      );
    }

    // AppBar M2 defaults for light themes:
    // - elevation: 4
    // - shadow color: black
    // - surface tint color: null
    // - background color: ColorScheme.primary
    // - foreground color: ColorScheme.onPrimary
    // - actions text: style bodyMedium, foreground color
    // - status bar brightness: light (based on color scheme brightness)
    await tester.pumpWidget(buildFrame(lightTheme));

    Material widget = _getAppBarMaterial(tester);
    IconTheme iconTheme = _getAppBarIconTheme(tester);
    IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    RichText actionIconText = _getAppBarIconRichText(tester);
    DefaultTextStyle text = _getAppBarText(tester);

    expect(
      SystemChrome.latestStyle!.statusBarBrightness,
      SystemUiOverlayStyle.light.statusBarBrightness,
    );
    expect(widget.color, lightTheme.colorScheme.primary);
    expect(widget.elevation, 4.0);
    expect(widget.shadowColor, Colors.black);
    expect(widget.surfaceTintColor, null);
    expect(iconTheme.data.color, lightTheme.colorScheme.onPrimary);
    expect(actionsIconTheme.data.color, lightTheme.colorScheme.onPrimary);
    expect(actionIconText.text.style!.color, lightTheme.colorScheme.onPrimary);
    expect(
      text.style,
      Typography.material2014().englishLike.bodyMedium!
          .merge(Typography.material2014().black.bodyMedium)
          .copyWith(color: lightTheme.colorScheme.onPrimary),
    );

    // AppBar M2 defaults for dark themes:
    // - elevation: 4
    // - shadow color: black
    // - surface tint color: null
    // - background color: ColorScheme.surface
    // - foreground color: ColorScheme.onSurface
    // - actions text: style bodyMedium, foreground color
    // - status bar brightness: dark (based on background color)
    await tester.pumpWidget(buildFrame(darkTheme));
    await tester.pumpAndSettle(); // Theme change animation

    widget = _getAppBarMaterial(tester);
    iconTheme = _getAppBarIconTheme(tester);
    actionsIconTheme = _getAppBarActionsIconTheme(tester);
    actionIconText = _getAppBarIconRichText(tester);
    text = _getAppBarText(tester);

    expect(
      SystemChrome.latestStyle!.statusBarBrightness,
      SystemUiOverlayStyle.light.statusBarBrightness,
    );
    expect(widget.color, darkTheme.colorScheme.surface);
    expect(widget.elevation, 4.0);
    expect(widget.shadowColor, Colors.black);
    expect(widget.surfaceTintColor, null);
    expect(iconTheme.data.color, darkTheme.colorScheme.onSurface);
    expect(actionsIconTheme.data.color, darkTheme.colorScheme.onSurface);
    expect(actionIconText.text.style!.color, darkTheme.colorScheme.onSurface);
    expect(
      text.style,
      Typography.material2014().englishLike.bodyMedium!
          .merge(Typography.material2014().black.bodyMedium)
          .copyWith(color: darkTheme.colorScheme.onSurface),
    );
  });

  testWidgets('Material3 - ThemeData colorScheme is used when no AppBarTheme is set', (
    WidgetTester tester,
  ) async {
    final ThemeData lightTheme = ThemeData.from(colorScheme: const ColorScheme.light());
    final ThemeData darkTheme = ThemeData.from(colorScheme: const ColorScheme.dark());
    Widget buildFrame(ThemeData appTheme) {
      return MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
              ),
            );
          },
        ),
      );
    }

    // M3 AppBar defaults for light themes:
    // - elevation: 0
    // - shadow color: Colors.transparent
    // - surface tint color: ColorScheme.surfaceTint
    // - background color: ColorScheme.surface
    // - foreground color: ColorScheme.onSurface
    // - actions text: style bodyMedium, foreground color
    // - status bar brightness: light (based on color scheme brightness)
    await tester.pumpWidget(buildFrame(lightTheme));

    Material widget = _getAppBarMaterial(tester);
    IconTheme iconTheme = _getAppBarIconTheme(tester);
    IconTheme actionsIconTheme = _getAppBarActionsIconTheme(tester);
    RichText actionIconText = _getAppBarIconRichText(tester);
    DefaultTextStyle text = _getAppBarText(tester);

    expect(SystemChrome.latestStyle!.statusBarBrightness, Brightness.light);
    expect(widget.color, lightTheme.colorScheme.surface);
    expect(widget.elevation, 0);
    expect(widget.shadowColor, Colors.transparent);
    expect(widget.surfaceTintColor, lightTheme.colorScheme.surfaceTint);
    expect(iconTheme.data.color, lightTheme.colorScheme.onSurface);
    expect(actionsIconTheme.data.color, lightTheme.colorScheme.onSurface);
    expect(actionIconText.text.style!.color, lightTheme.colorScheme.onSurface);
    expect(
      text.style,
      Typography.material2021().englishLike.bodyMedium!
          .merge(Typography.material2021().black.bodyMedium)
          .copyWith(color: lightTheme.colorScheme.onSurface),
    );

    // M3 AppBar defaults for dark themes:
    // - elevation: 0
    // - shadow color: Colors.transparent
    // - surface tint color: ColorScheme.surfaceTint
    // - background color: ColorScheme.surface
    // - foreground color: ColorScheme.onSurface
    // - actions text: style bodyMedium, foreground color
    // - status bar brightness: dark (based on background color)
    await tester.pumpWidget(buildFrame(darkTheme));
    await tester.pumpAndSettle(); // Theme change animation

    widget = _getAppBarMaterial(tester);
    iconTheme = _getAppBarIconTheme(tester);
    actionsIconTheme = _getAppBarActionsIconTheme(tester);
    actionIconText = _getAppBarIconRichText(tester);
    text = _getAppBarText(tester);

    expect(SystemChrome.latestStyle!.statusBarBrightness, Brightness.dark);
    expect(widget.color, darkTheme.colorScheme.surface);
    expect(widget.elevation, 0);
    expect(widget.shadowColor, Colors.transparent);
    expect(widget.surfaceTintColor, darkTheme.colorScheme.surfaceTint);
    expect(iconTheme.data.color, darkTheme.colorScheme.onSurface);
    expect(actionsIconTheme.data.color, darkTheme.colorScheme.onSurface);
    expect(actionIconText.text.style!.color, darkTheme.colorScheme.onSurface);
    expect(
      text.style,
      Typography.material2021().englishLike.bodyMedium!
          .merge(Typography.material2021().black.bodyMedium)
          .copyWith(
            color: darkTheme.colorScheme.onSurface,
            decorationColor: darkTheme.colorScheme.onSurface,
          ),
    );
  });

  testWidgets('AppBar iconTheme with color=null defers to outer IconTheme', (
    WidgetTester tester,
  ) async {
    // Verify claim made in https://github.com/flutter/flutter/pull/71184#issuecomment-737419215

    Widget buildFrame({Color? appIconColor, Color? appBarIconColor}) {
      return MaterialApp(
        theme: ThemeData.from(colorScheme: const ColorScheme.light()),
        home: IconTheme(
          data: IconThemeData(color: appIconColor),
          child: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(color: appBarIconColor),
                  actions: <Widget>[IconButton(icon: const Icon(Icons.share), onPressed: () {})],
                ),
              );
            },
          ),
        ),
      );
    }

    RichText getIconText() {
      return tester.widget<RichText>(
        find.descendant(of: find.byType(Icon), matching: find.byType(RichText)),
      );
    }

    await tester.pumpWidget(buildFrame(appIconColor: Colors.lime));
    await tester.pumpAndSettle();
    expect(getIconText().text.style!.color, Colors.lime);

    await tester.pumpWidget(buildFrame(appIconColor: Colors.lime, appBarIconColor: Colors.purple));
    await tester.pumpAndSettle();
    expect(getIconText().text.style!.color, Colors.purple);
  });

  testWidgets('AppBar uses AppBarTheme.centerTitle when centerTitle is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(centerTitle: true)),
        home: Scaffold(appBar: AppBar(title: const Text('Title'))),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolBar.centerMiddle, true);
  });

  testWidgets('AppBar.centerTitle takes priority over AppBarTheme.centerTitle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(centerTitle: true)),
        home: Scaffold(appBar: AppBar(title: const Text('Title'), centerTitle: false)),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    // The AppBar.centerTitle should be used instead of AppBarThemeData.centerTitle.
    expect(navToolBar.centerMiddle, false);
  });

  testWidgets(
    'AppBar.centerTitle adapts to TargetPlatform when AppBarThemeData.centerTitle is null',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(appBar: AppBar(title: const Text('Title'))),
        ),
      );

      final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
      // When ThemeData.platform is TargetPlatform.iOS, and AppBarThemeData is null,
      // the value of NavigationToolBar.centerMiddle should be true.
      expect(navToolBar.centerMiddle, true);
    },
  );

  testWidgets('AppBar.shadowColor takes priority over AppBarThemeData.shadowColor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(shadowColor: Colors.red)),
        home: Scaffold(appBar: AppBar(title: const Text('Title'), shadowColor: Colors.yellow)),
      ),
    );

    final AppBar appBar = tester.widget(find.byType(AppBar));
    // The AppBar.shadowColor should be used instead of AppBarThemeData.shadowColor.
    expect(appBar.shadowColor, Colors.yellow);
  });

  testWidgets('AppBar.surfaceTintColor takes priority over AppBarThemeData.surfaceTintColor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(surfaceTintColor: Colors.red)),
        home: Scaffold(appBar: AppBar(title: const Text('Title'), surfaceTintColor: Colors.yellow)),
      ),
    );

    final AppBar appBar = tester.widget(find.byType(AppBar));
    // The AppBar.surfaceTintColor should be used instead of AppBarThemeData.surfaceTintColor.
    expect(appBar.surfaceTintColor, Colors.yellow);
  });

  testWidgets(
    'Material3 - AppBarThemeData.iconTheme.color takes priority over IconButtonTheme.foregroundColor',
    (WidgetTester tester) async {
      const IconThemeData overallIconTheme = IconThemeData(color: Colors.yellow);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(foregroundColor: Colors.red),
            ),
            appBarTheme: const AppBarThemeData(iconTheme: overallIconTheme),
          ),
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final Color? leadingIconButtonColor = _iconStyle(tester, Icons.menu)?.color;
      final Color? actionIconButtonColor = _iconStyle(tester, Icons.add)?.color;

      expect(leadingIconButtonColor, overallIconTheme.color);
      expect(actionIconButtonColor, overallIconTheme.color);
    },
  );

  testWidgets(
    'Material3 - AppBarThemeData.iconTheme.size takes priority over IconButtonTheme.iconSize',
    (WidgetTester tester) async {
      const IconThemeData overallIconTheme = IconThemeData(size: 30.0);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 32.0)),
            appBarTheme: const AppBarThemeData(iconTheme: overallIconTheme),
          ),
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final double? leadingIconButtonSize = _iconStyle(tester, Icons.menu)?.fontSize;
      final double? actionIconButtonSize = _iconStyle(tester, Icons.add)?.fontSize;

      expect(leadingIconButtonSize, overallIconTheme.size);
      expect(actionIconButtonSize, overallIconTheme.size);
    },
  );

  testWidgets(
    'Material3 - AppBarThemeData.actionsIconTheme.color takes priority over IconButtonTheme.foregroundColor',
    (WidgetTester tester) async {
      const IconThemeData actionsIconTheme = IconThemeData(color: Colors.yellow);
      final IconButtonThemeData iconButtonTheme = IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: Colors.red),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: iconButtonTheme,
            appBarTheme: const AppBarThemeData(actionsIconTheme: actionsIconTheme),
          ),
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final Color? leadingIconButtonColor = _iconStyle(tester, Icons.menu)?.color;
      final Color? actionIconButtonColor = _iconStyle(tester, Icons.add)?.color;

      expect(leadingIconButtonColor, Colors.red); // leading color should come from iconButtonTheme
      expect(actionIconButtonColor, actionsIconTheme.color);
    },
  );

  testWidgets(
    'Material3 - AppBarThemeData.actionsIconTheme.size takes priority over IconButtonTheme.iconSize',
    (WidgetTester tester) async {
      const IconThemeData actionsIconTheme = IconThemeData(size: 30.0);
      final IconButtonThemeData iconButtonTheme = IconButtonThemeData(
        style: IconButton.styleFrom(iconSize: 32.0),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: iconButtonTheme,
            appBarTheme: const AppBarThemeData(actionsIconTheme: actionsIconTheme),
          ),
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final double? leadingIconButtonSize = _iconStyle(tester, Icons.menu)?.fontSize;
      final double? actionIconButtonSize = _iconStyle(tester, Icons.add)?.fontSize;

      expect(
        leadingIconButtonSize,
        32.0,
      ); // The size of leading icon button should come from iconButtonTheme
      expect(actionIconButtonSize, actionsIconTheme.size);
    },
  );

  testWidgets(
    'Material3 - AppBarThemeData.foregroundColor takes priority over IconButtonTheme.foregroundColor',
    (WidgetTester tester) async {
      final IconButtonThemeData iconButtonTheme = IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: Colors.red),
      );
      const AppBarThemeData appBarTheme = AppBarThemeData(foregroundColor: Colors.green);
      final ThemeData themeData = ThemeData(
        iconButtonTheme: iconButtonTheme,
        appBarTheme: appBarTheme,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: themeData,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('title'),
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            ),
          ),
        ),
      );

      final Color? leadingIconButtonColor = _iconStyle(tester, Icons.menu)?.color;
      final Color? actionIconButtonColor = _iconStyle(tester, Icons.add)?.color;

      expect(leadingIconButtonColor, appBarTheme.foregroundColor);
      expect(actionIconButtonColor, appBarTheme.foregroundColor);
    },
  );

  testWidgets('AppBar uses AppBarThemeData.titleSpacing', (WidgetTester tester) async {
    const double kTitleSpacing = 10;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(titleSpacing: kTitleSpacing)),
        home: Scaffold(appBar: AppBar(title: const Text('Title'))),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolBar.middleSpacing, kTitleSpacing);
  });

  testWidgets('AppBar.titleSpacing takes priority over AppBarThemeData.titleSpacing', (
    WidgetTester tester,
  ) async {
    const double kTitleSpacing = 10;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(titleSpacing: kTitleSpacing)),
        home: Scaffold(appBar: AppBar(title: const Text('Title'), titleSpacing: 40)),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolBar.middleSpacing, 40);
  });

  testWidgets('AppBar uses AppBarThemeData.leadingWidth', (WidgetTester tester) async {
    const double kLeadingWidth = 80;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(leadingWidth: kLeadingWidth)),
        home: Scaffold(appBar: AppBar(leading: const Icon(Icons.chevron_left))),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    final BoxConstraints leadingConstraints = (navToolBar.leading! as ConstrainedBox).constraints;
    expect(leadingConstraints.maxWidth, kLeadingWidth);
    expect(leadingConstraints.minWidth, kLeadingWidth);
  });

  testWidgets('AppBar.leadingWidth takes priority over AppBarThemeData.leadingWidth', (
    WidgetTester tester,
  ) async {
    const double kLeadingWidth = 80;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(leadingWidth: kLeadingWidth)),
        home: Scaffold(appBar: AppBar(leading: const Icon(Icons.chevron_left), leadingWidth: 40)),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    final BoxConstraints leadingConstraints = (navToolBar.leading! as ConstrainedBox).constraints;
    expect(leadingConstraints.maxWidth, 40);
    expect(leadingConstraints.minWidth, 40);
  });

  testWidgets('SliverAppBar uses AppBarThemeData.titleSpacing', (WidgetTester tester) async {
    const double kTitleSpacing = 10;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(titleSpacing: kTitleSpacing)),
        home: const CustomScrollView(slivers: <Widget>[SliverAppBar(title: Text('Title'))]),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolBar.middleSpacing, kTitleSpacing);
  });

  testWidgets('SliverAppBar.titleSpacing takes priority over AppBarThemeData.titleSpacing ', (
    WidgetTester tester,
  ) async {
    const double kTitleSpacing = 10;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(titleSpacing: kTitleSpacing)),
        home: const CustomScrollView(
          slivers: <Widget>[SliverAppBar(title: Text('Title'), titleSpacing: 40)],
        ),
      ),
    );

    final NavigationToolbar navToolbar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolbar.middleSpacing, 40);
  });

  testWidgets('SliverAppBar uses AppBarThemeData.leadingWidth', (WidgetTester tester) async {
    const double kLeadingWidth = 80;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(leadingWidth: kLeadingWidth)),
        home: const CustomScrollView(
          slivers: <Widget>[SliverAppBar(leading: Icon(Icons.chevron_left))],
        ),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    final BoxConstraints leadingConstraints = (navToolBar.leading! as ConstrainedBox).constraints;
    expect(leadingConstraints.maxWidth, kLeadingWidth);
    expect(leadingConstraints.minWidth, kLeadingWidth);
  });

  testWidgets('SliverAppBar.leadingWidth takes priority over AppBarThemeData.leadingWidth ', (
    WidgetTester tester,
  ) async {
    const double kLeadingWidth = 80;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarThemeData(leadingWidth: kLeadingWidth)),
        home: const CustomScrollView(
          slivers: <Widget>[SliverAppBar(leading: Icon(Icons.chevron_left), leadingWidth: 40)],
        ),
      ),
    );

    final NavigationToolbar navToolBar = tester.widget(find.byType(NavigationToolbar));
    final BoxConstraints leadingConstraints = (navToolBar.leading! as ConstrainedBox).constraints;
    expect(leadingConstraints.maxWidth, 40);
    expect(leadingConstraints.minWidth, 40);
  });

  testWidgets('SliverAppBar.medium uses AppBarThemeData properties', (WidgetTester tester) async {
    const String title = 'Medium App Bar';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: appBarTheme),
        home: CustomScrollView(
          primary: true,
          slivers: <Widget>[
            SliverAppBar.medium(
              leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
              title: const Text(title),
              actions: <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
            ),
          ],
        ),
      ),
    );

    // Test title.
    final RichText titleText = tester.firstWidget(find.byType(RichText));
    expect(titleText.text.style!.fontSize, appBarTheme.titleTextStyle!.fontSize);
    expect(titleText.text.style!.fontStyle, appBarTheme.titleTextStyle!.fontStyle);

    // Test background color, shadow color, and shape.
    final Material material = tester.widget<Material>(
      find.descendant(of: find.byType(SliverAppBar), matching: find.byType(Material).first),
    );
    expect(material.color, appBarTheme.backgroundColor);
    expect(material.shadowColor, appBarTheme.shadowColor);
    expect(material.shape, appBarTheme.shape);

    final RichText actionIcon = tester.widget(find.byType(RichText).last);
    expect(actionIcon.text.style!.color, appBarTheme.actionsIconTheme!.color);

    // Scroll to collapse the SliverAppBar.
    final ScrollController controller = primaryScrollController(tester);
    controller.jumpTo(120);
    await tester.pumpAndSettle();

    // Test title spacing.
    final Finder collapsedTitle = find.text(title).last;
    final Offset titleOffset = tester.getTopLeft(collapsedTitle);
    final Offset iconOffset = tester.getTopRight(
      find.ancestor(
        of: find.widgetWithIcon(IconButton, Icons.menu),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(titleOffset.dx, iconOffset.dx + appBarTheme.titleSpacing!);
  });

  testWidgets('SliverAppBar.medium properties take priority over AppBarThemeData properties', (
    WidgetTester tester,
  ) async {
    const String title = 'Medium App Bar';
    const Color backgroundColor = Color(0xff000099);
    const Color foregroundColor = Color(0xff00ff98);
    const Color shadowColor = Color(0xff00ff97);
    const ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.only(bottomStart: Radius.circular(12.0)),
    );
    const IconThemeData iconTheme = IconThemeData(color: Color(0xff00ff96));
    const IconThemeData actionsIconTheme = IconThemeData(color: Color(0xff00ff95));
    const double titleSpacing = 18.0;
    const TextStyle titleTextStyle = TextStyle(fontSize: 22.9, fontStyle: FontStyle.italic);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: appBarTheme),
        home: CustomScrollView(
          primary: true,
          slivers: <Widget>[
            SliverAppBar.medium(
              centerTitle: false,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shadowColor: shadowColor,
              shape: shape,
              iconTheme: iconTheme,
              actionsIconTheme: actionsIconTheme,
              titleSpacing: titleSpacing,
              titleTextStyle: titleTextStyle,
              leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
              title: const Text(title),
              actions: <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
            ),
          ],
        ),
      ),
    );

    // Test title.
    final RichText titleText = tester.firstWidget(find.byType(RichText));
    expect(titleText.text.style, titleTextStyle);

    // Test background color, shadow color, and shape.
    final Material material = tester.widget<Material>(
      find.descendant(of: find.byType(SliverAppBar), matching: find.byType(Material).first),
    );
    expect(material.color, backgroundColor);
    expect(material.shadowColor, shadowColor);
    expect(material.shape, shape);

    final RichText actionIcon = tester.widget(find.byType(RichText).last);
    expect(actionIcon.text.style!.color, actionsIconTheme.color);

    // Scroll to collapse the SliverAppBar.
    final ScrollController controller = primaryScrollController(tester);
    controller.jumpTo(120);
    await tester.pumpAndSettle();

    // Test title spacing.
    final Finder collapsedTitle = find.text(title).last;
    final Offset titleOffset = tester.getTopLeft(collapsedTitle);
    final Offset iconOffset = tester.getTopRight(
      find.ancestor(
        of: find.widgetWithIcon(IconButton, Icons.menu),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(titleOffset.dx, iconOffset.dx + titleSpacing);
  });

  testWidgets('SliverAppBar.large uses AppBarThemeData properties', (WidgetTester tester) async {
    const String title = 'Large App Bar';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: appBarTheme),
        home: CustomScrollView(
          primary: true,
          slivers: <Widget>[
            SliverAppBar.large(
              leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
              title: const Text(title),
              actions: <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
            ),
          ],
        ),
      ),
    );

    // Test title.
    final RichText titleText = tester.firstWidget(find.byType(RichText));
    expect(titleText.text.style!.fontSize, appBarTheme.titleTextStyle!.fontSize);
    expect(titleText.text.style!.fontStyle, appBarTheme.titleTextStyle!.fontStyle);

    // Test background color, shadow color, and shape.
    final Material material = tester.widget<Material>(
      find.descendant(of: find.byType(SliverAppBar), matching: find.byType(Material).first),
    );
    expect(material.color, appBarTheme.backgroundColor);
    expect(material.shadowColor, appBarTheme.shadowColor);
    expect(material.shape, appBarTheme.shape);

    final RichText actionIcon = tester.widget(find.byType(RichText).last);
    expect(actionIcon.text.style!.color, appBarTheme.actionsIconTheme!.color);

    // Scroll to collapse the SliverAppBar.
    final ScrollController controller = primaryScrollController(tester);
    controller.jumpTo(120);
    await tester.pumpAndSettle();

    // Test title spacing.
    final Finder collapsedTitle = find.text(title).last;
    final Offset titleOffset = tester.getTopLeft(collapsedTitle);
    final Offset iconOffset = tester.getTopRight(
      find.ancestor(
        of: find.widgetWithIcon(IconButton, Icons.menu),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(titleOffset.dx, iconOffset.dx + appBarTheme.titleSpacing!);
  });

  testWidgets('SliverAppBar.large properties take priority over AppBarThemeData properties', (
    WidgetTester tester,
  ) async {
    const String title = 'Large App Bar';
    const Color backgroundColor = Color(0xff000099);
    const Color foregroundColor = Color(0xff00ff98);
    const Color shadowColor = Color(0xff00ff97);
    const ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.only(bottomStart: Radius.circular(12.0)),
    );
    const IconThemeData iconTheme = IconThemeData(color: Color(0xff00ff96));
    const IconThemeData actionsIconTheme = IconThemeData(color: Color(0xff00ff95));
    const double titleSpacing = 18.0;
    const TextStyle titleTextStyle = TextStyle(fontSize: 22.9, fontStyle: FontStyle.italic);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: appBarTheme),
        home: CustomScrollView(
          primary: true,
          slivers: <Widget>[
            SliverAppBar.large(
              centerTitle: false,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shadowColor: shadowColor,
              shape: shape,
              iconTheme: iconTheme,
              actionsIconTheme: actionsIconTheme,
              titleSpacing: titleSpacing,
              titleTextStyle: titleTextStyle,
              leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
              title: const Text(title),
              actions: <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
            ),
          ],
        ),
      ),
    );

    // Test title.
    final RichText titleText = tester.firstWidget(find.byType(RichText));
    expect(titleText.text.style, titleTextStyle);

    // Test background color, shadow color, and shape.
    final Material material = tester.widget<Material>(
      find.descendant(of: find.byType(SliverAppBar), matching: find.byType(Material).first),
    );
    expect(material.color, backgroundColor);
    expect(material.shadowColor, shadowColor);
    expect(material.shape, shape);

    final RichText actionIcon = tester.widget(find.byType(RichText).last);
    expect(actionIcon.text.style!.color, actionsIconTheme.color);

    // Scroll to collapse the SliverAppBar.
    final ScrollController controller = primaryScrollController(tester);
    controller.jumpTo(120);
    await tester.pumpAndSettle();

    // Test title spacing.
    final Finder collapsedTitle = find.text(title).last;
    final Offset titleOffset = tester.getTopLeft(collapsedTitle);
    final Offset iconOffset = tester.getTopRight(
      find.ancestor(
        of: find.widgetWithIcon(IconButton, Icons.menu),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(titleOffset.dx, iconOffset.dx + titleSpacing);
  });

  testWidgets('SliverAppBar medium & large supports foregroundColor', (WidgetTester tester) async {
    const String title = 'AppBar title';
    const AppBarThemeData appBarTheme = AppBarThemeData(foregroundColor: Color(0xff00ff20));
    const Color foregroundColor = Color(0xff001298);

    Widget buildWidget({Color? color, AppBarThemeData? appBarTheme}) {
      return MaterialApp(
        theme: ThemeData(appBarTheme: appBarTheme),
        home: CustomScrollView(
          primary: true,
          slivers: <Widget>[
            SliverAppBar.medium(foregroundColor: color, title: const Text(title)),
            SliverAppBar.large(foregroundColor: color, title: const Text(title)),
          ],
        ),
      );
    }

    await tester.pumpWidget(buildWidget(appBarTheme: appBarTheme));

    // Test AppBarThemeData.foregroundColor parameter.
    RichText mediumTitle = tester.widget(find.byType(RichText).first);
    expect(mediumTitle.text.style!.color, appBarTheme.foregroundColor);
    RichText largeTitle = tester.widget(find.byType(RichText).first);
    expect(largeTitle.text.style!.color, appBarTheme.foregroundColor);

    await tester.pumpWidget(buildWidget(color: foregroundColor, appBarTheme: appBarTheme));

    // Test foregroundColor parameter.
    mediumTitle = tester.widget(find.byType(RichText).first);
    expect(mediumTitle.text.style!.color, foregroundColor);
    largeTitle = tester.widget(find.byType(RichText).first);
    expect(largeTitle.text.style!.color, foregroundColor);
  });

  testWidgets('Default AppBarThemeData debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const AppBarThemeData().debugFillProperties(builder);

    final List<String> description =
        builder.properties
            .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
            .map((DiagnosticsNode node) => node.toString())
            .toList();

    expect(description, <String>[]);
  });

  testWidgets('AppBarThemeData implements debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const AppBarThemeData(
      backgroundColor: Color(0xff000000),
      foregroundColor: Color(0xff000001),
      elevation: 8.0,
      scrolledUnderElevation: 3,
      shadowColor: Color(0xff000002),
      surfaceTintColor: Color(0xff000003),
      shape: StadiumBorder(),
      iconTheme: IconThemeData(color: Color(0xff000004)),
      actionsIconTheme: IconThemeData(color: Color(0xff000004)),
      centerTitle: true,
      titleSpacing: 40.0,
      leadingWidth: 96,
      toolbarHeight: 96,
      toolbarTextStyle: TextStyle(color: Color(0xff000005)),
      titleTextStyle: TextStyle(color: Color(0xff000006)),
      systemOverlayStyle: SystemUiOverlayStyle(systemNavigationBarColor: Color(0xff000007)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 8.0),
    ).debugFillProperties(builder);

    final List<String> description =
        builder.properties
            .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
            .map((DiagnosticsNode node) => node.toString())
            .toList();

    expect(
      description,
      equalsIgnoringHashCodes(<String>[
        'backgroundColor: ${const Color(0xff000000)}',
        'foregroundColor: ${const Color(0xff000001)}',
        'elevation: 8.0',
        'scrolledUnderElevation: 3.0',
        'shadowColor: ${const Color(0xff000002)}',
        'surfaceTintColor: ${const Color(0xff000003)}',
        'shape: StadiumBorder(BorderSide(width: 0.0, style: none))',
        'iconTheme: IconThemeData#00000(color: ${const Color(0xff000004)})',
        'actionsIconTheme: IconThemeData#00000(color: ${const Color(0xff000004)})',
        'centerTitle: true',
        'titleSpacing: 40.0',
        'leadingWidth: 96.0',
        'toolbarHeight: 96.0',
        'toolbarTextStyle: TextStyle(inherit: true, color: ${const Color(0xff000005)})',
        'titleTextStyle: TextStyle(inherit: true, color: ${const Color(0xff000006)})',
        'systemOverlayStyle: SystemUiOverlayStyle(systemNavigationBarColor: ${const Color(0xff000007)})',
        'actionsPadding: EdgeInsets(8.0, 0.0, 8.0, 0.0)',
      ]),
    );

    // On the web, Dart doubles and ints are backed by the same kind of object because
    // JavaScript does not support integers. So, the Dart double "4.0" is identical
    // to "4", which results in the web evaluating to the value "4" regardless of which
    // one is used. This results in a difference for doubles in debugFillProperties between
    // the web and the rest of Flutter's target platforms.
  }, skip: kIsWeb); // https://github.com/flutter/flutter/issues/87364

  testWidgets('Local AppBarTheme overrides defaults', (WidgetTester tester) async {
    const Color backgroundColor = Colors.blueAccent;
    const Color foregroundColor = Colors.white;
    const double elevation = 1.0;
    const double scrolledUnderElevation = 2.0;
    const Color shadowColor = Colors.black87;
    const Color surfaceTintColor = Colors.transparent;
    const ShapeBorder shape = RoundedRectangleBorder();
    const IconThemeData iconTheme = IconThemeData(color: Colors.red);
    const IconThemeData actionsIconTheme = IconThemeData(color: Color(0xFF6750A4));
    const bool centerTitle = true;
    const double titleSpacing = 20.0;
    const double leadingWidth = 80.0;
    const double toolbarHeight = 100.0;
    const TextStyle toolbarTextStyle = TextStyle(color: Colors.yellow);
    const TextStyle titleTextStyle = TextStyle(color: Colors.orange);
    const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.dark;
    const EdgeInsetsGeometry actionsPadding = EdgeInsets.all(8);

    const AppBarThemeData appbarThemeData = AppBarThemeData(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      toolbarTextStyle: toolbarTextStyle,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      actionsPadding: actionsPadding,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppBarTheme(
          data: appbarThemeData,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Title'),
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            ),
          ),
        ),
      ),
    );

    final Material material = _getAppBarMaterial(tester);
    expect(material.color, backgroundColor);
    expect(material.elevation, elevation);
    expect(material.shadowColor, shadowColor);
    expect(material.surfaceTintColor, surfaceTintColor);
    expect(material.shape, shape);

    final IconTheme leadingIconTheme = _getAppBarIconTheme(tester);
    expect(leadingIconTheme.data, iconTheme);

    final IconTheme actionsIconThemeWidget = _getAppBarActionsIconTheme(tester);
    expect(actionsIconThemeWidget.data.color, appbarThemeData.actionsIconTheme!.color);
    expect(actionsIconThemeWidget.data.size, appbarThemeData.actionsIconTheme!.size);

    final NavigationToolbar navToolbar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolbar.centerMiddle, centerTitle);
    expect(navToolbar.middleSpacing, titleSpacing);

    final BoxConstraints leadingConstraints = (navToolbar.leading! as ConstrainedBox).constraints;
    expect(leadingConstraints.maxWidth, leadingWidth);
    expect(leadingConstraints.minWidth, leadingWidth);

    expect(tester.getSize(find.byType(AppBar)).height, toolbarHeight);

    final DefaultTextStyle text = _getAppBarText(tester);
    expect(text.style, toolbarTextStyle);

    final RichText titleText = tester.widget<RichText>(
      find.descendant(of: find.text('Title'), matching: find.byType(RichText)),
    );
    expect(titleText.text.style, titleTextStyle);

    expect(SystemChrome.latestStyle, systemOverlayStyle);

    final Padding actionsPaddingWidget = tester.widget<Padding>(
      find.descendant(of: find.byType(NavigationToolbar), matching: find.byType(Padding).last),
    );
    expect(actionsPaddingWidget.padding, actionsPadding);

    final Size appBarSize = tester.getSize(find.byType(AppBar));
    expect(appBarSize.height, toolbarHeight);
  });

  testWidgets('Local AppBarTheme can override global AppBarTheme', (WidgetTester tester) async {
    const Color backgroundColor = Colors.blueAccent;
    const Color foregroundColor = Colors.white;
    const double elevation = 1.0;
    const double scrolledUnderElevation = 2.0;
    const Color shadowColor = Colors.black87;
    const Color surfaceTintColor = Colors.transparent;
    const ShapeBorder shape = RoundedRectangleBorder();
    const IconThemeData iconTheme = IconThemeData(color: Colors.red);
    const IconThemeData actionsIconTheme = IconThemeData(color: Color(0xFF6750A4));
    const bool centerTitle = true;
    const double titleSpacing = 20.0;
    const double leadingWidth = 80.0;
    const double toolbarHeight = 100.0;
    const TextStyle toolbarTextStyle = TextStyle(color: Colors.yellow);
    const TextStyle titleTextStyle = TextStyle(color: Colors.orange);
    const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.dark;
    const EdgeInsetsGeometry actionsPadding = EdgeInsets.all(8);

    const AppBarThemeData appbarThemeData = AppBarThemeData(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      toolbarTextStyle: toolbarTextStyle,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      actionsPadding: actionsPadding,
    );
    const AppBarThemeData globalAppbarThemeData = AppBarThemeData(
      backgroundColor: Colors.red,
      foregroundColor: Colors.green,
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
      shadowColor: Colors.blue,
      surfaceTintColor: Colors.yellow,
      shape: RoundedRectangleBorder(),
      iconTheme: IconThemeData(color: Colors.black),
      actionsIconTheme: IconThemeData(color: Colors.purple),
      centerTitle: false,
      titleSpacing: 10.0,
      leadingWidth: 50.0,
      toolbarHeight: 50.0,
      toolbarTextStyle: TextStyle(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.black),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actionsPadding: EdgeInsets.zero,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: globalAppbarThemeData),
        home: AppBarTheme(
          data: appbarThemeData,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Title'),
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            ),
          ),
        ),
      ),
    );

    final Material material = _getAppBarMaterial(tester);
    expect(material.color, backgroundColor);
    expect(material.elevation, elevation);
    expect(material.shadowColor, shadowColor);
    expect(material.surfaceTintColor, surfaceTintColor);
    expect(material.shape, shape);

    final IconTheme leadingIconTheme = _getAppBarIconTheme(tester);
    expect(leadingIconTheme.data, iconTheme);

    final IconTheme actionsIconThemeWidget = _getAppBarActionsIconTheme(tester);
    expect(actionsIconThemeWidget.data.color, appbarThemeData.actionsIconTheme!.color);
    expect(actionsIconThemeWidget.data.size, appbarThemeData.actionsIconTheme!.size);

    final NavigationToolbar navToolbar = tester.widget(find.byType(NavigationToolbar));
    expect(navToolbar.centerMiddle, centerTitle);
    expect(navToolbar.middleSpacing, titleSpacing);

    final BoxConstraints leadingConstraints = (navToolbar.leading! as ConstrainedBox).constraints;
    expect(leadingConstraints.maxWidth, leadingWidth);
    expect(leadingConstraints.minWidth, leadingWidth);

    expect(tester.getSize(find.byType(AppBar)).height, toolbarHeight);

    final DefaultTextStyle text = _getAppBarText(tester);
    expect(text.style, toolbarTextStyle);

    final RichText titleText = tester.widget<RichText>(
      find.descendant(of: find.text('Title'), matching: find.byType(RichText)),
    );
    expect(titleText.text.style, titleTextStyle);

    expect(SystemChrome.latestStyle, systemOverlayStyle);

    final Padding actionsPaddingWidget = tester.widget<Padding>(
      find.descendant(of: find.byType(NavigationToolbar), matching: find.byType(Padding).last),
    );
    expect(actionsPaddingWidget.padding, actionsPadding);

    final Size appBarSize = tester.getSize(find.byType(AppBar));
    expect(appBarSize.height, toolbarHeight);
  });

  // This is a regression test for https://github.com/flutter/flutter/issues/130485.
  testWidgets(
    'Material3 - AppBarThemeData.iconTheme correctly applies custom white color in dark mode',
    (WidgetTester tester) async {
      final ThemeData themeData = ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarThemeData(iconTheme: IconThemeData(color: Colors.white)),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: themeData,
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              actions: <Widget>[IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            ),
          ),
        ),
      );

      Color? leadingIconButtonColor() => _iconStyle(tester, Icons.menu)?.color;
      Color? actionIconButtonColor() => _iconStyle(tester, Icons.add)?.color;

      expect(leadingIconButtonColor(), Colors.white);
      expect(actionIconButtonColor(), Colors.white);
    },
  );
}

AppBarThemeData _appBarTheme() {
  const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.dark;
  const Color backgroundColor = Colors.lightBlue;
  const double elevation = 6.0;
  const Color shadowColor = Colors.red;
  const Color surfaceTintColor = Colors.green;
  const IconThemeData iconThemeData = IconThemeData(color: Colors.black);
  const IconThemeData actionsIconThemeData = IconThemeData(color: Colors.pink);
  return const AppBarThemeData(
    actionsIconTheme: actionsIconThemeData,
    systemOverlayStyle: systemOverlayStyle,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shadowColor: shadowColor,
    surfaceTintColor: surfaceTintColor,
    shape: StadiumBorder(),
    iconTheme: iconThemeData,
    toolbarHeight: 96,
    toolbarTextStyle: TextStyle(color: Colors.yellow),
    titleTextStyle: TextStyle(color: Colors.pink),
  );
}

Material _getAppBarMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first,
  );
}

IconTheme _getAppBarIconTheme(WidgetTester tester) {
  return tester.widget<IconTheme>(
    find.descendant(of: find.byType(AppBar), matching: find.byType(IconTheme)).first,
  );
}

IconTheme _getAppBarActionsIconTheme(WidgetTester tester) {
  return tester.widget<IconTheme>(
    find.descendant(of: find.byType(NavigationToolbar), matching: find.byType(IconTheme)).first,
  );
}

RichText _getAppBarIconRichText(WidgetTester tester) {
  return tester.widget<RichText>(
    find.descendant(of: find.byType(Icon), matching: find.byType(RichText)).first,
  );
}

DefaultTextStyle _getAppBarText(WidgetTester tester) {
  return tester.widget<DefaultTextStyle>(
    find
        .descendant(
          of: find.byType(CustomSingleChildLayout),
          matching: find.byType(DefaultTextStyle),
        )
        .first,
  );
}

TextStyle? _iconStyle(WidgetTester tester, IconData icon) {
  final RichText iconRichText = tester.widget<RichText>(
    find.descendant(of: find.byIcon(icon).first, matching: find.byType(RichText)),
  );
  return iconRichText.text.style;
}
