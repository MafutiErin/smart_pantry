// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AIChatPage]
class AIChatRoute extends PageRouteInfo<void> {
  const AIChatRoute({List<PageRouteInfo>? children})
    : super(AIChatRoute.name, initialChildren: children);

  static const String name = 'AIChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AIChatPage();
    },
  );
}

/// generated route for
/// [AddItemPage]
class AddItemRoute extends PageRouteInfo<void> {
  const AddItemRoute({List<PageRouteInfo>? children})
    : super(AddItemRoute.name, initialChildren: children);

  static const String name = 'AddItemRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddItemPage();
    },
  );
}

/// generated route for
/// [BarcodeScannerPage]
class BarcodeScannerRoute extends PageRouteInfo<void> {
  const BarcodeScannerRoute({List<PageRouteInfo>? children})
    : super(BarcodeScannerRoute.name, initialChildren: children);

  static const String name = 'BarcodeScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BarcodeScannerPage();
    },
  );
}

/// generated route for
/// [EditItemPage]
class EditItemRoute extends PageRouteInfo<EditItemRouteArgs> {
  EditItemRoute({
    Key? key,
    required InventoryItem item,
    List<PageRouteInfo>? children,
  }) : super(
         EditItemRoute.name,
         args: EditItemRouteArgs(key: key, item: item),
         initialChildren: children,
       );

  static const String name = 'EditItemRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditItemRouteArgs>();
      return EditItemPage(key: args.key, item: args.item);
    },
  );
}

class EditItemRouteArgs {
  const EditItemRouteArgs({this.key, required this.item});

  final Key? key;

  final InventoryItem item;

  @override
  String toString() {
    return 'EditItemRouteArgs{key: $key, item: $item}';
  }
}

/// generated route for
/// [InventoryListPage]
class InventoryListRoute extends PageRouteInfo<void> {
  const InventoryListRoute({List<PageRouteInfo>? children})
    : super(InventoryListRoute.name, initialChildren: children);

  static const String name = 'InventoryListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InventoryListPage();
    },
  );
}

/// generated route for
/// [ItemDetailPage]
class ItemDetailRoute extends PageRouteInfo<ItemDetailRouteArgs> {
  ItemDetailRoute({
    Key? key,
    required InventoryItem item,
    required int index,
    List<PageRouteInfo>? children,
  }) : super(
         ItemDetailRoute.name,
         args: ItemDetailRouteArgs(key: key, item: item, index: index),
         initialChildren: children,
       );

  static const String name = 'ItemDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ItemDetailRouteArgs>();
      return ItemDetailPage(key: args.key, item: args.item, index: args.index);
    },
  );
}

class ItemDetailRouteArgs {
  const ItemDetailRouteArgs({
    this.key,
    required this.item,
    required this.index,
  });

  final Key? key;

  final InventoryItem item;

  final int index;

  @override
  String toString() {
    return 'ItemDetailRouteArgs{key: $key, item: $item, index: $index}';
  }
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}
