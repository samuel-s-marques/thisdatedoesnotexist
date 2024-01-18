import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_state_enum.dart';

class GroupedListView extends StatelessWidget {
  const GroupedListView({
    super.key,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.itemCount = 0,
    this.groupSeparatorBuilder,
    this.padding,
    this.reverse = false,
    this.shrinkWrap = false,
    this.state = ChatState.idle,
    this.controller,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final bool shrinkWrap;
  final ChatState state;
  final ScrollController? controller;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext) errorBuilder;
  final Widget Function(BuildContext) loadingBuilder;
  final Widget Function(String separator)? groupSeparatorBuilder;
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (state == ChatState.empty) {
          return emptyBuilder(context);
        } else if (state == ChatState.error) {
          return errorBuilder(context);
        } else if (state == ChatState.loading) {
          return loadingBuilder(context);
        } else {
          return ListView.builder(
            itemCount: itemCount,
            padding: padding,
            reverse: reverse,
            shrinkWrap: shrinkWrap,
            controller: controller,
            itemBuilder: (BuildContext context, int index) {
              return itemBuilder(context, index);
            },
          );
        }
      },
    );
  }
}
