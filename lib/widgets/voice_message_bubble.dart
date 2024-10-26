import 'package:flutter/material.dart';

class VoiceMessageBubble extends StatefulWidget {
  final bool isSender;
  final String? voiceUrl;
  final String? localVoicePath;
  final Color color;
  final int duration;
  int currentPosition;
  final bool isPlaying;
  final VoidCallback onPlay;
  final ValueChanged<int> onSeek;
  static ContextMenuController voiceContextMenuController =
      ContextMenuController();
  VoiceMessageBubble({
    super.key,
    required this.isSender,
    required this.voiceUrl,
    required this.localVoicePath,
    required this.color,
    required this.duration,
    required this.currentPosition,
    required this.isPlaying,
    required this.onPlay,
    required this.onSeek,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  late GlobalKey _cardKey;

  @override
  void initState() {
    super.initState();
    _cardKey = GlobalKey();
  }

  void _showContextMenu(Offset position) {
    VoiceMessageBubble.voiceContextMenuController.show(
      context: context,
      contextMenuBuilder: (BuildContext context) {
        return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: TextSelectionToolbarAnchors(
              primaryAnchor: position,
            ),
            buttonItems: [
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了分享");
                    ContextMenuController.removeAny();
                  },
                  label: "分享",
                  type: ContextMenuButtonType.share),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了撤回");
                    ContextMenuController.removeAny();
                  },
                  label: "撤回",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    // editableTextState.sea(
                    //     SelectionChangedCause.toolbar);
                    ContextMenuController.removeAny();
                    print('点击了搜索');
                  },
                  type: ContextMenuButtonType.searchWeb),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了转发");
                    ContextMenuController.removeAny();
                  },
                  label: "转发",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了收藏");
                    ContextMenuController.removeAny();
                  },
                  label: "收藏",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了回复");
                    ContextMenuController.removeAny();
                  },
                  label: "回复",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了多选");
                    ContextMenuController.removeAny();
                  },
                  label: "多选",
                  type: ContextMenuButtonType.custom),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width * 0.51;
    return SizedBox(
      height: 45,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onLongPress: () {
            RenderBox box =
                _cardKey.currentContext?.findRenderObject() as RenderBox;
            Offset position = box.localToGlobal(Offset.zero);
            _showContextMenu(position);
          },
          child: Card(
            key: _cardKey,
            color: widget.color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Row(
              children: widget.isSender
                  ? [
                      const SizedBox(width: 5),
                      _buildPlayButton(),
                      const SizedBox(width: 5),
                      _buildSlider()
                    ]
                  : [
                      const SizedBox(width: 5),
                      _buildSlider(),
                      const SizedBox(width: 5),
                      const SizedBox(width: 5),
                      _buildPlayButton()
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: widget.onPlay,
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircleAvatar(
            backgroundColor: widget.color,
            child: Icon(
              size: 35,
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_circle_rounded,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: SliderTheme(
              data:
                  SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
              child: Slider(
                value: widget.currentPosition.toDouble(),
                max: widget.duration.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    widget.currentPosition = value.floor();
                  });
                  widget.onSeek(value.floor());
                },
              ),
            ),
          ),
          Text('${widget.currentPosition} / ${widget.duration}'),
        ],
      ),
    );
  }
}
