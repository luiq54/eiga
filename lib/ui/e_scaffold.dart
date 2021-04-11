import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/e_graphql_client.dart';
import '../models/e_oauth2_client.dart';
import 'pages/discover.dart';
import 'pages/profile.dart';

class EigaScaffold extends StatefulWidget {
  final EigaGraphQLClient gqlClient;
  final EigaOAuth2Client oauth2Client;

  const EigaScaffold(
      {Key key, @required this.gqlClient, @required this.oauth2Client})
      : super(key: key);

  @override
  _EigaScaffoldState createState() => _EigaScaffoldState();
}

class _EigaScaffoldState extends State<EigaScaffold> {
  int _selectedIndex = 0;
  final _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: widget.gqlClient.client,
      child: CacheProvider(
        child: MaterialApp(
          theme: ThemeData(fontFamily: "Inter"),
          darkTheme: ThemeData(
            fontFamily: "Inter",
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            accentColor: Colors.blue,
            canvasColor: Colors.black,
            dividerColor: Colors.white38,
            appBarTheme: AppBarTheme(color: Colors.black),
          ),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          home: AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.black),
            child: Scaffold(
              body: SafeArea(
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageViewController,
                  children: [
                    Column(
                      children: [
                        Center(child: Text("Profile")),
                        Center(child: Profile(
                          logout: () {
                            widget.oauth2Client.deleteToken();
                            Future.delayed(
                                Duration.zero,
                                () =>
                                    Navigator.popAndPushNamed(context, '_app'));
                          },
                        ))
                      ],
                    ),
                    Center(child: Text("Library")),
                    DiscoverPage()
                  ],
                ),
              ),
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      activeIcon: Icon(Icons.account_circle),
                      label: ""),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.collections_bookmark_outlined),
                      activeIcon: Icon(Icons.collections_bookmark),
                      label: ""),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.explore_outlined),
                      activeIcon: Icon(Icons.explore),
                      label: "")
                ],
                currentIndex: _selectedIndex,
                onTap: _onBottomNavTapped,
                showSelectedLabels: false,
                showUnselectedLabels: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _pageViewController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
      _selectedIndex = index;
    });
  }
}
