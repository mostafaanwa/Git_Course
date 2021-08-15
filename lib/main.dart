import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/cart.dart';
import './providers/orders.dart';
import './providers/products.dart';
import './providers/auth.dart';
import './screens/edit_product_screen.dart';
import './screens/cart_screen.dart';
import './screens/user_products_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/splash_screen.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (_) => Orders(),
              update: (ctx, authValue, previousOrders) =>
              previousOrders..getData(
                  authValue.token,
                  authValue.userId,
                  previousOrders == null? null: previousOrders.orders)),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (_) => Products(),
              update: (ctx, authValue, previousProducts) =>
              previousProducts..getData(
                  authValue.token,
                  authValue.userId,
                  previousProducts == null? null: previousProducts.items)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx,authSnapshot) =>
                    authSnapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
              CartScreen.routeName: (_) => CartScreen(),
              OrdersScreen.routeName: (_) => OrdersScreen(),
              UserProductScreen.routeName: (_) => UserProductScreen(),
              EditProductScreen.routeName: (_) => EditProductScreen(),
            },
          ),
        ));
  }
}
