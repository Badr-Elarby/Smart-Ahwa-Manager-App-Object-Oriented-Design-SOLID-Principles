import 'package:smart_ahwa_manager_app/core/interfaces/i_order_repository.dart';
import 'package:smart_ahwa_manager_app/core/interfaces/i_report_service.dart';
import 'package:smart_ahwa_manager_app/core/models/order.dart';

class ReportService implements IReportService {
  final IOrderRepository _orderRepository;

  ReportService(this._orderRepository);

  @override
  Future<String> getMostPopularDrink() async {
    final allOrders = await _orderRepository.getAllOrders();
    if (allOrders.isEmpty) return 'No orders yet.';

    final drinkCounts = <String, int>{};
    for (var order in allOrders.where(
      (o) => o.status == OrderStatus.completed,
    )) {
      drinkCounts[order.drink.name] = (drinkCounts[order.drink.name] ?? 0) + 1;
    }

    if (drinkCounts.isEmpty) return 'No completed orders yet.';

    final sortedDrinks = drinkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedDrinks.first.key;
  }

  @override
  Future<int> getTotalServedOrders() async {
    final allOrders = await _orderRepository.getAllOrders();
    return allOrders
        .where((order) => order.status == OrderStatus.completed)
        .length;
  }
}
