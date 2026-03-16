import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/inventory_item_model.dart';

abstract class InventoryLocalDataSource {
  Future<List<InventoryItemModel>> getItems();
  Future<void> addItem(InventoryItemModel item);
  Future<void> updateItem(InventoryItemModel item);
  Future<void> deleteItem(int id);
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final DatabaseHelper databaseHelper;

  InventoryLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<void> addItem(InventoryItemModel item) async {
    final Database db = await databaseHelper.database;

    await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<InventoryItemModel>> getItems() async {
    final Database db = await databaseHelper.database;

    final result = await db.query(
      'inventory',
      orderBy: 'created_at DESC',
    );

    return result.map((e) => InventoryItemModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateItem(InventoryItemModel item) async {
    final Database db = await databaseHelper.database;

    await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteItem(int id) async {
    final Database db = await databaseHelper.database;

    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}