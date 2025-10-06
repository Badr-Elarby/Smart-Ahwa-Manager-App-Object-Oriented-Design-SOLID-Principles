import 'package:smart_ahwa_manager_app/core/interfaces/i_drink.dart';
import 'package:smart_ahwa_manager_app/core/models/customer.dart';

enum OrderStatus { pending, completed }

class Order {
  final String id;
  final Customer customer;
  final IDrink drink;
  final String specialInstructions;
  OrderStatus status;
  final DateTime orderTime;
  DateTime? completionTime;

  Order({
    required this.id,
    required this.customer,
    required this.drink,
    this.specialInstructions = '',
    this.status = OrderStatus.pending,
    required this.orderTime,
    this.completionTime,
  });

  void markAsCompleted() {
    if (status == OrderStatus.pending) {
      status = OrderStatus.completed;
      completionTime = DateTime.now();
    }
  }
}
