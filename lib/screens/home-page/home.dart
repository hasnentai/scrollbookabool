import 'dart:async';
import 'dart:convert';

import 'package:bookabook/models/product.dart';
import 'package:bookabook/screens/home-page/categories-controller.dart';
import 'package:bookabook/screens/service/productService.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:bookabook/screens/service/category_service.dart';
import 'package:http/http.dart' as http;

CatController catController = CatController();

class Home extends StatefulWidget {
  final String email;
  final String displayName;
  Home(this.email, this.displayName);
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences prefs;
  String email;
  String displayName;
  final List<Category> _categories = <Category>[];
  List _products = [];
  List _masterData = [];
  List allCat = [];
  CatService catService;
  List<CatService> finalList = new List<CatService>();
  List<ProductService> productList = new List<ProductService>();
  List<List<ProductService>> finalProductList =
      new List<List<ProductService>>();
  List<int> index = new List<int>();

  bool isError = false;

  void initState() {
    email = widget.email;
    displayName = widget.displayName;
    // _fetchProducts();
    fetchCats();
    setState(() {
      this.getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<CatService>> getData() async {
    var res = await http.get(consts.url +
        "/wc/v3/products/categories?" +
        consts.ck +
        "&" +
        consts.cs);
    print(res.body);

    var data = json.decode(res.body);
    var list = data as List;
    print(list);
    List<CatService> finalListinner =
        list.map<CatService>((json) => CatService.fromJson(json)).toList();

        for(int i =0;i<finalListinner.length;i++){
          if(finalListinner[i].count!=0){
            finalList.add(finalListinner[i]);
          }
        }

    for (int i = 0; i < finalList.length; i++) {
      productList = new List<ProductService>();
      var res = await http.get(consts.url +
          "/wc/v3/products?category=" +
          finalList[i].catId.toString() +
          "&" +
          consts.ck +
          "&" +
          consts.cs);

      var data = json.decode(res.body);
      var list = data as List;
      productList = list
          .map<ProductService>((json) => ProductService.fromJson(json))
          .toList();
      setState(() {
        index.add(productList.length);
        finalProductList.add(productList);
      });
    }
    
    return finalList;
  }

  Future<void> fetchCats() async {
    final List<Category> categories = await catController.fetchCats();
    if (categories != null) {
      setState(() => _categories.addAll(categories));
    } else {
      setState(() => isError = true);
    }
  }

  // Future<void> _fetchProducts() async {
  //   List products = await catController.fetchProducts();
  //   setState(() => _products = products);
  //   print(_products);
  //   await uniqueList(_products);
  // }

  uniqueList(List list) async {
    print('called');
    final List unique = [];
    for (var i = 0; i < list.length; i++) {
      if (!unique.contains(list[i]['categories'][0]['name'])) {
        unique.add(list[i]['categories'][0]['name']);
      }
      // print(list[i]['categories'][0]['name']);
    }

    // setState(() {
    //   if (_categories == null) {
    //     _categories = unique;
    //   } else {
    //     _categories.addAll(unique);
    //   }
    // });
    finalComp();
  }

  finalComp() async {
    List masterData = [];
    final List temp = [];
    for (int i = 0; i < _categories.length; i++) {
      for (int j = 0; j < _products.length; j++) {
        if (_categories[i] == _products[j]['categories'][0]['name']) {
          temp.add(_products[j]);
        }

        // print(temp);
      }

      Map jsonMap = {_categories[i]: temp};
      // print(jsonMap);
      masterData.add(jsonMap);
      // print(masterData);
      // temp.clear();
    }

    setState(() {
      if (_masterData.isEmpty) {
        _masterData = masterData;
      } else {
        _masterData.addAll(masterData);
      }
    });
  }

  Widget navBarBuilder(BuildContext context) {
    return ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
            accountName: displayName != null ? Text(displayName) : Text(""),
            accountEmail: email != null ? Text(email) : Text(""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.orange
                  : Colors.white,
              child: Text(
                displayName.split('')[0].toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            )),
        Column(
          children: _categories.map<Widget>((item) {
            return ListTile(
              title: Text(item.name),
            );
          }).toList(),
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () async {
            prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Navigator.pushReplacementNamed(context, "/myhome");
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFF900F),
          statusBarIconBrightness: Brightness.light),
    );
    return new Scaffold(
      key: _scaffoldKey,
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Color(0xFFFF900F),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Color(0xFFFF900F),
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.red,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.white30))),
        child: new BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.white,
          items: [
            new BottomNavigationBarItem(
                title: new Text(''), icon: new Icon(Icons.home)),
            new BottomNavigationBarItem(
                title: new Text(''), icon: new Icon(Icons.notifications)),
            new BottomNavigationBarItem(
                title: new Text(''), icon: new Icon(Icons.search)),
            new BottomNavigationBarItem(
                title: new Text(''), icon: new Icon(Icons.person))
          ],
        ),
      ),
      appBar: new AppBar(
        title: new Text(
          'Home',
          style: new TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF900F),
        leading: GestureDetector(
          child: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onTap: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
        centerTitle: false,
      ),
      drawer: Drawer(child: navBarBuilder(context)),
      body: 
      finalProductList != null
          ? listBuilder(context, finalList, finalProductList)
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget listBuilder(BuildContext context, List<CatService> categories,
      List<List<ProductService>> products) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categories.length,
        itemBuilder: (context, i) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(categories[i].catName),
                  ),
                  Text("See All"),
                ],
              ),
              SingleChildScrollView(
                
                scrollDirection: Axis.horizontal,
                child: new Container(
                  height: 200.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: new EdgeInsets.all(8.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: index[i],
                    itemBuilder: (context, j) {
                      return index != null?Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Container(
                              height: 200.0,
                              width: 200.0,
                              color: Colors.blue,
                              child: Text(finalProductList[i][j].name),
                            ),
                          ),
                        ],
                      ):new CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget homeBodybuilder(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[listBuilder(context, finalList, finalProductList)],
      ),
    );
  }

  Widget _buildCarousel(context, index, List<Product> data) {
    // var cat = _categories[index];
    // print(_masterData[index][cat].length);
    // List data = _masterData[index][cat];
    String imgUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJftYqJsvhphX6OOjKMjbwllPKR70rAjXcpsP3tQ8XM7-tqRm4';
    return CarouselSlider(
        height: 250,
        items: data.map((item) {
          // if (item['images'].isNotEmpty) {
          //   imgUrl = item['images'][0]['src'];
          // }
          return Card(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: FadeInImage(
                    height: 150,
                    width: 200,
                    image: item.images.isEmpty
                        ? CachedNetworkImageProvider(imgUrl)
                        : CachedNetworkImageProvider(item.images[0]['src']),
                    // fit: BoxFit.cover,
                    placeholder: AssetImage('res/placeholder.jpg'),
                  ),
                ),
                ListTile(
                  title: Text(
                    item.name,
                    softWrap: true,
                  ),
                )
              ],
            ),
          );
        }).toList());
  }
}
