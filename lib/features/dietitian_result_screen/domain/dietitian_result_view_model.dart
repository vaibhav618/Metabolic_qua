import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;

class DietitianResultViewModel {
  final ScrollController scrollController = ScrollController();
  final ScrollController tabScrollController = ScrollController();

  // Section anchor keys (use ONLY in parent KeyedSubtree)
  final GlobalKey fatAnchorKey = GlobalKey(debugLabel: "fat_anchor");
  final GlobalKey gutAnchorKey = GlobalKey(debugLabel: "gut_anchor");
  final GlobalKey liverAnchorKey = GlobalKey(debugLabel: "liver_anchor");

  // Tab keys (use ONLY on TabWidget)
  final GlobalKey tabFatKey = GlobalKey(debugLabel: "tab_fat");
  final GlobalKey tabGutKey = GlobalKey(debugLabel: "tab_gut");
  final GlobalKey tabLiverKey = GlobalKey(debugLabel: "tab_liver");

  bool isAnimating = false;

  double _pinnedHeaderHeight = 0;
  void setPinnedHeaderHeight(double height) {
    _pinnedHeaderHeight = height;
  }

  Future<void> scrollToSection(
      GlobalKey anchorKey, {
        double appBarHeight = kToolbarHeight,
        double extraTopPadding = 8,
      }) async {
    if (isAnimating) return;
    if (!scrollController.hasClients) return;

    final ctx = anchorKey.currentContext;
    if (ctx == null) return;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;

    final reveal = viewport.getOffsetToReveal(renderObject, 0.0);
    final rawTarget = reveal.offset;

    final topBlocker = appBarHeight + _pinnedHeaderHeight + extraTopPadding;

    final target = (rawTarget - topBlocker).clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );

    isAnimating = true;
    try {
      await scrollController.animateTo(
        target.toDouble(),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    } finally {
      isAnimating = false;
    }
  }

  Future<void> tabScrollTo(GlobalKey tabKey) async {
    if (!tabScrollController.hasClients) return;

    final ctx = tabKey.currentContext;
    if (ctx == null) return;

    final tabRender = ctx.findRenderObject();
    if (tabRender == null || tabRender is! RenderBox) return;

    final tabBarRender =
    tabScrollController.position.context.storageContext.findRenderObject();
    if (tabBarRender == null || tabBarRender is! RenderBox) return;

    final tabWidth = tabRender.size.width;
    final tabBarWidth = tabBarRender.size.width;

    final tabLeftInBar =
        tabRender.localToGlobal(Offset.zero, ancestor: tabBarRender).dx;

    final tabOffsetInScroll = tabLeftInBar + tabScrollController.offset;

    final target = (tabOffsetInScroll - (tabBarWidth / 2) + (tabWidth / 2)).clamp(
      tabScrollController.position.minScrollExtent,
      tabScrollController.position.maxScrollExtent,
    );

    await tabScrollController.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  double? getSectionRevealOffset(GlobalKey anchorKey) {
    if (!scrollController.hasClients) return null;

    final ctx = anchorKey.currentContext;
    if (ctx == null) return null;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return null;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return null;

    return viewport.getOffsetToReveal(renderObject, 0.0).offset;
  }

  void dispose() {
    scrollController.dispose();
    tabScrollController.dispose();
  }
}
