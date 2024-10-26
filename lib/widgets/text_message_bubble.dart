import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';


class TextMessageBubble extends StatefulWidget {
  final bool isSender;
  final String content;
  final Color color;
  const TextMessageBubble(
      {super.key,
      required this.content, required this.isSender, required this.color,
      });

  @override
  State<StatefulWidget> createState() => _TextMessageBubbleState();
}

class _TextMessageBubbleState extends State<TextMessageBubble> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //选择的文本
    var selectedText = '';
    return SelectionArea(
      onSelectionChanged: (SelectedContent? selectedContent){
        selectedText = selectedContent?.plainText ?? "";
      },
      contextMenuBuilder: (context, selectionRegionState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
            buttonItems: <ContextMenuButtonItem>[
              ContextMenuButtonItem(
                  onPressed: () {
                    selectionRegionState
                        .selectAll(SelectionChangedCause.toolbar);
                  },
                  type: ContextMenuButtonType.selectAll),
              ContextMenuButtonItem(
                  onPressed: () {
                    selectionRegionState
                        .copySelection(SelectionChangedCause.toolbar);

                    selectionRegionState.hideToolbar();
                  },
                  type: ContextMenuButtonType.copy),
              ContextMenuButtonItem(
                  onPressed: ()async{
                    await Share.share(selectedText);
                    print("点击了分享");
                  },
                  label: "分享",
                  type: ContextMenuButtonType.share),
              ContextMenuButtonItem(
                  onPressed: () {
                    // editableTextState.sea(
                    //     SelectionChangedCause.toolbar);
                    print('点击了搜索');
                  },
                  type: ContextMenuButtonType.searchWeb),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了转发");
                  },
                  label: "转发",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了收藏");
                  },
                  label: "收藏",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了回复");
                  },
                  label: "回复",
                  type: ContextMenuButtonType.custom),
              ContextMenuButtonItem(
                  onPressed: () {
                    print("点击了多选");
                  },
                  label: "多选",
                  type: ContextMenuButtonType.custom),
            ],
            anchors: selectionRegionState.contextMenuAnchors);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 计算文本的最大宽度为父组件宽度的 4/5
            double maxWidth = constraints.maxWidth * 0.8;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                widget.content,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.clip,
              ),
            );
          },
        ),
      ),
    );
  }
}
