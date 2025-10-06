import 'package:smart_ahwa_manager_app/core/models/order.dart';

abstract class IOrderRepository {
  Future<void> addOrder(Order order);
  Future<void> updateOrder(Order order);
  Future<List<Order>> getPendingOrders();
  Future<List<Order>> getAllOrders();
}
