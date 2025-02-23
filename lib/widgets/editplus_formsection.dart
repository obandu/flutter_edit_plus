part of edit_plus;

class EditplusFormsection extends StatefulWidget {
  final Widget body;
  final String title;

  EditplusFormsection({required this.title, required this.body});

  @override
  State<StatefulWidget> createState() => EditplusFormsectionState();
}

class EditplusFormsectionState extends State<EditplusFormsection> {
  bool hidden = false;

  @override
  Widget build(BuildContext context) {
    Icon arrowIcon = (hidden == false)
        ? Icon(Icons.arrow_upward_sharp)
        : Icon(Icons.arrow_downward_rounded);
    return Column(
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
                OutlinedButton.icon(
                    onPressed: hideUnHideSection,
                    label: Text(""),
                    icon: arrowIcon),
              ],
            )),
        (hidden == true)
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.grey)),
                padding: EdgeInsets.all(3.0),
                child: widget.body),
      ],
    );
  }

  void hideUnHideSection() {
    hidden = !hidden;
    setState(() {});
  }
}
