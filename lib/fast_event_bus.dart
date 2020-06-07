import 'dart:async';

typedef EventListen = void Function(dynamic message);

void eventSend(String key, {data}) {
  EventBus.getDefault().post(key, data ?? "");
}

class _EventData {
  String key;
  dynamic data;

  _EventData(this.key, this.data);

  @override
  String toString() {
    return "key : $key --- data : $data";
  }
}

class EventBus {
  static EventBus _instance;
//  StreamController _streamController;
  Map<String, StreamSubscription> _streamState;
  Map<String, EventListen> _streamListen;
  Map<String, StreamController<_EventData>> _controller;
  factory EventBus.getDefault() {
    return _instance ??= EventBus._init();
  }

  ///初始化
  EventBus._init() {
//    _streamController = StreamController.broadcast();
    _streamState = {};
    _streamListen = {};
    _controller = {};
  }

  bool register(String key, EventListen listen, {bool replace = true}) {
    ///需要返回订阅者，所以不能使用下面这种形式
    ///没有指定类型，全类型注册
    if (!replace) {
      if (_streamState.containsKey(key)) {
        return false;
      }
    } else {
      _streamListen[key] = listen;

      if (!_streamState.containsKey(key)) {
        _controller[key] = StreamController<_EventData>.broadcast();
        Stream<_EventData> stream = _controller[key]
            .stream
            .where((type) => type is _EventData)
            .cast<_EventData>();
        _streamState[key] = stream.listen(_listenCallback);
      }
    }

    return true;
  }

  void _listenCallback(_EventData data) {
    var key = data.key;
    if (_streamListen.containsKey(key)) {
      _streamListen[key](data.data);
    } else {
      unregister(key);
    }
  }

  void post(String key, event) {
    _controller[key].add(_EventData(key, event));
  }

  void clearAll() {
    _controller.clear();
    _streamListen.clear();
    _streamState.clear();
  }

  bool unregister(String key) {
    if (_streamState.containsKey(key)) {
      _streamState[key].cancel();
      _streamState.remove(key);
      _streamListen.remove(key);
      return true;
    } else {
      return false;
    }
  }
}