part of edit_plus;

class EditplusFormsection extends StatefulWidget {
  final Widget body;
  final String title;
  String? background = "FFFFFFFF";

  EditplusFormsection(
      {required this.title, required this.body, this.background});

  @override
  State<StatefulWidget> createState() => EditplusFormsectionState();
}

class EditplusFormsectionState extends State<EditplusFormsection> {
  bool hidden = false;
  int color_a = 0xFF;
  int color_r = 0xFF;
  int color_g = 0xFF;
  int color_b = 0xFF;

  @override
  void initState() {
    // make the colours if it exists
    if (widget.background!.length == 6) {
      color_r = int.parse(widget.background!.substring(0, 2), radix: 16);
      color_g = int.parse(widget.background!.substring(2, 4), radix: 16);
      color_b = int.parse(widget.background!.substring(4), radix: 16);
    } else if (widget.background!.length == 8) {
      color_a = int.parse(widget.background!.substring(0, 2), radix: 16);
      color_r = int.parse(widget.background!.substring(2, 4), radix: 16);
      color_g = int.parse(widget.background!.substring(4, 6), radix: 16);
      color_b = int.parse(widget.background!.substring(6), radix: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    Icon arrowIcon = (hidden == false)
        ? Icon(Icons.arrow_upward_sharp)
        : Icon(Icons.arrow_downward_rounded);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(width: 1.0, color: Colors.grey)),
            padding: EdgeInsets.all(3.0),
            child: Row(
              children: [
                Expanded(
                  child: EditPlusUiUtils.getBoldLabelText(widget.title),
                ),
                TextButton.icon(
                    onPressed: hideUnHideSection,
                    label: Text(""),
                    icon: arrowIcon),
              ],
            )),
        (hidden == true)
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(color_a, color_r, color_g, color_b),
                    border: Border.all(width: 1.0, color: Colors.grey)),
                child: Row(children: [
                  Expanded(child: widget.body),
                ])),
      ],
    );
  }

  void hideUnHideSection() {
    hidden = !hidden;
    setState(() {});
  }
}
