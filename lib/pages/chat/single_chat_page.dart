import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:let_us_chat/blocs/chat/abstract_chat/abstract_chat_bloc.dart';
import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/utils/shared_preference_utils.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/models/message.dart';
import 'package:let_us_chat/pages/utils/platform_utils.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_more.dart';
import 'package:let_us_chat/widgets/chat_loading_indicator.dart';
import 'package:let_us_chat/widgets/file_message_bubble.dart';
import 'package:let_us_chat/widgets/image_message_bubble.dart';
import 'package:let_us_chat/widgets/no_more_chat_indicator.dart';
import 'package:let_us_chat/widgets/show_snack_bar.dart';
import 'package:let_us_chat/widgets/text_message_bubble.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:record/record.dart';
import '../../blocs/chat/single_chat/single_chat_bloc.dart';
import '../../blocs/global_user/global_user_bloc.dart';
import '../../models/user.dart';
import '../../repository/models/friend.dart';
import '../../widgets/voice_message_bubble.dart';
import '../utils/image_picker_util.dart';

class SingleChatPage extends StatefulWidget {
  final Friend friend;
  const SingleChatPage({super.key, required this.friend});
  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SingleChatPage> {
  late AnimationController _animationController;
  late final String _friendUid;
  late final Friend _friend;
  late User _user;
  late List<MessageDto> _messageList;
  late SingleChatBloc _singleChatBloc;
  late WebSocketService _webSocketService;
  final bool _isMobile = PlatformUtils.isMobile;
  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  String? _voicePath;
  late PlayerStatus _playerStatus;
  String? _currentPlayId;
  late bool _isCancelled;
  Timer? _timer; //用于记录录音时长的计时器
  late Stopwatch _stopwatch;
  late double _recordTime;
  int _currentPosition = 0;
  late bool _isRecording;
  late bool _isEmojiVisible;
  late bool _isVoiceVisible;
  late bool _isMoreSectionVisible;
  late bool _isKeyBoardVisible;
  late bool _showSelectedImages;
  late final FocusNode _keyboardFocusNode;
  late final FocusNode _textFieldFocusNode;
  late final ScrollController _scrollController;
  late final ScrollController _emojiScrollController;
  late final TextEditingController _textEditingController;
  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS]
      .contains(foundation.defaultTargetPlatform);
  late bool _canLoadMoreMessage;
  late bool _loadingMoreMessage;
  late List<String> _selectedImagePathList;
  late List<String> _selectedVideoPathList;
  late double _keyboardHeight;
  late bool _keyboardHeightStored;
  late double _inputFieldPadding;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    WidgetsBinding.instance.addObserver(this);
    //初始化为325,稍后在build中点击输入出现keyboard后会自动获取并切换
    //之后会保存到ShardPreferences中
    _keyboardHeightStored = false;
    _keyboardHeight = 325;
    _getKeyboardHeight();
    _inputFieldPadding = 0;
    _isRecording = false;
    _isCancelled = false;
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _playerStatus = PlayerStatus.ready;
    _canLoadMoreMessage = true;
    _loadingMoreMessage = false;
    _isVoiceVisible = false;
    _isEmojiVisible = false;
    _isMoreSectionVisible = false;
    _showSelectedImages = false;
    _keyboardFocusNode = FocusNode();
    _textFieldFocusNode = FocusNode();
    _isKeyBoardVisible = false;
    _scrollController = ScrollController();
    _emojiScrollController = ScrollController();
    _textEditingController = TextEditingController();
    _messageList = [];
    _selectedImagePathList = [];
    _selectedVideoPathList = [];
    _scrollController.addListener(_onScroll);
    _friend = widget.friend;
    _friendUid = _friend.userId;
    _stopwatch = Stopwatch();
    _recordTime = 0;

    _singleChatBloc = context.read<SingleChatBloc>();
    _webSocketService = serviceLocator.get<WebSocketService>();
    // 注册 WebSocket 消息处理回调
    _webSocketService.registerMessageHandler(_friendUid,
        (MessageDto newMessage) {
      _singleChatBloc.add(NewMessageReceived(message: newMessage));
    });
    _keyboardFocusNode.addListener(() {
      //键盘关闭时回调
      if (!_keyboardFocusNode.hasFocus) {
        print("键盘关闭,触发回调");
        setState(() {
          _inputFieldPadding = 0;
        });
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (_audioPlayer.duration != null &&
          _audioPlayer.duration!.inSeconds > 1) {
        print("此次播放音频长度大于1s");
        _currentPosition = pos.inSeconds;
      } else {
        print("此次播放音频长度等于1s");
        _currentPosition = (pos.inMilliseconds / 1000).round();
      }
      setState(() {});
      print("当前秒数: $_currentPosition");
    });
    _audioPlayer.playerStateStream.listen((playerState) async {
      if (playerState.processingState == ProcessingState.completed) {
        await _audioPlayer.pause();
        await _audioPlayer.seek(Duration.zero, index: 0);
        setState(() {
          _playerStatus = PlayerStatus.complete;
          _currentPlayId = null;
        });
      }
    });

    _user = serviceLocator.get<GlobalUserBloc>().globalUser!;
    _singleChatBloc.add((InitializeChatEvent(friend: _friend)));
    _singleChatBloc.add(LoadChatHistoryEvent());
  }

  void _startStopWatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  void _stopStopWatch() {
    _stopwatch.stop();
  }

  void _resetStopWatch() {
    _stopwatch.reset();
    setState(() {
      _recordTime = 0;
    });
  }

  void _getKeyboardHeight() {
    var height = globalKeyboardHeight;
    if (height != null) {
      print("缓存的keyboardHeight不为空");
      _keyboardHeightStored = true;
      _keyboardHeight = height;
      print("缓存的keyboardHeight: $_keyboardHeight");
      setState(() {});
    } else {
      _keyboardHeightStored = false;
      _keyboardHeight = 325;
      setState(() {});
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyBoardVisible) {
      setState(() {
        _isKeyBoardVisible = newValue;
      });
      if (!_isKeyBoardVisible) {
        setState(() {
          _inputFieldPadding = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _webSocketService.unregisterMessageHandler(_friendUid);
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    _emojiScrollController.dispose();
    _textEditingController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_canLoadMoreMessage &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      if (_loadingMoreMessage) return;
      //到顶部时尝试加载更多历史信息
      if (_canLoadMoreMessage) {
        _singleChatBloc.add(LoadMoreChatHistoryEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_keyboardHeightStored) {
      var height = MediaQuery.of(context).viewInsets.bottom;
      if (_keyboardFocusNode.hasFocus && height > 0) {
        _keyboardHeight = height;
        setState(() {});
        print("_keyboardHeight: $_keyboardHeight");
        SharedPreferenceUtil.saveKeyboardHeight(height);
        print("将$height缓存");
        _keyboardHeightStored = true;
      } else {
        _keyboardHeight = 325;
        setState(() {});
      }
    }
    // print(
    //     "当前showEmojiPicker: $_isEmojiVisible\nshowVoiceArea:$_isVoiceVisible\nfocusNodeHasFocus:${_keyboardFocusNode.hasFocus}");
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            ContextMenuController.removeAny(); //用于关闭聊天气泡的ContextMenu
            setState(() {
              _isEmojiVisible = false;
              _isVoiceVisible = false;
              _isMoreSectionVisible = false;
              _selectedImagePathList = [];
              _inputFieldPadding = 0;
            });
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : const Color(0xFFEBEDF0),
            //resizeToAvoidBottomInset: false,
            appBar: AppBarWithMore(
              title: _friend.alias ?? _friend.nickname,
              centerTitle: true,
              onPressed: () {
                GoRouter.of(context)
                    .pushNamed("singleChatInfo", extra: _singleChatBloc);
              },
            ),
            body: PopScope(
              canPop: !_isVoiceVisible &&
                  !_isEmojiVisible &&
                  !_isKeyBoardVisible &&
                  !_isMoreSectionVisible &&
                  !_showSelectedImages,
              onPopInvokedWithResult: (bool isPop, dynamic result) {
                print("isPop:$isPop");
                setState(() {
                  _isVoiceVisible = false;
                  _isEmojiVisible = false;
                  _isMoreSectionVisible = false;
                  _showSelectedImages = false;
                });
                ContextMenuController.removeAny();
                FocusScope.of(context).unfocus();
                _keyboardFocusNode.unfocus();
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors
                          .transparent, //防止ListView不足的部分Expanded 不渲染导致点击无法关闭contextMenu
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      child: BlocConsumer(
                        bloc: _singleChatBloc,
                        listener: (context, state) {
                          if (state is ChatHistoryLoaded) {
                            _messageList = state.chatHistory;
                            print("聊天记录加载完成");
                            _scrollToBottom();
                          } else if (state is SendingMessage) {
                            //由于messageList 是reverse过的,所以要加到start
                            print("新发送了一条消息,消息状态设置为发送中");
                            _messageList.insert(0, state.message);
                            _scrollToBottom();
                          } else if (state is SendMessageSucceed) {
                            //发送成功后,修改消息的发送状态
                            print("当前最后一个元素的位置: ${_messageList.length - 1}");
                            print(_messageList[0]);
                            setState(() {
                              print("将最后一个元素的状态设置为已发送");
                              _messageList[0].messageStatus =
                                  MessageStatus.sent;
                            });
                          } else if (state is SendMessageFailed) {
                            var failMessageIndex = _messageList.indexWhere(
                                (e) => e.messageId == state.messageId);
                            if (failMessageIndex >= 0) {
                              _messageList[failMessageIndex].messageStatus =
                                  MessageStatus.failed;
                              _scrollToBottom();
                              ShowWidgetUtil.showSnackBar(
                                  context, state.errorMessage);
                            }
                          } else if (state is LoadingMoreChatHistory) {
                            setState(() {
                              _loadingMoreMessage = true;
                            });
                            print(
                                "请求获取更多信息,设置_loadingMoreMessage=$_loadingMoreMessage");
                          } else if (state is LoadMoreChatHistorySucceed) {
                            _messageList.addAll(state.chatHistory);
                            print("获取聊天记录成功,设置loadingMoreMessage为false");
                            setState(() {
                              _loadingMoreMessage = false;
                            });
                          } else if (state is NoMoreChatHistory) {
                            setState(() {
                              _canLoadMoreMessage = false; //没有更多消息,不允许获取更多消息
                            });
                          } else if (state is NewChatMessageHasReceived) {
                            //收到消息插入到最后 由于messageList 是reverse过的,所以要加到start
                            _messageList.insert(0, state.message);
                          } else if (state is ChatHistoryCleared) {
                            _messageList.clear();
                          }
                        },
                        builder: (context, state) {
                          if (state is LoadingChatHistory) {
                            print("获取聊天记录中");
                            return Column(
                              children: [
                                const Text("获取聊天记录中"),
                                Center(
                                  child: LoadingAnimationWidget.twistingDots(
                                    leftDotColor: const Color(0xFF1A1A3F),
                                    rightDotColor: const Color(0xFFEA3799),
                                    size: 200,
                                  ),
                                ),
                              ],
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            reverse: true, // 最新的消息显示在最下方
                            itemCount: _messageList.length +
                                1, // 如果在获取聊天历史记录,给loading框加一个位置
                            itemBuilder: (context, index) {
                              if (index == _messageList.length) {
                                if (!_canLoadMoreMessage) {
                                  print("显示没有更多信息");
                                  return const NoMoreChatIndicator();
                                } else if (_loadingMoreMessage) {
                                  print("显示loading框");
                                  return const ChatLoadingIndicator();
                                }
                                return const SizedBox.shrink();
                              }
                              //以下都要转换为localDateTime,否则因为时区问题有时不会判断为同一天
                              final message = _messageList[index];
                              //print("index: $index sendTime: ${message.sendTime.toIso8601String()}");
                              final isFirstMessageOfDay = index ==
                                      _messageList.length - 1 ||
                                  !_isSameDay(
                                      _messageList[index + 1]
                                          .sendTime
                                          .toLocal(),
                                      message.sendTime
                                          .toLocal()); //最后一条消息与上一条消息发送时间不是同一天,则最后一条消息为今天的第一条消息

                              final formattedTime = DateFormat('HH:mm').format(
                                  message.sendTime
                                      .toLocal()); //用当前时区显示,显示时间例如00:06

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isFirstMessageOfDay)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          _formatDate(message.sendTime),
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 0),
                                    child: _buildMessageBubble(
                                        message, formattedTime),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  _buildInputField(),
                  _buildEmojiPicker(),
                  _buildVoiceInput(),
                  _buildMoreSection()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageDto message, String formattedTime) {
    bool isSender = message.senderId == currentUserId!;
    Color? messageBubbleColor = isSender
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.green[700] // 深色模式下使用较深的绿色
            : Colors.green[100]) // 浅色模式下使用较浅的绿色
        : (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700] // 深色模式下使用较深的灰色
            : Colors.grey[350]); // 浅色模式下使用较浅的灰色

    Widget statusIcon;
    if (message.messageStatus == MessageStatus.sending) {
      statusIcon = const Icon(
        Icons.upload,
        size: 12,
        color: Colors.green,
      );
    } else if (message.messageStatus == MessageStatus.sent) {
      statusIcon = const Icon(Icons.check, size: 12, color: Colors.green);
    } else {
      statusIcon = const Icon(Icons.error, size: 12, color: Colors.red);
    }

    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSender) _friendAvatar(),
        Flexible(
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              switch (message.messageType) {
                MessageType.text => TextMessageBubble(
                    content: message.content ?? "",
                    isSender: isSender,
                    color: messageBubbleColor!,
                  ),
                MessageType.image => ImageMessageBubble(
                    storagePath: message.cachedMedia?.path,
                    imageUrl: message.mediaUrl,
                  ),
                MessageType.file => FileMessageBubble(
                    fileName: message.mediaName ?? "no name",
                    fileSize: message.mediaSize ?? 0,
                    fileUrl: message.mediaUrl!,
                    isUploading: false,
                    onTap: () => print("点击了文件"),
                    onLongPress: () {
                      print("长按了文件");
                    },
                  ),
                //TODO: Handle this case
                MessageType.video => throw UnimplementedError(),
                MessageType.voice => VoiceMessageBubble(
                    isSender: message.senderId == _user.userId,
                    voiceUrl: message.mediaUrl,
                    localVoicePath: message.cachedMedia?.path,
                    currentPosition: _currentPlayId == message.messageId
                        ? _currentPosition
                        : 0,
                    color: messageBubbleColor!,
                    duration: message.mediaSize?.toInt() ?? 0,
                    isPlaying: _playerStatus == PlayerStatus.playing &&
                        _currentPlayId == message.messageId,
                    onPlay: () async {
                      if (_playerStatus == PlayerStatus.playing) {
                        //只有当前播放的id是自己的消息id时才能控制
                        if (message.messageId == _currentPlayId) {
                          setState(() {
                            _playerStatus = PlayerStatus.paused;
                          });
                          await _audioPlayer.pause();
                        }
                      } else {
                        //如果上一个音频没有播放完,继续上一次的播放
                        if (_playerStatus == PlayerStatus.paused) {
                          setState(() {
                            _playerStatus = PlayerStatus.playing;
                          });
                          await _audioPlayer.play();
                        } //上一次已经播放完成,则重置播放的音频url
                        else {
                          if (message.mediaUrl != null) {
                            if (_isMobile) {
                              final audioSource = LockCachingAudioSource(
                                  Uri.parse(message.mediaUrl!));
                              await _audioPlayer.setAudioSource(audioSource);
                            } else {
                              await _audioPlayer.setUrl(message.mediaUrl!);
                            }
                            setState(() {
                              _playerStatus = PlayerStatus.playing;
                              _currentPlayId = message.messageId;
                            });
                            await _audioPlayer.play();
                          } else {
                            ShowWidgetUtil.showToast(context, "此消息无法播放");
                          }
                        }
                      }
                    },
                    onSeek: (int value) async {
                      if (_playerStatus != PlayerStatus.playing) {
                        if (_isMobile) {
                          final audioSource = LockCachingAudioSource(
                              Uri.parse(message.mediaUrl!));
                          await _audioPlayer.setAudioSource(audioSource);
                        } else {
                          await _audioPlayer.setUrl(message.mediaUrl!);
                        }
                        await _audioPlayer.seek(Duration(seconds: value));
                        await _audioPlayer.pause();
                        print("设置当前状态为pause");
                        setState(() {
                          _currentPlayId = message.messageId;
                          _playerStatus = PlayerStatus.paused;
                        });
                      }
                    },
                  ),
                // TODO: Handle this case.
                MessageType.recall => throw UnimplementedError(),
              },
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (isSender) ...[
                    const SizedBox(width: 8),
                    statusIcon,
                  ]
                ],
              ),
            ],
          ),
        ),
        if (isSender) _userAvatar(),
      ],
    );
  }

  Widget _friendAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).pushNamed("friendInfo", extra: _friendUid);
        },
        child: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(_friend.avatar),
        ),
      ),
    );
  }

  Widget _userAvatar() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).pushNamed("friendInfo", extra: _user.userId);
        },
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(_user.avatar),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.only(bottom: _inputFieldPadding),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // 阴影颜色
              //spreadRadius: 5, // 阴影扩散半径
              //blurRadius: 7, // 模糊半径
              offset: const Offset(0, 3), // 阴影的偏移量
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          children: [
            // Emoji
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {
                if (_isEmojiVisible) {
                  FocusScope.of(context).requestFocus();
                  _keyboardFocusNode.requestFocus();
                  setState(() {
                    _isEmojiVisible = false;
                    _isVoiceVisible = false;
                    _isMoreSectionVisible = false;
                    _inputFieldPadding = 0;
                  });
                } else {
                  FocusScope.of(context).unfocus();
                  _keyboardFocusNode.unfocus();
                  setState(() {
                    _isEmojiVisible = true;
                    _isVoiceVisible = false;
                    _isMoreSectionVisible = false;
                    _inputFieldPadding = 0;
                  });
                }
              },
            ),

            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                if (_isMoreSectionVisible) {
                  FocusScope.of(context).requestFocus();
                  _keyboardFocusNode.requestFocus();
                  setState(() {
                    _isMoreSectionVisible = false;
                    _isVoiceVisible = false;
                    _isEmojiVisible = false;
                    _inputFieldPadding = 0;
                  });
                } else {
                  FocusScope.of(context).unfocus();
                  _keyboardFocusNode.unfocus();
                  setState(() {
                    _isMoreSectionVisible = true;
                    _isVoiceVisible = false;
                    _isEmojiVisible = false;
                    _inputFieldPadding = 0;
                  });
                }
              },
            ),
            // 输入框
            Expanded(
              child: KeyboardListener(
                focusNode: _keyboardFocusNode,
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    _sendTextMessage();
                    FocusScope.of(context).requestFocus(_textFieldFocusNode);
                  }
                },
                child: TextField(
                  focusNode: _textFieldFocusNode,
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: "输入消息...",
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    print("点击了消息输入框,softKeyboard高度: $_keyboardHeight");
                    setState(() {
                      _isEmojiVisible = false;
                      _isVoiceVisible = false;
                      _isMoreSectionVisible = false;
                      if (_isMobile) {
                        _inputFieldPadding = _keyboardHeight;
                      } else {
                        _inputFieldPadding = 0;
                      }
                    });
                  },
                ),
              ),
            ),
            // Voice input button
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                if (_isVoiceVisible) {
                  FocusScope.of(context).requestFocus(_keyboardFocusNode);
                  setState(() {
                    _isVoiceVisible = false;
                    _isEmojiVisible = false;
                    _isMoreSectionVisible = false;
                    _inputFieldPadding = 0;
                  });
                } else {
                  FocusScope.of(context).unfocus();
                  _keyboardFocusNode.unfocus();
                  setState(() {
                    _isEmojiVisible = false;
                    _isMoreSectionVisible = false;
                    _isVoiceVisible = !_isVoiceVisible;
                    _inputFieldPadding = 0;
                  });
                }
              },
            ),
            // Send button
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendTextMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendTextMessage() async {
    if (_textEditingController.text.length > 300) {
      ShowWidgetUtil.showToast(context, "一次消息最多发送300个字符");
      return;
    }
    if (_textEditingController.text.isNotEmpty) {
      _singleChatBloc.add(
        SendChatMsgEvent(
          message: MessageDto(
            messageId: null,
            chatType: ChatType.singleChat,
            senderId: currentUserId!,
            receiverId: _friendUid,
            messageType: MessageType.text,
            messageStatus: MessageStatus.sending,
            content: _textEditingController.text,
            sendTime: DateTime.now(),
          ),
        ),
      );
      _textEditingController.clear();
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    //print("第一条消息: ${date1.toIso8601String()}, 第二条消息: ${date2.toIso8601String()}");
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final difference = _daysBetween(date.toLocal(), DateTime.now().toLocal());
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  int _daysBetween(DateTime from, DateTime to) {
    //print("days between ${from.toIso8601String()},${to.toIso8601String()}");
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  Widget _buildMoreSection() {
    return Offstage(
      offstage: !_isMoreSectionVisible,
      child: _showSelectedImages
          ? _buildImageArea(_selectedImagePathList)
          : SizedBox(
              height: _keyboardHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: GridView.count(
                  crossAxisCount: 4, // 每行4个元素
                  mainAxisSpacing: 20, // 每行之间的垂直距离
                  crossAxisSpacing: 16, // 每列之间的水平距离
                  childAspectRatio: 1,
                  children: [
                    _buildGridItem(Icons.photo, "相册", () async {
                      print("点击了相册");
                      setState(() {
                        _showSelectedImages = true;
                      });
                    }),
                    _buildGridItem(Icons.camera_alt, "拍摄", () async {
                      print("点击了拍摄");
                      final picker = ImagePicker();
                      await ImagePickerUtil.getImageFromCamera(picker)
                          .then((file) async {
                        if (file != null) {
                          print("拍摄的文件地址为${file.path}");
                          if (mounted) {
                            final image = await GoRouter.of(context).pushNamed(
                                "takePhotoResult",
                                extra: file.path) as File?;
                            if (image != null) {
                              print("照片地址为: ${image.path}");
                              File file = File(image.path);
                              var imageMsg = MessageDto(
                                  chatType: ChatType.singleChat,
                                  senderId: _user.userId,
                                  receiverId: _friendUid,
                                  messageType: MessageType.image,
                                  messageStatus: MessageStatus.sending,
                                  cachedMedia: file,
                                  sendTime: DateTime.now());
                              _singleChatBloc
                                  .add(SendChatMsgEvent(message: imageMsg));
                            }
                          }
                        } else {
                          print("拍摄的文件为空");
                        }
                      });
                    }),
                    _buildGridItem(Icons.location_on, "位置", () {
                      print("点击了位置");
                    }),
                    _buildGridItem(Icons.mic, "语音输入", () {
                      print("点击了语音输入");
                      setState(() {
                        _isMoreSectionVisible = false;
                        _isVoiceVisible = true;
                      });
                    }),
                    _buildGridItem(Icons.inbox, "我的收藏", () {
                      print("点击了我的收藏");
                    }),
                    _buildGridItem(Icons.account_box, "名片", () {
                      print("点击了名片");
                    }),
                    _buildGridItem(Icons.folder, "文件", () {
                      GoRouter.of(context)
                          .pushNamed("sendFile", extra: _friend.userId);
                      print("点击了文件");
                    }),
                    _buildGridItem(Icons.music_note, "音乐", () {
                      print("点击了音乐");
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageArea(List<String> fileList) {
    return SizedBox(
      height: _keyboardHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                children: [
                  // 添加图标按钮
                  InkWell(
                    onTap: () async {
                      print("点击了继续添加图片");
                      final picker = ImagePicker();
                      await ImagePickerUtil.getMultipleImageFromGallery(
                              picker, 12)
                          .then((fileList) {
                        if (fileList != null) {
                          setState(() {
                            _selectedImagePathList
                                .addAll(fileList.map((e) => e.path).toList());
                          });
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                        crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: const Icon(Icons.add,
                                size: 40, color: Colors.blue),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "相册",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //拍照
                  InkWell(
                    onTap: () async {
                      print("点击了拍照");
                      final picker = ImagePicker();
                      await ImagePickerUtil.getImageFromCamera(picker)
                          .then((file) async {
                        if (file != null) {
                          print("拍摄的文件地址为${file.path}");
                          if (mounted) {
                            final image = await GoRouter.of(context).pushNamed(
                                "takePhotoResult",
                                extra: file.path) as File?;
                            if (image != null) {
                              _selectedImagePathList.add(image.path);
                              setState(() {});
                            }
                          }
                        } else {
                          print("拍摄的文件为空");
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                        crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: const Icon(Icons.photo_camera,
                                size: 40, color: Colors.blue),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "拍照",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //清除全部
                  InkWell(
                    onTap: () async {
                      print("点击清空所有图片");
                      _selectedImagePathList = [];
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                        crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: const Icon(Icons.delete,
                                size: 40, color: Colors.red),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "清空全部",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 其他元素
                  ...fileList
                      .asMap()
                      .entries
                      .map((file) => _buildImageGrid(file.value, file.key))
                      .toList(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSelectedImages = false;
                      _selectedImagePathList = [];
                    });
                  },
                  icon: const CircleAvatar(
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    print("点击发送图片按钮");
                    if (PlatformUtils.isWeb) {
                      showFloatSnackBar(
                          context: context,
                          content: "目前web端不支持发送图片信息",
                          bottomMargin: 60);
                      return;
                    }
                    for (var image in _selectedImagePathList) {
                      _singleChatBloc.add(SendChatMsgEvent(
                          message: MessageDto(
                              chatType: ChatType.singleChat,
                              senderId: _user.userId,
                              receiverId: _friendUid,
                              cachedMedia: File(image),
                              messageType: MessageType.image,
                              messageStatus: MessageStatus.sending,
                              sendTime: DateTime.now())));
                    }
                  },
                  icon: const CircleAvatar(
                    child: Icon(Icons.file_upload_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(String filePath, int currentIndex) {
    return InkWell(
      onTap: () {
        print("点击照片区域,currentIndex: $currentIndex");
        GoRouter.of(context).pushNamed("photoGallery", extra: {
          'imageList': _selectedImagePathList,
          'initialIndex': currentIndex
        });
      },
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            width: (MediaQuery.of(context).size.width - 50) / 4,
            height: (MediaQuery.of(context).size.width - 50) / 4,
            child: Image.file(File(filePath)),
          ),
          Positioned(
            top: -14, // 调整此值以改变图标的垂直位置
            right: -14, // 调整此值以改变图标的水平位置
            child: IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.red),
              onPressed: () {
                // 添加删除逻辑
                print("点击了删除照片");
                _selectedImagePathList.removeWhere((e) => e == filePath);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          highlightColor: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: (MediaQuery.of(context).size.width - 200) / 4,
            height: (MediaQuery.of(context).size.width - 200) / 4,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent, width: 1),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.black),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildEmojiPicker() {
    Color backGroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    return Offstage(
      offstage: !_isEmojiVisible,
      child: SizedBox(
        height: _keyboardHeight,
        child: EmojiPicker(
          scrollController: _emojiScrollController,
          textEditingController: _textEditingController,
          config: Config(
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: 28 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.2
                        : 1.0),
                backgroundColor: backGroundColor),
            swapCategoryAndBottomBar: true, //将删除按钮放到emoji上方,emoji类别选择放到下方
            skinToneConfig: const SkinToneConfig(),
            categoryViewConfig: CategoryViewConfig(
                extraTab: CategoryExtraTab.BACKSPACE,
                backgroundColor: backGroundColor),
            bottomActionBarConfig: const BottomActionBarConfig(
                showBackspaceButton: false, showSearchViewButton: false),
            searchViewConfig: const SearchViewConfig(),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceInput() {
    return Stack(
      children: [
        Offstage(
          offstage: !_isVoiceVisible,
          child: SizedBox(
            height: _keyboardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRecording ? "" : '按住说话',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 28.0),
                    LongPressDraggable(
                      feedback: _buildRecordingButton(),
                      childWhenDragging: const SizedBox.shrink(), // 拖动时隐藏静态按钮
                      onDragStarted: () {
                        print("onDragStarted开始录音");
                        setState(() {
                          _isRecording = true;
                          _isCancelled = false; //每次录音时重置
                        });
                        _requestMicrophonePermission();
                        _startRecordVoice();
                      },
                      onDragEnd: (details) async {
                        if (_isCancelled) {
                          await _cancelRecordVoice();
                          print("录音已取消");
                        } else {
                          print("松开手指,录音结束");
                          await _stopRecordVoice();
                          print("录音时长为: $_recordTime");
                          if (_recordTime < 1) {
                            if (mounted) {
                              ShowWidgetUtil.showToast(context, '说话时间太短',
                                  bottom: 250);
                            }
                            return;
                          }
                          var message = MessageDto(
                              chatType: ChatType.singleChat,
                              cachedMedia: File(_voicePath!),
                              senderId: _user.userId,
                              receiverId: _friendUid,
                              mediaSize: _recordTime,
                              messageType: MessageType.voice,
                              messageStatus: MessageStatus.sending,
                              sendTime: DateTime.now());
                          _singleChatBloc.add(
                            SendChatMsgEvent(
                              message: message,
                            ),
                          );
                        }
                      },
                      onDragUpdate: (details) {},
                      child: _buildRecordingButton(), // 拖动前显示的按钮
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 40,
          top: 40,
          child: DragTarget(
            builder: (BuildContext context, List<String?> candidateData,
                List<dynamic> rejectedData) {
              return Offstage(
                offstage: !_isRecording,
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // 动态改变颜色
                  ),
                  child: const Center(
                    child: Icon(
                      size: 50,
                      Icons.close,
                    ),
                  ),
                ),
              );
            },
            onWillAcceptWithDetails: (data) {
              // 当拖动对象进入 DragTarget 区域时调用
              print("拖动对象进入 DragTarget 区域");
              // 返回 true 表示接受拖动对象
              return true;
            },
            onAcceptWithDetails: (data) {
              // 当拖动对象被释放到 DragTarget 区域内时调用
              // 处理接受的拖动数据
              print("到 DragTarget 区域内");
            },
            onLeave: (data) async {
              // 当拖动对象离开 DragTarget 区域时调用
              print("取消录音");
              setState(() {
                _isCancelled = true;
              });
              await _audioRecorder.cancel();
            },
          ),
        ),
        Positioned(
          left: 40,
          top: 40,
          child: DragTarget(
            builder: (BuildContext context, List<String?> candidateData,
                List<dynamic> rejectedData) {
              return Offstage(
                offstage: !_isRecording,
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue, // 动态改变颜色
                  ),
                  child: const Center(
                      child: Text(
                    "文",
                    style: TextStyle(fontSize: 40),
                  )),
                ),
              );
            },
            onWillAcceptWithDetails: (data) {
              // 当拖动对象进入 DragTarget 区域时调用
              print("拖动对象进入 转文字 区域");
              // 返回 true 表示接受拖动对象
              return true;
            },
            onAcceptWithDetails: (data) {
              // 当拖动对象被释放到 DragTarget 区域内时调用
              // 处理接受的拖动数据
              print("到 DragTarget 区域内");
            },
            onLeave: (data) {
              // 当拖动对象离开 DragTarget 区域时调用
              print("转文字");
              _stopRecordVoice();
              var path = _voicePath;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingButton() {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: const Center(
        child: Icon(
          color: Colors.white,
          Icons.mic,
          size: 50.0,
        ),
      ),
    );
  }

  Future<void> _startRecordVoice() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        String fileName =
            "recording_${DateTime.now().millisecondsSinceEpoch}.m4a";
        _voicePath = "${dir.path}/$fileName";
        await _audioRecorder.start(
            const RecordConfig(
                encoder: AudioEncoder.aacLc,
                sampleRate: 44100,
                bitRate: 128000),
            path: _voicePath!);
        _resetStopWatch();
        _startStopWatch();
        _timer =
            Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
          if (_stopwatch.isRunning) {
            _recordTime = _stopwatch.elapsed.inSeconds.toDouble();
          }
        });
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print("开始录制音频失败: $e");
      _requestMicrophonePermission();
    }
  }

  Future<void> _stopRecordVoice() async {
    try {
      String? path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _voicePath = path!;
      });
      _stopStopWatch();
      _timer?.cancel();
    } catch (e) {
      print("停止录制音频失败: $e");
      _requestMicrophonePermission();
    }
  }

  Future<void> _cancelRecordVoice() async {
    await _audioRecorder.cancel();
    _timer?.cancel();
    print("取消了录音");
    setState(() {
      _isRecording = false;
      _isCancelled = true;
    });
  }

  Future<void> _requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    var nowStatus = await Permission.microphone.status;
    if (nowStatus == PermissionStatus.denied ||
        nowStatus == PermissionStatus.permanentlyDenied) {
      if (mounted) {
        bool result = ShowWidgetUtil.showAlertDialog(
          context,
          "语音功能被禁用",
          "无法使用设备麦克风,请检查应用权限后重试",
        );
        if (result) {
          await openAppSettings();
        }
      }
    }
  }
}
