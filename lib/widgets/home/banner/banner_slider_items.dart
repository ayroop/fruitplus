import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../../widgets/home/banner/banner_items.dart';
import '../../../widgets/home/header/header_text.dart';
import '../../../common/tools.dart';
import 'package:page_indicator/page_indicator.dart';

/// The Banner Group type to display the image as multi columns
class BannerSliderItems extends StatefulWidget {
  final config;

  BannerSliderItems({this.config});

  @override
  _StateBannerSlider createState() => _StateBannerSlider();
}

class _StateBannerSlider extends State<BannerSliderItems> {
  int position = 0;
  PageController _controller = PageController();

  void initState() {
    super.initState();
    bool autoPlay = widget.config['autoPlay'] ?? false;
    if (autoPlay) {
      Future.delayed(Duration(seconds: 3), () {
        autoPlayBanner();
      });
    }
  }

  void autoPlayBanner() {
    List items = widget.config['items'];
    int intervalTime = widget.config['intervalTime'] ?? 3;
    Timer.periodic(Duration(seconds: intervalTime), (callback) {
      if (position >= items.length - 1) {
        _controller.jumpToPage(0);
      } else {
        if (position != null) {
          _controller.animateToPage(position + 1,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        }
      }
    });
  }

  Widget getBannerPageView(width) {
    List items = widget.config['items'];
    bool showNumber = widget.config['showNumber'] ?? false;

    return Padding(
      child: Stack(
        children: <Widget>[
          PageIndicatorContainer(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                this.setState(() {
                  position = index;
                });
              },
              children: <Widget>[
                for (int i = 0; i < items.length; i++)
                  BannerImageItem(
                    config: items[i],
                    width: width,
                    boxFit: BoxFit.cover,
                    padding:
                        Tools.formatDouble(widget.config['padding'] ?? 0.0),
                    radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
                  ),
              ],
            ),
            align: IndicatorAlign.bottom,
            length: items.length,
            indicatorSpace: 5.0,
            padding: const EdgeInsets.all(10.0),
            indicatorColor: Colors.black12,
            indicatorSelectorColor: Colors.black87,
            shape: IndicatorShape.roundRectangleShape(
              size: showNumber ? Size(0.0, 0.0) : Size(25.0, 2.0),
            ),
          ),
          showNumber
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        child: Text(
                          "${position + 1}/${items.length}",
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 5),
    );
  }

  Widget renderBanner(width) {
    List items = widget.config['items'];
    switch (widget.config['design']) {
      case 'swiper':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          viewportFraction: 0.85,
          scale: 0.9,
        );
      case 'tinder':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width,
          itemHeight: width * 1.2,
          layout: SwiperLayout.TINDER,
        );
      case 'stack':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width - 40,
          layout: SwiperLayout.STACK,
        );
      case 'custom':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width - 40,
          itemHeight: width + 100,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
              .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate(
            [Offset(-370.0, -40.0), Offset(0.0, 0.0), Offset(370.0, -40.0)],
          ),
        );
      default:
        return getBannerPageView(width);
    }
  }

  double bannerPercent(width) {
    final screenSize = MediaQuery.of(context).size;
    return Tools.formatDouble(
        widget.config['height'] ?? 0.5 / (screenSize.height / width));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    bool isBlur = widget.config['isBlur'] == true;

    List items = widget.config['items'];
    double bannerExtraHeight =
        screenSize.height * (widget.config['title'] != null ? 0.12 : 0.0);
    double upHeight = Tools.formatDouble(widget.config['upHeight'] ?? 0.0);

    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          double _bannerPercent = bannerPercent(constraint.maxWidth);
          return FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              height: screenSize.height * _bannerPercent +
                  bannerExtraHeight +
                  upHeight,
              child: Stack(
                children: <Widget>[
                  if (widget.config['showBackground'] == true)
                    Container(
                      height: screenSize.height * _bannerPercent +
                          bannerExtraHeight +
                          upHeight,
                      child: Padding(
                        child: ClipRRect(
                          child: Stack(children: <Widget>[
                            isBlur
                                ? Transform.scale(
                                    child: Image.network(
                                      items[position]['background'] != null
                                          ? items[position]['background']
                                          : items[position]['image'],
                                      fit: BoxFit.fill,
                                      width: screenSize.width + upHeight,
                                    ),
                                    scale: 3,
                                  )
                                : Image.network(
                                    items[position]['background'] != null
                                        ? items[position]['background']
                                        : items[position]['image'],
                                    fit: BoxFit.fill,
                                    width: constraint.maxWidth,
                                    height: screenSize.height * _bannerPercent +
                                        bannerExtraHeight +
                                        upHeight,
                                  ),
                            ClipRect(
                              child: BackdropFilter(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(isBlur ? 0.6 : 0.0),
                                  ),
                                ),
                                filter: ImageFilter.blur(
                                    sigmaX: isBlur ? 12 : 0,
                                    sigmaY: isBlur ? 12 : 0),
                              ),
                            ),
                          ]),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(100, 6),
                          ),
                        ),
                        padding: const EdgeInsets.only(bottom: 50),
                      ),
                    ),
                  if (widget.config['title'] != null)
                    HeaderText(
                      config: widget.config,
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: screenSize.height * _bannerPercent,
                      child: renderBanner(constraint.maxWidth),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
