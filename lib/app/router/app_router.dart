import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/inventory/domain/entities/inventory_item.dart';
import '../../features/inventory/presentation/pages/add_item_page.dart';
import '../../features/inventory/presentation/pages/ai_chat_page.dart';
import '../../features/inventory/presentation/pages/barcode_scanner_page.dart';
import '../../features/inventory/presentation/pages/edit_item_page.dart';
import '../../features/inventory/presentation/pages/inventory_list_page.dart';
import '../../features/inventory/presentation/pages/item_detail_page.dart';
import '../../features/inventory/presentation/pages/splash_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: InventoryListRoute.page),
    AutoRoute(page: AddItemRoute.page),
    CustomRoute(
      page: ItemDetailRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 260,
    ),
    AutoRoute(page: EditItemRoute.page),
    AutoRoute(page: AIChatRoute.page),
    AutoRoute(page: BarcodeScannerRoute.page),
  ];
}
