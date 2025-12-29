import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/inventory_model.dart';

class InventoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<InventoryModel>> getAllInventory() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*')
          .order('stock', ascending: true); // الأقل كمية أولاً

      return (response as List).map((item) {
        return _mapToInventoryModel(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  Future<List<InventoryModel>> getLowStockItems() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*')
          .gt('stock', 0)
          .lte('stock', 10) // الحد الافتراضي للمخزون المنخفض
          .order('stock', ascending: true);

      return (response as List).map((item) {
        return _mapToInventoryModel(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock items: $e');
    }
  }

  Future<List<InventoryModel>> getOutOfStockItems() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*')
          .lte('stock', 0)
          .order('name');

      return (response as List).map((item) {
        return _mapToInventoryModel(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch out of stock items: $e');
    }
  }

  Future<List<InventoryModel>> searchInventory(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*')
          .ilike('name', '%$query%')
          .order('stock', ascending: true);

      return (response as List).map((item) {
        return _mapToInventoryModel(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search inventory: $e');
    }
  }

  Future<void> updateStock(String productId, int newQuantity,
      {int? minStockLevel}) async {
    try {
      final updateData = <String, dynamic>{
        'stock': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newQuantity <= 0) {
        updateData['stock_status'] = 'Out of Stock';
      } else if (newQuantity <= (minStockLevel ?? 10)) {
        updateData['stock_status'] = 'Low Stock';
      } else {
        updateData['stock_status'] = 'In Stock';
      }

      await _supabase.from('products').update(updateData).eq('id', productId);
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  Future<void> addStock(String productId, int quantity) async {
    try {
      final response = await _supabase
          .from('products')
          .select('stock')
          .eq('id', productId)
          .single();

      final currentStock = _parseStock(response['stock']);
      final newStock = currentStock + quantity;

      await updateStock(productId, newStock);
    } catch (e) {
      throw Exception('Failed to add stock: $e');
    }
  }

  Future<void> removeStock(String productId, int quantity) async {
    try {
      final response = await _supabase
          .from('products')
          .select('stock')
          .eq('id', productId)
          .single();

      final currentStock = _parseStock(response['stock']);
      final newStock = (currentStock - quantity).clamp(0, 999999);

      await updateStock(productId, newStock);
    } catch (e) {
      throw Exception('Failed to remove stock: $e');
    }
  }

  Future<List<StockMovementModel>> getAllMovements() async {
    try {
      // تحقق من وجود جدول stock_movements
      final response = await _supabase
          .from('stock_movements')
          .select('*')
          .order('created_at', ascending: false)
          .limit(100);

      return (response as List).map((item) {
        return StockMovementModel(
          id: item['id']?.toString(),
          productId: item['product_id']?.toString() ?? '',
          productName: item['product_name'] ?? '',
          movementType: item['movement_type'] ?? '',
          quantity: item['quantity'] ?? 0,
          previousStock: item['previous_stock'] ?? 0,
          newStock: item['new_stock'] ?? 0,
          reason: item['reason'],
          notes: item['notes'],
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
          createdBy: item['created_by'],
        );
      }).toList();
    } catch (e) {
      // إذا لم يكن جدول stock_movements موجوداً، أرجع قائمة فارغة
      return [];
    }
  }

  Future<List<StockMovementModel>> getProductMovements(String productId) async {
    try {
      final response = await _supabase
          .from('stock_movements')
          .select('*')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return StockMovementModel(
          id: item['id']?.toString(),
          productId: item['product_id']?.toString() ?? '',
          productName: item['product_name'] ?? '',
          movementType: item['movement_type'] ?? '',
          quantity: item['quantity'] ?? 0,
          previousStock: item['previous_stock'] ?? 0,
          newStock: item['new_stock'] ?? 0,
          reason: item['reason'],
          notes: item['notes'],
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
          createdBy: item['created_by'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addStockMovement({
    required String productId,
    required String productName,
    required String movementType,
    required int quantity,
    required int previousStock,
    required int newStock,
    String? reason,
    String? notes,
    String? createdBy,
  }) async {
    try {
      await _supabase.from('stock_movements').insert({
        'product_id': productId,
        'product_name': productName,
        'movement_type': movementType,
        'quantity': quantity,
        'previous_stock': previousStock,
        'new_stock': newStock,
        'reason': reason,
        'notes': notes,
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // تجاهل الخطأ إذا لم يكن جدول stock_movements موجوداً
      print('Stock movement not recorded: $e');
    }
  }

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
      // جلب بيانات المنتج الحالية
      final response = await _supabase
          .from('products')
          .select('stock, name')
          .eq('id', productId)
          .single();

      final previousStock = _parseStock(response['stock']);
      final productName = response['name'] ?? '';
      int newStock;

      // حساب الكمية الجديدة
      switch (movementType) {
        case 'in':
          newStock = previousStock + quantity;
          break;
        case 'out':
          newStock = (previousStock - quantity).clamp(0, 999999);
          break;
        case 'adjustment':
          newStock = quantity;
          break;
        default:
          newStock = previousStock;
      }

      // تحديث المخزون
      await updateStock(productId, newStock, minStockLevel: minStockLevel);

      // تسجيل الحركة
      await addStockMovement(
        productId: productId,
        productName: productName,
        movementType: movementType,
        quantity: movementType == 'adjustment'
            ? (newStock - previousStock).abs()
            : quantity,
        previousStock: previousStock,
        newStock: newStock,
        reason: reason,
        notes: notes,
        createdBy: createdBy,
      );
    } catch (e) {
      throw Exception('Failed to update stock with movement: $e');
    }
  }

  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final response = await _supabase.from('products').select('stock, price');

      final items = response as List;

      int totalProducts = items.length;
      int inStock = 0;
      int lowStock = 0;
      int outOfStock = 0;
      double totalValue = 0;

      for (var item in items) {
        final qty = _parseStock(item['stock']);
        final price = _parsePrice(item['price']);
        const minLevel = 10; // الحد الافتراضي

        if (qty <= 0) {
          outOfStock++;
        } else if (qty <= minLevel) {
          lowStock++;
        } else {
          inStock++;
        }

        totalValue += qty * price;
      }

      return {
        'total_products': totalProducts,
        'in_stock': inStock,
        'low_stock': lowStock,
        'out_of_stock': outOfStock,
        'total_value': totalValue,
      };
    } catch (e) {
      throw Exception('Failed to get inventory stats: $e');
    }
  }

  /// تحويل بيانات المنتج إلى InventoryModel
  InventoryModel _mapToInventoryModel(Map<String, dynamic> item) {
    return InventoryModel(
      id: item['id']?.toString(),
      productId: item['id']?.toString() ?? '',
      productName: item['name'] ?? '',
      productImage: item['image_url'],
      sku: item['sku'],
      category: item['category']?.toString(),
      quantity: _parseStock(item['stock']),
      minStockLevel: 10, // القيمة الافتراضية
      unitPrice: _parsePrice(item['price']),
      lastUpdated: item['updated_at'] != null
          ? DateTime.tryParse(item['updated_at'])
          : null,
    );
  }

  /// تحويل آمن للمخزون
  int _parseStock(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// تحويل آمن للسعر
  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
