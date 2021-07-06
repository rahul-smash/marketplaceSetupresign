import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomGridView extends StatefulWidget {
  int size;
  List<Widget> childList;

  int columns;

  CustomGridView(this.childList, {this.columns = 2}) {
    //calculate size
    double valve = childList.length / columns;
    int remainder = (childList.length % columns);

    size = (valve).truncate();
    if (remainder != 0) {
      size += 1;
    }

//    print("size = ${size}");
  }

  @override
  _CustomGridViewState createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView.separated(
          separatorBuilder: (context, index) => Container(
                height: 10,
                color: Colors.transparent,
              ),
          itemCount: widget.size,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            int columnFirstIndex = index * 2;
            int columnSecondIndex = index * 2 + 1;
//            int columnThirdIndex = index * 2 + 2;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: widget.childList.length > columnFirstIndex
                        ? widget.childList[columnFirstIndex]
                        : Container(
                            height: 1,
                          )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: widget.childList.length > columnSecondIndex
                      ? widget.childList[columnSecondIndex]
                      : Container(
                          height: 1,
                        ),
                ),
//                SizedBox(
//                  width: 10,
//                ),
//                Expanded(
//                  child: widget.childList.length > columnThirdIndex
//                      ? widget.childList[columnThirdIndex]
//                      : Container(
//                          height: 1,
//                        ),
//                )
              ],
            );
          }),
    );
  }

  Widget _getDynamicallyChildren(int index) {
    List<int> columnIndexes = List.generate(widget.columns, (columnIndex) {
      return index * widget.columns + (index % widget.columns);
    });

    List<Widget> children = List.empty(growable: true);
    for (var i = 0; i < columnIndexes.length; i++) {
      children.add(Expanded(
          child: widget.childList.length > columnIndexes[i]
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.childList[columnIndexes[i]],
                  ],
                )
              : Container(
                  height: 1,
                )));
      if (columnIndexes.length - 1 > i) {
        children.add(
          SizedBox(
            width: 10,
          ),
        );
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
