import 'package:blind_english/medias_app.dart';
import 'package:flutter/material.dart';
import 'package:blind_english/pages/player/part_player_service.dart';
import 'package:blind_english/widgets/part_login.dart';
import 'package:blind_english/pages/player/part_player.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProxyAnimation transitionAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: LoginStateWidget(Scaffold(
        // key: _scaffoldKey,
        // drawer: Drawer(
        //   child: Column(
        //     children: <Widget>[
        //       MyDrawerHeader(),
        //       MediaQuery.removePadding(
        //           context: context,
        //           removeTop: true,
        //           child: Expanded(
        //             child: ListView(
        //               children: <Widget>[
        //                 ListTile(
        //                   leading: Icon(Icons.settings,
        //                       color: Theme.of(context).iconTheme.color),
        //                   title: Text(
        //                     "设置",
        //                   ),
        //                   onTap: () {
        //                     //TODO to setting
        //                   },
        //                 ),
        //                 Divider(
        //                   height: 0.5,
        //                   indent: 64,
        //                 )
        //               ],
        //             ),
        //           ))
        //     ],
        //   ),
        // ),
        appBar: AppBar(
          // leading: IconButton(
          //     icon: AnimatedIcon(
          //         icon: AnimatedIcons.menu_arrow,
          //         color: Theme.of(context).primaryIconTheme.color,
          //         progress: transitionAnimation),
          //     onPressed: () {
          //       // _scaffoldKey.currentState.openDrawer();
          //     }),
          title: Container(
            height: kToolbarHeight,
            width: 128,
            child: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                    child: Text("世界新闻")),
//                Tab(
//                    child: Icon(Icons.cloud,
//                        color: Theme.of(context).primaryIconTheme.color)),
              ],
            ),
          ),
          titleSpacing: 0,
          // centerTitle: true,
          actions: <Widget>[
            // IconButton(
            //   onPressed: () {
            //     // Navigator.push(
            //     //     context, NeteaseSearchPageRoute(transitionAnimation));
            //   },
            //   icon: Icon(Icons.search),
            // )
          ],
        ),
        body: BoxWithBottomPlayerController(TabBarView(
          controller: _tabController,
          children: <Widget>[new MediaApp()],
        )),
      )),
    );
  }
}

class MyDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget name;
    ImageProvider avatar;
    List<Widget> otherAccountsPictures;
    if (LoginState.of(context).isLogin) {
      Map profile = LoginState.of(context).user["profile"];
      name = Text(profile["nickname"]);
      // avatar = NeteaseImage(profile["avatarUrl"]);
      otherAccountsPictures = [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip: "退出登陆",
            onPressed: () {
              // neteaseRepository.logout();
            },
          ),
        )
      ];
    } else {
      name = const Text("未登录");
    }

    void _onAvatarClick() {
      if (!LoginState.of(context).isLogin) {
        // Navigator.of(context).pushNamed(ROUTE_LOGIN);
      } else {
        debugPrint("work in process...");
      }
    }

    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: _onAvatarClick,
        child: CircleAvatar(
          backgroundImage: avatar,
        ),
      ),
      accountName: name,
      accountEmail: null,
      otherAccountsPictures: otherAccountsPictures,
    );
  }
}
