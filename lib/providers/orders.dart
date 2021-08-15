import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;

  getData(String token, String uid, List<OrderItem> ordersI) {
    authToken = token;
    userId = uid;
    _orders = ordersI;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-5d1a4-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';

    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        print ("no orders");
        return;
      }

      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
              id: orderId,
              amount: orderData["amount"],
              products: (orderData["products"]).map<CartItem>((item) =>
                  CartItem(
                      id: item["id"],
                      title: item["title"],
                      quantity: item["quantity"],
                      price: item["price"])).toList(),
              dateTime: DateTime.parse(orderData["dateTime"])),
        );
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      print (e);
    }
  }

  Future <void> addOrder (List<CartItem> cartProducts, double total) async {

    final url = 'https://shop-5d1a4-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {

      final res = await http.post( url,body: json.encode({
        "amount": total,
        "dateTime": timeStamp.toIso8601String(),
        "products": cartProducts.map((cartIt) => {
          "id": cartIt.id,
          "title": cartIt.title,
          "quantity": cartIt.quantity,
          "price": cartIt.price,
        }).toList(),
      }));
      _orders.insert(0, OrderItem(
          id: json.decode(res.body)["name"],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp));
      notifyListeners();
    } catch (e){
      print(e);
    }
  }

}
