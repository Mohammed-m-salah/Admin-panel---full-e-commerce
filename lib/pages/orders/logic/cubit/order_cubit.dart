import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit(this._orderRepository) : super(OrderInitial());

  // Fetch all orders
  Future<void> fetchOrders() async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getAllOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Fetch orders by status
  Future<void> fetchOrdersByStatus(String status) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrdersByStatus(status);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Fetch orders by payment status
  Future<void> fetchOrdersByPaymentStatus(String paymentStatus) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrdersByPaymentStatus(paymentStatus);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Fetch orders by customer ID
  Future<void> fetchOrdersByCustomerId(String customerId) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrdersByCustomerId(customerId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Fetch orders by date range
  Future<void> fetchOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrdersByDateRange(startDate, endDate);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Add new order
  Future<void> addOrder(OrderModel order) async {
    try {
      await _orderRepository.addOrder(order);
      emit(OrderOperationSuccess('Order added successfully'));
      fetchOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Update order
  Future<void> updateOrder(OrderModel order) async {
    try {
      await _orderRepository.updateOrder(order);
      emit(OrderOperationSuccess('Order updated successfully'));
      fetchOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Update order status only
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      emit(OrderOperationSuccess('Order status updated successfully'));
      fetchOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Update payment status only
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _orderRepository.updatePaymentStatus(orderId, paymentStatus);
      emit(OrderOperationSuccess('Payment status updated successfully'));
      fetchOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Update both order and payment status
  Future<void> updateOrderAndPaymentStatus(
      String orderId, String status, String paymentStatus, String? notes) async {
    try {
      await _orderRepository.updateOrderAndPaymentStatus(
          orderId, status, paymentStatus, notes);
      emit(OrderOperationSuccess('Order updated successfully'));
      fetchOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Delete order
  Future<void> deleteOrder(String id) async {
    try {
      await _orderRepository.deleteOrder(id);
      emit(OrderOperationSuccess('Order deleted successfully'));
      fetchOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Search orders
  Future<void> searchOrders(String query) async {
    if (query.isEmpty) {
      fetchOrders();
      return;
    }

    emit(OrderLoading());
    try {
      final orders = await _orderRepository.searchOrders(query);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // Generate order number
  Future<String> generateOrderNumber() async {
    return await _orderRepository.generateOrderNumber();
  }
}
