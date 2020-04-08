import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../widgets/home/search/custom_search.dart';
import 'search/custom_search_page.dart' as search;

class Logo extends StatelessWidget {
  final config;

  Logo({this.config});

  Widget renderLogo() {
    if (config['image'] != null) {
      if (config['image'].indexOf('http') != -1) {
        return Image.network(
          config['image'],
          height: 40,
        );
      }
      return Image.asset(
        config['image'],
        height: 40,
      );
    }
    return Image.asset(kLogoImage, height: 40);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          // constraints: BoxConstraints(minHeight: 100),
          child: Stack(
            children: <Widget>[
              (config['showSearch'] ?? false)
                  ? Positioned(
                      // top: 55,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).accentColor.withOpacity(0.6),
                          size: 22,
                        ),
                        onPressed: () {
                          search.showSearch(
                              context: context, delegate: CustomSearch());
                        },
                      ),
                    )
                  : Container(),
              Positioned(
                // top: 55,
                left: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.blur_on,
                    color: Theme.of(context).accentColor.withOpacity(0.9),
                    size: 22,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              if (!(config['hideLogo'] ?? false))
                Center(
                  child: Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        renderLogo(),
                        SizedBox(
                          width: 5,
                        ),
                        if (config['name'] != null)
                          Text(
                            config['name'],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                      ],
                    ),
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      // top: 60.0
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
