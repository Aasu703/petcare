import 'package:flutter/material.dart';
import 'package:petcare/core/constants/app_spacing.dart';

/// Standardized scaffold wrapper used across pages for consistent layout.
///
/// Provides optional title, back button, and body content with uniform padding.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
    this.padding = Insets.screenH,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;

  /// Plain text title for the app bar. Ignored if [titleWidget] is set.
  final String? title;

  /// Custom title widget (e.g. a search bar).
  final Widget? titleWidget;

  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final EdgeInsets padding;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final bool hasAppBar =
        title != null || titleWidget != null || showBackButton;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: hasAppBar
          ? AppBar(
              title:
                  titleWidget ??
                  (title != null
                      ? Text(
                          title!,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        )
                      : null),
              centerTitle: false,
              automaticallyImplyLeading: showBackButton,
              actions: actions,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        top: !hasAppBar,
        child: Padding(padding: padding, child: body),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
