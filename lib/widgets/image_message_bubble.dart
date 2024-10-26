import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageMessageBubble extends StatefulWidget {
  final String? imageUrl;
  final String? storagePath;
  static final ContextMenuController _contextMenuController = ContextMenuController();
  const ImageMessageBubble({
    super.key,
    required this.imageUrl,
    this.storagePath,
  });

  @override
  State<StatefulWidget> createState() => _ImageMessageBubbleState();
}

class _ImageMessageBubbleState extends State<ImageMessageBubble> with AutomaticKeepAliveClientMixin<ImageMessageBubble>{

  late GlobalKey _messageKey;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _messageKey = GlobalKey();
  }
  @override
  void dispose() {
    super.dispose();
  }
  void _showContextMenu(Offset position){
    ImageMessageBubble._contextMenuController.show(context: context, contextMenuBuilder: (BuildContext context) {
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
          ]
      );
    }, );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    //The number of device pixels for each logical pixel.
    //使用这个乘以下方图片的宽度,使得照片保持清晰性的同时不会rebuild
    var devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    //print("这个图片信息的本地路径为: $storagePath,url为: $imageUrl");
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        print("点击了图片");
        GoRouter.of(context).pushNamed("photoView", extra: {
          'imagePath': widget.storagePath,
          'imageUrl': widget.imageUrl
        });
      },
      onLongPress: () {
        print("长按了图片");
        RenderBox box = _messageKey.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        _showContextMenu(position);
        },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 8, 5),
        child: ConstrainedBox(
          key: _messageKey,
          constraints: BoxConstraints(
              maxWidth: size.width * 0.6, maxHeight: size.height * 0.24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: widget.storagePath != null
                ? Image.file(File(widget.storagePath!))
                : CachedNetworkImage(
              fit: BoxFit.contain,
              maxWidthDiskCache: (size.width*0.6*devicePixelRatio).toInt(),//使得image不会rebuild
              maxHeightDiskCache: (size.height*0.6*devicePixelRatio).toInt(),
              fadeInDuration: Duration.zero,
              imageUrl: widget.imageUrl!,
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5.0, // 更细的圆圈
                  ),
                );
              },
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
