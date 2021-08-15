import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  var _editProduct = Product(id: null,
      title: "",
      description: "",
      price: 0,
      imageUrl: "");

  var _initialValue = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": ""

  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState(){
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    if(_isInit){
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null){
        _editProduct = Provider.of<Products>(context,listen: false).findById(productId);
        _initialValue = {
          "title": _editProduct.title,
          "description": _editProduct.description,
          "price": _editProduct.price.toString(),
          "imageUrl": ""
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _descriptionFocusNode.dispose();
  }
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus){
      if ((!_imageUrlController.text.startsWith("http") &&
          !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".png") &&
          !_imageUrlController.text.endsWith(".jpg") &&
          !_imageUrlController.text.endsWith(".jpeg"))){
  return;
    }
    setState(() {

    });
    }
  }

  Future<void> _saveForm () async {
    final isValid = _formKey.currentState.validate();
    if (!isValid){return;}
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null){
      await Provider.of<Products>(context,listen: false).updateProduct(_editProduct.id, _editProduct);
    } else {
      try{
        await Provider.of<Products>(context,listen: false).addProduct(_editProduct);
      } catch (e){
        await showDialog(context: context, builder: (ctx)=> AlertDialog(
          title: Text("An error occurred!"),
          content: Text("Something went wrong."),
          actions: [
            FlatButton(onPressed: ()=> Navigator.of(ctx).pop(),
                child: Text("Okay"))
          ],
        ));

      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("EditProductScreen"),
        actions: [
          IconButton(onPressed: _saveForm, icon: Icon(Icons.save)),

        ],
      ),
      body: _isLoading? Center(
        child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initialValue["title"],
                decoration: InputDecoration(labelText: "Title"),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value){
                  if (value.isEmpty){
                    return "Please provide a value";
                  } return null;
                },
                onSaved: (value){
                  _editProduct = Product(
                      id: _editProduct.id,
                      title: value,
                      description: _editProduct.description,
                      price: _editProduct.price,
                      imageUrl: _editProduct.imageUrl,
                  isFavorite: _editProduct.isFavorite);
                },
              ),

              TextFormField(
                initialValue: _initialValue["price"],
                decoration: InputDecoration(labelText: "Price"),
                textInputAction: TextInputAction.next,
                focusNode: _priceFocusNode,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value){
                  if (value.isEmpty){
                    return "Please enter a price.";
                  }
                  else if (double.tryParse(value) == null){
                    return "Please enter a valid number.";

                  }
                  else if (double.parse(value) <= 0){
                    return "Please enter a number greater than zero.";

                  }
                  return null;
                },
                onSaved: (value){
                  _editProduct = Product(
                      id: _editProduct.id,
                      title: _editProduct.title,
                      description: _editProduct.description,
                      price: double.parse(value),
                      imageUrl: _editProduct.imageUrl,
                      isFavorite: _editProduct.isFavorite);
                },
              ),

              TextFormField(
                initialValue: _initialValue["description"],
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value){
                  if (value.isEmpty){
                    return "Please enter a description.";
                  }
                  else if (value.length < 10){
                    return "Should be at least 10 characters long.";
                  }
                  return null;
                },
                onSaved: (value){
                  _editProduct = Product(
                      id: _editProduct.id,
                      title: _editProduct.title,
                      description: value,
                      price: _editProduct.price,
                      imageUrl: _editProduct.imageUrl,
                      isFavorite: _editProduct.isFavorite);
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8,right: 10),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty? Text("Enter a url") :
                    FittedBox(
                      child: Image.network(_imageUrlController.text,
                      fit: BoxFit.cover),
                    ),
                  ),
                  
                  Expanded(child: TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: "Image URL"),
                    keyboardType: TextInputType.url,
                    focusNode: _imageUrlFocusNode,
                    validator: (value){
                      if (value.isEmpty){
                        return "Please enter an image URL.";
                      }
                      else if (!value.startsWith("http") && !value.startsWith("https")){
                        return "Please enter a valid URL.";
                      }
                      else if (!value.endsWith(".png") && !value.endsWith(".jpg")
                          && !value.endsWith(".jpeg")){
                        return "Please enter a valid URL.";
                      }
                      return null;
                    },
                    onSaved: (value){
                      _editProduct = Product(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: _editProduct.description,
                          price: _editProduct.price,
                          imageUrl: value,

                          isFavorite: _editProduct.isFavorite);
                    },
                  ),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


}
