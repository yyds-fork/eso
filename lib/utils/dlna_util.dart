
import 'package:dlna/dlna.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 视频投屏
class DLNAUtil {

  DLNAUtil._();

  static DLNAUtil _instance;

  /// 视频投屏
  static DLNAUtil get instance => _getInstance();

  static _getInstance() {
    if (_instance == null) {
      _instance = DLNAUtil._();
      _instance.manager = DLNAManager();
      _instance.manager.enableCache();
      _instance.manager.setRefresher(DeviceRefresher(
          onDeviceAdd: (dev) {
            if (!_instance._devices.contains(dev)) {
              _instance._devices.add(dev);
              print('add ' + dev.toString());
              _instance._update();
            }
          },
          onDeviceRemove: (dev) {
            _instance._devices.remove(dev);
            print("remove $dev");
            _instance._update();
          },
          onDeviceUpdate: (dev) {
            print('update $dev');
          },
          onSearchError: (err) {
            print('error $err');
            _instance.isSearching = false;
            _instance._update();
          },
          onPlayProgress: (position) {
            print('播放进度: ' + _time2Str(DateTime.now().millisecondsSinceEpoch) + ' / ' + position.relTime);
          }
      ));
    }
    return _instance;
  }

  var _devices = <DLNADevice>[];
  DLNAManager manager;

  var isSearching = false;

  _update() {
    if (_state != null) _state(() => null);
  }

  StateSetter _state;

  DLNADevice curDevice;

  /// 释放
  static release() {
    if (_instance == null) return;
    _instance.manager.release();
    _instance.manager = null;
    _instance = null;
  }

  /// 开始投屏
  start(BuildContext context, {String title, @required String url, String videoType = VideoObject.VIDEO_MP4, VoidCallback onPlay}) async {
    if (url == null || url.isEmpty) return null;

    showDialog(context: context, builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: StatefulBuilder(builder: (context, StateSetter state) {
            _state = state;
            var children = <Widget>[];
            if (_devices.isEmpty)
              children.add(Text("没有可投屏的设备", style: TextStyle(color: Colors.grey)));
            else {
              _devices.forEach((e) {
                children.add(Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(e.deviceName),
                    selected: curDevice == e,
                    // subtitle: Text(e.description.toString()),
                    onTap: () async {
                      try {
                        await manager.actStop();
                      } catch (e) {}
                      try {
                        PlayMode playMode = PlayMode.NORMAL;
                        await manager.actSetPlayMode(playMode);
                        manager.setDevice(e);

                        var _type = videoType;
                        if (Utils.empty(_type)) {
                          if (url.indexOf('.mp4') > 1)
                            _type = VideoObject.VIDEO_MP4;
                          else if (url.indexOf('.m3u8') > 1)
                            _type = VideoObject.VIDEO_H264;
                          else if (url.indexOf('.avi') > 1)
                            _type = VideoObject.VIDEO_AVI;
                          if (Utils.empty(_type)) _type = VideoObject.VIDEO_MP4;
                        }

                        var video = VideoObject(title ?? "", url, _type);
                        video.refreshPosition = true;
                        await manager.actSetVideoUrl(video);
                        await manager.actPlay();

                        curDevice = e;
                        _update();

                      } catch (e) {
                        print(e);
                        return;
                      }
                      if (onPlay != null) onPlay();
                    },
                  ),
                ));
              });
            }

//            var _makeDevice = (String name) {
//              var item = DLNADevice();
//              item.description = DLNADescription();
//              item.description.friendlyName = name;
//              return item;
//            };

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DLNA 投屏", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 300),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ButtonTheme(
                  textTheme: ButtonTextTheme.accent,
                  minWidth: 50,
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FlatButton(child: Text(isSearching ? "停止搜索" : "搜索设备"), onPressed: () async {
                          if (!isSearching) {
                            if (_devices.isEmpty)
                              manager.startSearch();
                            else {
                              _devices.clear();
                              manager.forceSearch();
                            }
                            isSearching = true;
                            _update();
                          } else {
                            manager.stopSearch();
                            isSearching = false;
                            _update();
                          }
                        }),
                        Expanded(child: Container()),
                        IconButton(icon: Icon(Icons.pause, color: _devices.isEmpty ? Colors.grey : Theme.of(context).accentColor), onPressed: _devices.isEmpty ? null : () {
                          manager.actPause();
                        }),
                        IconButton(icon: Icon(Icons.stop, color: _devices.isEmpty ? Colors.grey : Theme.of(context).accentColor), onPressed: _devices.isEmpty ? null : () {
                          manager.actStop();
                        })
                      ],
                    ),
                  ),
                )
              ],
            );

          }),
        ),
      );
    });
  }

  static String _time2Str(int intTime) {
    var time = DateTime.fromMillisecondsSinceEpoch(intTime);
    return "${_formatInt(time.hour)}:${_formatInt(time.minute)}:${_formatInt(time.second)}";
  }

  static String _formatInt(int value) {
    return value.toString().padLeft(2, '0');
  }

}