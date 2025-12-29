import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/inventory_repository.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _repository;

  InventoryCubit(this._repository) : super(InventoryInitial());

  // Fetch all inventory items
  Future<void> fetchInventory() async {
    emit(InventoryLoading());
    try {
      final items = await _repository.getAllInventory();
      final movements = await _repository.getAllMovements();
      emit(InventoryLoaded(items: items, movements: movements));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Fetch low stock items only
  Future<void> fetchLowStockItems() async {
    emit(InventoryLoading());
    try {
      final items = await _repository.getLowStockItems();
      emit(InventoryLoaded(items: items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Fetch out of stock items only
  Future<void> fetchOutOfStockItems() async {
    emit(InventoryLoading());
    try {
      final items = await _repository.getOutOfStockItems();
      emit(InventoryLoaded(items: items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Update stock quantity
  Future<void> updateStock(
    String productId,
    int newQuantity, {
    int? minStockLevel,
  }) async {
    try {
      await _repository.updateStock(productId, newQuantity,
          minStockLevel: minStockLevel);
      emit(InventoryOperationSuccess('Stock updated successfully'));
      fetchInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Update stock with movement record
  Future<void> updateStockWithMovement({
    required String productId,
    required String movementType,
    required int quantity,
    String? reason,
    String? notes,
    String? createdBy,
    int? minStockLevel,
  }) async {
    try {
      await _repository.updateStockWithMovement(
        productId: productId,
        movementType: movementType,
        quantity: quantity,
        reason: reason,
        notes: notes,
        createdBy: createdBy,
        minStockLevel: minStockLevel,
      );
      emit(InventoryOperationSuccess('Stock movement recorded successfully'));
      fetchInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Add stock
  Future<void> addStock(String productId, int quantity,
      {String? reason, String? notes}) async {
    try {
      await _repository.updateStockWithMovement(
        productId: productId,
        movementType: 'in',
        quantity: quantity,
        reason: reason,
        notes: notes,
      );
      emit(InventoryOperationSuccess('Stock added successfully'));
      fetchInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Remove stock
  Future<void> removeStock(String productId, int quantity,
      {String? reason, String? notes}) async {
    try {
      await _repository.updateStockWithMovement(
        productId: productId,
        movementType: 'out',
        quantity: quantity,
        reason: reason,
        notes: notes,
      );
      emit(InventoryOperationSuccess('Stock removed successfully'));
      fetchInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Adjust stock (set to specific value)
  Future<void> adjustStock(
    String productId,
    int newQuantity, {
    String? reason,
    String? notes,
    int? minStockLevel,
  }) async {
    try {
      await _repository.updateStockWithMovement(
        productId: productId,
        movementType: 'adjustment',
        quantity: newQuantity,
        reason: reason,
        notes: notes,
        minStockLevel: minStockLevel,
      );
      emit(InventoryOperationSuccess('Stock adjusted successfully'));
      fetchInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Fetch stock movements
  Future<void> fetchMovements() async {
    try {
      final movements = await _repository.getAllMovements();
      emit(StockMovementsLoaded(movements));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Fetch movements for specific product
  Future<void> fetchProductMovements(String productId) async {
    try {
      final movements = await _repository.getProductMovements(productId);
      emit(StockMovementsLoaded(movements));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Search inventory
  Future<void> searchInventory(String query) async {
    if (query.isEmpty) {
      fetchInventory();
      return;
    }

    emit(InventoryLoading());
    try {
      final items = await _repository.searchInventory(query);
      emit(InventoryLoaded(items: items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // Get inventory stats
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      return await _repository.getInventoryStats();
    } catch (e) {
      return {
        'total_products': 0,
        'in_stock': 0,
        'low_stock': 0,
        'out_of_stock': 0,
        'total_value': 0.0,
      };
    }
  }
}
