import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomGridView extends StatefulWidget {
  int size;
  List<Widget> childList;

  CustomGridView(this.childList) {
    //calculate size
    double valve = childList.length / 3;
    int remainder = (childList.length % 3);

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
            int columnFirstIndex = index * 3;
            int columnSecondIndex = index * 3 + 1;
            int columnThirdIndex = index * 3 + 2;

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
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: widget.childList.length > columnThirdIndex
                      ? widget.childList[columnThirdIndex]
                      : Container(
                    height: 1,
                  ),
                )
              ],
            );
          }),
    );
  }
}
