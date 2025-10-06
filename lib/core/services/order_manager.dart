import 'package:smart_ahwa_manager_app/core/interfaces/i_drink.dart';
import 'package:smart_ahwa_manager_app/core/interfaces/i_order_repository.dart';
import 'package:smart_ahwa_manager_app/core/models/customer.dart';
import 'package:smart_ahwa_manager_app/core/models/order.dart';

class OrderManager {
  final IOrderRepository _orderRepository;

  OrderManager(this._orderRepository);

  Future<void> createOrder(
    Customer customer,
    IDrink drink,
    String instructions,
  ) async {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customer: customer,
      drink: drink,
      specialInstructions: instructions,
      orderTime: DateTime.now(),
    );
    await _orderRepository.addOrder(order);
  }

  Future<void> completeOrder(String orderId) async {
    final allOrders = await _orderRepository.getAllOrders();
    final orderToComplete = allOrders.firstWhere(
      (order) => order.id == orderId,
    );
    orderToComplete.markAsCompleted();
    await _orderRepository.updateOrder(orderToComplete);
  }

  Future<List<Order>> getPendingOrders() async {
    return _orderRepository.getPendingOrders();
  }
}
