import 'package:smart_ahwa_manager_app/core/interfaces/i_order_repository.dart';
import 'package:smart_ahwa_manager_app/core/models/order.dart';

class InMemoryOrderRepository implements IOrderRepository {
  final List<Order> _orders = [];

  @override
  Future<void> addOrder(Order order) async {
    _orders.add(order);
  }

  @override
  Future<void> updateOrder(Order order) async {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
    }
  }

  @override
  Future<List<Order>> getPendingOrders() async {
    return _orders
        .where((order) => order.status == OrderStatus.pending)
        .toList();
  }

  @override
  Future<List<Order>> getAllOrders() async {
    return List.unmodifiable(_orders);
  }
}
