import '../../data/model/inventory_model.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryModel> items;
  final List<StockMovementModel> movements;

  InventoryLoaded({
    required this.items,
    this.movements = const [],
  });
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);
}

class InventoryOperationSuccess extends InventoryState {
  final String message;

  InventoryOperationSuccess(this.message);
}

/// حالة تحميل الحركات فقط
class StockMovementsLoaded extends InventoryState {
  final List<StockMovementModel> movements;

  StockMovementsLoaded(this.movements);
}

/// حالة تحميل الإحصائيات
class InventoryStatsLoaded extends InventoryState {
  final Map<String, dynamic> stats;

  InventoryStatsLoaded(this.stats);
}
