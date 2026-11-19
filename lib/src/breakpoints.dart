import 'package:flutter/widgets.dart';

/// Screen size classes.
enum ScreenSize {
  /// Phones.
  mobile,

  /// Tablets and small windows.
  tablet,

  /// Laptops and large windows.
  desktop;

  /// Whether this is [mobile].
  bool get isMobile => this == mobile;

  /// Whether this is [tablet].
  bool get isTablet => this == tablet;

  /// Whether this is [desktop].
  bool get isDesktop => this == desktop;
}

/// Width thresholds between size classes.
@immutable
class Breakpoints {
  /// Creates breakpoints. Widths below [tablet] are mobile, widths below
  /// [desktop] are tablet, and the rest are desktop.
  const Breakpoints({this.tablet = 600, this.desktop = 1024})
      : assert(tablet < desktop);

  /// First width that counts as tablet.
  final double tablet;

  /// First width that counts as desktop.
  final double desktop;

  /// The size class for [width].
  ScreenSize sizeFor(double width) {
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

/// Provides [Breakpoints] to the widgets below it.
class BreakpointScope extends InheritedWidget {
  /// Creates the scope.
  const BreakpointScope({
    super.key,
    required this.breakpoints,
    required super.child,
  });

  /// The breakpoints to use below this widget.
  final Breakpoints breakpoints;

  /// The nearest breakpoints, or the defaults.
  static Breakpoints of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<BreakpointScope>()
          ?.breakpoints ??
      const Breakpoints();

  @override
  bool updateShouldNotify(BreakpointScope oldWidget) =>
      oldWidget.breakpoints.tablet != breakpoints.tablet ||
      oldWidget.breakpoints.desktop != breakpoints.desktop;
}

/// Responsive helpers on [BuildContext], based on the screen width.
extension BreakpointContext on BuildContext {
  /// The size class of the screen.
  ScreenSize get screenSize =>
      BreakpointScope.of(this).sizeFor(MediaQuery.sizeOf(this).width);

  /// Whether the screen is mobile-sized.
  bool get isMobile => screenSize.isMobile;

  /// Whether the screen is tablet-sized.
  bool get isTablet => screenSize.isTablet;

  /// Whether the screen is desktop-sized.
  bool get isDesktop => screenSize.isDesktop;

  /// Picks a value for the current size. Missing values fall back to the
  /// next smaller size.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) =>
      ResponsiveValue(mobile: mobile, tablet: tablet, desktop: desktop)
          .forSize(screenSize);
}

/// A value that differs by screen size.
@immutable
class ResponsiveValue<T> {
  /// Creates the value. [tablet] falls back to [mobile]; [desktop] falls back
  /// to [tablet], then [mobile].
  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  /// Value on mobile.
  final T mobile;

  /// Value on tablet.
  final T? tablet;

  /// Value on desktop.
  final T? desktop;

  /// The value for [size].
  T forSize(ScreenSize size) => switch (size) {
        ScreenSize.mobile => mobile,
        ScreenSize.tablet => tablet ?? mobile,
        ScreenSize.desktop => desktop ?? tablet ?? mobile,
      };

  /// The value for the current screen.
  T of(BuildContext context) => forSize(context.screenSize);
}

/// Builds different layouts for mobile, tablet and desktop.
///
/// By default it uses the screen width. Set [useParentWidth] to use the
/// space given by the parent instead (handy inside side panels).
class BreakpointBuilder extends StatelessWidget {
  /// Creates the builder. [tablet] falls back to [mobile]; [desktop] falls
  /// back to [tablet], then [mobile].
  const BreakpointBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.useParentWidth = false,
  });

  /// Layout for mobile.
  final WidgetBuilder mobile;

  /// Layout for tablet.
  final WidgetBuilder? tablet;

  /// Layout for desktop.
  final WidgetBuilder? desktop;

  /// Whether to measure the parent's width instead of the screen's.
  final bool useParentWidth;

  @override
  Widget build(BuildContext context) {
    final value = ResponsiveValue<WidgetBuilder>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    if (!useParentWidth) return value.of(context)(context);
    final breakpoints = BreakpointScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) =>
          value.forSize(breakpoints.sizeFor(constraints.maxWidth))(context),
    );
  }
}
