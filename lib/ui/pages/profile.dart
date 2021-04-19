import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../graphql/graphql_api.dart';
import '../../models/e_oauth2_client.dart';
import '../widgets/profile/anime_stats.dart';
import '../widgets/profile/manga_stats.dart';

class Profile extends StatefulWidget {
  final EigaOAuth2Client client;

  const Profile({required this.client});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Query(
        options: QueryOptions(
            document: UserInfoQuery().document,
            fetchPolicy: FetchPolicy.cacheFirst),
        builder: (
          QueryResult result, {
          Future<QueryResult?> Function()? refetch,
          FetchMore? fetchMore,
        }) {
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          if (result.data == null && result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final UserInfo$Query$User user =
              UserInfo$Query.fromJson(result.data!).viewer!;

          return RefreshIndicator(
            onRefresh: () => refetch!(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 10),
                    title: Stack(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            user.name,
                            style: TextStyle(fontFamily: "Rubik"),
                          ),
                        ),
                        Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1!
                                        .color!,
                                    width: 5),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                imageUrl: user.avatar!.medium!,
                                fit: BoxFit.cover,
                              ),
                            ))
                      ],
                    ),
                    background: user.bannerImage != null
                        ? CachedNetworkImage(
                            imageUrl: user.bannerImage!, fit: BoxFit.cover)
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.blue,
                                  Colors.purple,
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BubbleTabIndicator(
                            indicatorHeight: 30,
                            indicatorColor: Theme.of(context).accentColor,
                            tabBarIndicatorSize: TabBarIndicatorSize.tab,
                            indicatorRadius: 5),
                        tabs: [makeTab("Anime"), makeTab("Manga")],
                      ),
                      Container(
                        constraints:
                            BoxConstraints(minHeight: 300, maxHeight: 900),
                        child: TabBarView(
                            controller: _tabController,
                            children: [
                              AnimeStats(user: user),
                              MangaStats(user: user)
                            ]),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void logout(BuildContext context) {
    widget.client.deleteToken();
    Future.delayed(
        Duration.zero, () => Navigator.popAndPushNamed(context, '_app'));
  }

  @override
  bool get wantKeepAlive => true;

  Widget makeTab(String text) {
    return Tab(
      child: Text(
        text,
        style: TextStyle(fontFamily: "Rubik"),
      ),
    );
  }
}
