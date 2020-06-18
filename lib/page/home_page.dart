import 'dart:async';

import 'package:eso/evnts/audio_state_event.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/page/audio_page.dart';
import 'package:eso/page/search_page.dart';
import 'package:eso/ui/widgets/animation_rotate_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../model/page_switch.dart';
import '../model/profile.dart';
import '../utils.dart';
import 'discover_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription stream;
  bool lastAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    lastAudioPlaying = AudioService.isPlaying;
    stream = eventBus.on<AudioStateEvent>().listen((event) {
      if (lastAudioPlaying != AudioService.isPlaying) {
        lastAudioPlaying = AudioService.isPlaying;
        if (this.mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PageSwitch(Global.currentHomePage),
      child: Consumer<PageSwitch>(
        builder: (BuildContext context, PageSwitch pageSwitch, Widget widget) {
          Global.currentHomePage = pageSwitch.currentIndex;
          final _pageView = PageView(
            controller: pageSwitch.pageController,
            children: <Widget>[
              FavoritePage(),
              DiscoverPage(),
            ],
            onPageChanged: (index) => pageSwitch.changePage(index, false),
            physics: new NeverScrollableScrollPhysics(), //禁止主页左右滑动
          );
          return Scaffold(
            body: AudioService.isPlaying ? Stack(
              children: [
                _pageView,
                _buildAudioView(context),
              ],
            ): _pageView,
            bottomNavigationBar: Consumer<Profile>(
              builder: (BuildContext context, Profile profile, Widget widget) {
                //bool isDark = Theme.of(context).brightness == Brightness.dark;
                return BottomAppBar(
                  color: Theme.of(context).canvasColor,
                  shape: CircularNotchedRectangle(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: () => pageSwitch.changePage(0),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.library_books,
                                  color: getColor(pageSwitch, context, 0),
                                ),
                                Text(
                                  "收藏",
                                  style:
                                  TextStyle(color: getColor(pageSwitch, context, 0)),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () => pageSwitch.changePage(1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.satellite,
                                    color: getColor(pageSwitch, context, 1)),
                                Text("发现",
                                    style: TextStyle(
                                        color: getColor(pageSwitch, context, 1)))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context)
                  .push(
                  MaterialPageRoute(builder: (BuildContext context) => SearchPage()))
                  .whenComplete(() => pageSwitch.refreshList()),
              child: Icon(Icons.search, color: Theme.of(context).canvasColor),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }
  
  Widget _buildAudioView(BuildContext context) {
    final chapter = AudioService().curChapter;
    final Widget _view = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Theme.of(context).primaryColorLight.withOpacity(0.8), width: 0.5)
      ),
      child: AnimationRotateView(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: Utils.empty(chapter?.cover) ? null : DecorationImage(
              image: NetworkImage(chapter.cover ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          child: Utils.empty(chapter?.cover) ? Icon(Icons.audiotrack, color: Colors.black12, size: 24) : Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColorLight.withOpacity(0.8), width: 0.35)
            ),
          ),
        ),
      ),
    );
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: InkWell(
        child: chapter != null ? Tooltip(
          child: _view,
          message: '正在播放: ' + chapter.name ?? '',
        ): _view,
        onTap: chapter == null ? null : () {
          Utils.startPageWait(context, AudioPage(searchItem: AudioService().searchItem));
        },
      ),
    );
  }

  Color getColor(PageSwitch pageSwitch, BuildContext context, int value) {
    return pageSwitch.currentIndex == value
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyText1.color;
  }
}

