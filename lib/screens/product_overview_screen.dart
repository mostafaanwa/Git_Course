import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import './cart_screen.dart';

enum FilterOption { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    try {
      Provider.of<Products>(context, listen: false).fetchAndSetProducts();
      Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    } catch (e) {
      setState(() => _isLoading = false);
      print (e);
    } finally{
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectedVal) {
              setState(() {
                if (selectedVal == FilterOption.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text("Show all"),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Cart>(
              child: IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
                icon: Icon(Icons.shopping_cart),
              ),
              builder: (_, cart, ch) =>
                  Badge(child: ch, value: cart.itemCount.toString())),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
