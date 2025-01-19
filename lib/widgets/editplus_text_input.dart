part of edit_plus;

class EditplusTextInput extends StatelessWidget {
  final String label;
  final String text;
  TextStyle? labelTheme;
  TextStyle? textTheme;

  EditplusTextInput(
      {Key? key,
      Theme? labelTheme,
      Theme? textTheme,
      required this.label,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Row(children: [
        Flexible(
          flex: 1,
          child: Text(
            label,
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            text,
          ),
        )
      ]),
    );
  }
}
