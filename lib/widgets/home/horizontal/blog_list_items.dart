import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../models/blog.dart';
import '../../../screens/blogs.dart';
import '../../../widgets/blog/blog_view.dart';
import '../../../widgets/home/header/header_view.dart';

class BlogListItems extends StatefulWidget {
  final config;

  BlogListItems({this.config});

  @override
  _BlogListItemsState createState() => _BlogListItemsState();
}

class _BlogListItemsState extends State<BlogListItems> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    getBlogs();
  }

  Future<List<Blog>> getBlogs() async {
    List<Blog> blogs = [];
    var _jsons = await Blog.getBlogs(
        url: serverConfig['blog'] ?? serverConfig['url'], page: 1);
    for (var item in _jsons) {
      blogs.add(Blog.fromJson(item));
    }
    Provider.of<BlogModel>(context, listen: false).addBlogs(blogs);
    return blogs;
  }

  Widget _buildHeader(context, blogs) {
    if (widget.config.containsKey("name")) {
      var showSeeAllLink = widget.config['layout'] != "instagram";
      return HeaderView(
        headerText: widget.config["name"] ?? '',
        showSeeAll: showSeeAllLink,
        callback: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: kLayoutWeb,
              builder: (context) => BlogScreen(),
            ),
          )
        },
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var emptyPosts = [Blog.empty(1), Blog.empty(2), Blog.empty(3)];
    var blogs = Provider.of<BlogModel>(context).blogs;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (blogs.isEmpty) {
          return Column(
            children: <Widget>[
              _buildHeader(context, null),
              BlogItemView(posts: emptyPosts, index: 0),
              BlogItemView(posts: emptyPosts, index: 1),
              BlogItemView(posts: emptyPosts, index: 2),
            ],
          );
        }
        return Column(
          children: <Widget>[
            _buildHeader(context, blogs),
            Container(
              width: constraints.maxWidth,
              height: constraints.maxWidth * (kLayoutWeb ? 0.4 : 0.6),
              color: Theme.of(context).cardColor.withOpacity(0.85),
              padding: const EdgeInsets.only(top: 8.0),
              child: PageView(
                children: [
                  for (var i = 0; i < blogs.length; i = i + 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        blogs[i] != null
                            ? Expanded(
                                child: BlogItemView(posts: blogs, index: i),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                        i + 1 < blogs.length
                            ? Expanded(
                                child: BlogItemView(posts: blogs, index: i + 1),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                        i + 2 < blogs.length
                            ? Expanded(
                                child: BlogItemView(posts: blogs, index: i + 2),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                      ],
                    )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
