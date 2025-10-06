import 'package:smart_ahwa_manager_app/core/interfaces/i_drink.dart';

abstract class DrinkBase implements IDrink {
  @override
  final String name;
  @override
  final double price;

  DrinkBase(this.name, this.price);
}
