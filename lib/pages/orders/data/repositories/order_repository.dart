import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/order_model.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all orders
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromMap(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Fetch orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromMap(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  // Fetch orders by payment status
  Future<List<OrderModel>> getOrdersByPaymentStatus(String paymentStatus) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('payment_status', paymentStatus)
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromMap(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by payment status: $e');
    }
  }

  // Fetch single order by ID
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('id', id)
          .single();

      return OrderModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Fetch order by order number
  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_number', orderNumber)
          .single();

      return OrderModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch order by number: $e');
    }
  }

  // Fetch orders by customer ID
  Future<List<OrderModel>> getOrdersByCustomerId(String customerId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromMap(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customer orders: $e');
    }
  }

  // Fetch orders by date range
  Future<List<OrderModel>> getOrdersByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromMap(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by date range: $e');
    }
  }

  // Add new order
  Future<void> addOrder(OrderModel order) async {
    try {
      final orderData = order.toMap();
      orderData.remove('id');

      await _supabase.from('orders').insert(orderData);
    } catch (e) {
      throw Exception('Failed to add order: $e');
    }
  }

  // Update order
  Future<void> updateOrder(OrderModel order) async {
    try {
      final orderData = order.toMap();
      orderData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('orders')
          .update(orderData)
          .eq('id', order.id!);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _supabase.from('orders').update({
        'payment_status': paymentStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Update both order status and payment status
  Future<void> updateOrderAndPaymentStatus(
      String orderId, String status, String paymentStatus, String? notes) async {
    try {
      final updateData = {
        'status': status,
        'payment_status': paymentStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null && notes.isNotEmpty) {
        updateData['notes'] = notes;
      }

      await _supabase.from('orders').update(updateData).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Delete order
  Future<void> deleteOrder(String id) async {
    try {
      await _supabase.from('orders').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // Search orders
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .or('order_number.ilike.%$query%,customer_name.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromMap(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  // Get orders statistics
  Future<Map<String, dynamic>> getOrdersStatistics() async {
    try {
      final allOrders = await getAllOrders();

      final totalOrders = allOrders.length;
      final pendingOrders =
          allOrders.where((o) => o.status == 'pending').length;
      final processingOrders =
          allOrders.where((o) => o.status == 'processing').length;
      final shippedOrders =
          allOrders.where((o) => o.status == 'shipped').length;
      final deliveredOrders =
          allOrders.where((o) => o.status == 'delivered').length;
      final cancelledOrders =
          allOrders.where((o) => o.status == 'cancelled').length;
      final refundedOrders =
          allOrders.where((o) => o.status == 'refunded').length;

      final totalRevenue = allOrders
          .where((o) => o.paymentStatus == 'paid')
          .fold(0.0, (sum, o) => sum + o.total);

      final paidOrders =
          allOrders.where((o) => o.paymentStatus == 'paid').length;
      final unpaidOrders =
          allOrders.where((o) => o.paymentStatus == 'pending').length;

      return {
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'processing_orders': processingOrders,
        'shipped_orders': shippedOrders,
        'delivered_orders': deliveredOrders,
        'cancelled_orders': cancelledOrders,
        'refunded_orders': refundedOrders,
        'total_revenue': totalRevenue,
        'paid_orders': paidOrders,
        'unpaid_orders': unpaidOrders,
      };
    } catch (e) {
      throw Exception('Failed to get orders statistics: $e');
    }
  }

  // Generate unique order number
  Future<String> generateOrderNumber() async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    try {
      // Get count of orders for today
      final response = await _supabase
          .from('orders')
          .select('id')
          .gte('created_at', DateTime(now.year, now.month, now.day).toIso8601String())
          .lte('created_at', DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String());

      final count = (response as List).length + 1;
      final orderNumber = 'ORD-$year$month$day-${count.toString().padLeft(4, '0')}';

      return orderNumber;
    } catch (e) {
      // Fallback with timestamp
      final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
      return 'ORD-$year$month$day-$timestamp';
    }
  }
}
