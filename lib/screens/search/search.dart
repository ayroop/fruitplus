import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/search.dart';
import 'product_list.dart';
import 'recent_search.dart';

class SearchScreen extends StatefulWidget {
  final isModal;

  SearchScreen({Key key, this.isModal}) : super(key:key);

  @override
  _StateSearchScreen createState() => _StateSearchScreen();
}

class _StateSearchScreen extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;

  bool isVisibleSearch = false;
  String searchText;
  var textController = TextEditingController();
  Timer _timer;
  FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      isVisibleSearch = _focus.hasFocus;
    });
  }

  Widget _renderSearchLayout() {
    final screenSize = MediaQuery.of(context).size;

    return ListenableProvider.value(
      value: Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (searchText == null || searchText.isEmpty) {
          return Padding(
            child: RecentSearches(
              onTap: (text) {
                setState(() {
                  searchText = text;
                });
                textController.text = text;
                FocusScope.of(context).requestFocus(FocusNode()); //dismiss keyboard
                Provider.of<SearchModel>(context, listen: false).searchProducts(name: text, page: 1);
              },
            ),
            padding: const EdgeInsets.only(left: 10, right: 10),
          );
        }

        if (model.loading) {
          return kLoadingWidget(context);
        }

        return Column(
          children: <Widget>[
            Container(
              width: screenSize.width,
              child: Container(
                width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                height: 45,
                decoration: BoxDecoration(color: HexColor("#F9F9F9")),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [
                  Text(
                    S.of(context).weFoundProducts(model.products.length.toString()),
                  )
                ]),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: ProductList(name: searchText, products: model.products),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: widget.isModal != null
          ? AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 22,
                ),
              ),
              title: Container(
                width: screenSize.width,
                child: Container(
                  width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                  child: Text(
                    S.of(context).search,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: InkWell(
          onTap: () => Utils.hideKeyboard(context),
          child: Column(
            children: <Widget>[
              Container(
                width: screenSize.width,
                child: Container(
                  width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                  child: widget.isModal == null
                      ? AnimatedContainer(
                          height: isVisibleSearch ? 0.1 : 40,
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(S.of(context).search,
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

                            ],
                          ),
                          duration: Duration(milliseconds: 250),
                        )
                      : SizedBox(
                          height: 10.0,
                        ),
                ),
              ),
              Container(
                width: screenSize.width,
                child: Container(
                  width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.search,
                              color: Colors.black45,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: textController,
                                focusNode: _focus,
                                onChanged: (text) {
                                  if (_timer != null) {
                                    _timer.cancel();
                                  }
                                  _timer = Timer(Duration(milliseconds: 500), () {
                                    setState(() {
                                      searchText = text;
                                    });
                                    Provider.of<SearchModel>(context, listen: false)
                                        .searchProducts(name: text, page: 1);
                                  });
                                },
                                decoration: InputDecoration(
                                  fillColor: Theme.of(context).accentColor,
                                  border: InputBorder.none,
                                  hintText: S.of(context).searchForItems,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              width: (searchText == null || searchText.isEmpty) ? 0 : 50,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    searchText = "";
                                    isVisibleSearch = false;
                                  });
                                  textController.text = "";
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                                child: Center(
                                  child:
                                      Text(S.of(context).cancel, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              duration: Duration(milliseconds: 200),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Expanded(child: _renderSearchLayout()),
            ],
          ),
        ),
      ),
    );
  }
}
