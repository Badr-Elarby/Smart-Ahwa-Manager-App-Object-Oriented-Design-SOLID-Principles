import 'package:flutter/material.dart';
import 'package:smart_ahwa_manager_app/core/interfaces/i_drink.dart';
import 'package:smart_ahwa_manager_app/core/interfaces/i_order_repository.dart';
import 'package:smart_ahwa_manager_app/core/interfaces/i_report_service.dart';
import 'package:smart_ahwa_manager_app/core/models/customer.dart';
import 'package:smart_ahwa_manager_app/core/models/order.dart';
import 'package:smart_ahwa_manager_app/core/services/order_manager.dart';
import 'package:smart_ahwa_manager_app/core/services/report_service.dart';
import 'package:smart_ahwa_manager_app/data/drinks/hibiscus_tea.dart';
import 'package:smart_ahwa_manager_app/data/drinks/shai.dart';
import 'package:smart_ahwa_manager_app/data/drinks/turkish_coffee.dart';
import 'package:smart_ahwa_manager_app/data/repositories/in_memory_order_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Ahwa Manager',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system, // Follow system theme
      home: const AhwaManagerHomePage(),
    );
  }
}

class AhwaManagerHomePage extends StatefulWidget {
  const AhwaManagerHomePage({super.key});

  @override
  State<AhwaManagerHomePage> createState() => _AhwaManagerHomePageState();
}

class _AhwaManagerHomePageState extends State<AhwaManagerHomePage> {
  // --- Business Logic Instances (unchanged) ---
  final IOrderRepository _orderRepository = InMemoryOrderRepository();
  late final OrderManager _orderManager;
  late final IReportService _reportService;

  // --- UI State ---
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _drinkTypeController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();
  List<Order> _pendingOrders = [];
  String _mostPopularDrink = 'N/A';
  int _totalServedOrders = 0;
  IDrink? _selectedDrink; // To hold the selected drink object

  @override
  void initState() {
    super.initState();
    _orderManager = OrderManager(_orderRepository);
    _reportService = ReportService(_orderRepository);
    _loadOrders();
    _generateReports();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _drinkTypeController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final orders = await _orderManager.getPendingOrders();
    setState(() {
      _pendingOrders = orders;
    });
  }

  Future<void> _generateReports() async {
    final popularDrink = await _reportService.getMostPopularDrink();
    final servedOrders = await _reportService.getTotalServedOrders();
    setState(() {
      _mostPopularDrink = popularDrink;
      _totalServedOrders = servedOrders;
    });
  }

  IDrink? _getDrinkInstance(String drinkName) {
    switch (drinkName.toLowerCase()) {
      case 'shai':
        return Shai();
      case 'turkish coffee':
        return TurkishCoffee();
      case 'hibiscus tea':
        return HibiscusTea();
      default:
        return null; // Or a default/unknown drink
    }
  }

  Future<void> _addOrder() async {
    final customerName = _customerNameController.text.trim();
    final drinkTypeName = _drinkTypeController.text.trim();
    final specialInstructions = _specialInstructionsController.text.trim();

    if (customerName.isEmpty || drinkTypeName.isEmpty) {
      _showSnackBar(
        'Customer name and drink type cannot be empty.',
        Colors.red,
      );
      return;
    }

    final drink = _getDrinkInstance(drinkTypeName);
    if (drink == null) {
      _showSnackBar(
        'Invalid drink type. Please choose Shai, Turkish Coffee, or Hibiscus Tea.',
        Colors.red,
      );
      return;
    }

    final customer = Customer(customerName);
    await _orderManager.createOrder(customer, drink, specialInstructions);
    _customerNameController.clear();
    _drinkTypeController.clear();
    _specialInstructionsController.clear();
    _loadOrders();
    _showSnackBar('Order added successfully!', Colors.green);
  }

  Future<void> _markOrderCompleted(String orderId) async {
    await _orderManager.completeOrder(orderId);
    _loadOrders();
    _generateReports();
    _showSnackBar('Order marked as completed!', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Ahwa Manager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Add New Order Section ---
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Order',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _drinkTypeController,
                        decoration: const InputDecoration(
                          labelText:
                              'Drink Type (e.g., Shai, Turkish Coffee, Hibiscus Tea)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_cafe),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _specialInstructionsController,
                        decoration: const InputDecoration(
                          labelText:
                              'Special Instructions (e.g., "extra mint, ya rais")',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _addOrder,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add Order'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            50,
                          ), // Make button full width
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Pending Orders Section ---
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Orders',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _pendingOrders.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No pending orders.'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pendingOrders.length,
                              itemBuilder: (context, index) {
                                final order = _pendingOrders[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${order.customer.name} - ${order.drink.name}',
                                    ),
                                    subtitle: Text(
                                      'Instructions: ${order.specialInstructions.isNotEmpty ? order.specialInstructions : 'None'}\n'
                                      'Order Time: ${order.orderTime.toLocal().toString().split('.')[0]}',
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () =>
                                          _markOrderCompleted(order.id),
                                      child: const Text('Complete'),
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),

              // --- Reports Section ---
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text('Most Popular Drink'),
                        subtitle: Text(_mostPopularDrink),
                      ),
                      ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: const Text('Total Served Orders'),
                        subtitle: Text('$_totalServedOrders'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _generateReports,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Reports'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
