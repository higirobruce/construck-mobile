import 'package:flutter/material.dart';
import 'package:mobile2/screens/mainScreen.dart';

class ListSelector extends StatefulWidget {
  final void Function(dynamic) notifyParent;
  final selectedItem;
  final itemList;
  final BuildContext context;
  const ListSelector(
      {Key? key,
      required this.notifyParent,
      required this.context,
      required this.selectedItem,
      required this.itemList})
      : super(key: key);

  @override
  State<ListSelector> createState() => _ListSelectorState();
}

class _ListSelectorState extends State<ListSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: GLOBAL_PADDING),
      child: Container(
        height: 1000.0,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
                decoration: BoxDecoration(
                  border: index == 0
                      ? const Border() // This will create no border for the first item
                      : Border(
                          top: BorderSide(
                              width: 1,
                              color: Colors.grey[
                                  300]!)), // This will create top borders for the rest
                ),
                child: Padding(
                  padding: const EdgeInsets.all(GLOBAL_PADDING),
                  child: GestureDetector(
                      onTap: () => {
                            widget.notifyParent(widget.itemList![index]),
                            Navigator.pop(context)
                          },
                      child: Text(widget.itemList![index]['description'])),
                ));
          },
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.itemList!.length,
        ),
      ),
    );
  }
}
