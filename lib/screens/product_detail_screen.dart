import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {

    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProducts = Provider.of<Products>(context,listen: false).findById(productId);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProducts.title),
              background: Hero(
                  tag: loadedProducts.id,
                  child: Image.network(loadedProducts.imageUrl,
                  fit: BoxFit.cover,)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 10),
                Text('\$${loadedProducts.price}',
                  textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey,
                    fontSize: 20),),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(loadedProducts.description,
                      textAlign: TextAlign.center,
                  softWrap: true,),
                ),
                
              ]
            ),
          ),
        ],
      )
    );
  }
}
