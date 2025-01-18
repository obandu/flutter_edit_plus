part of edit_plus;

class EditPlusUiUtils {
  static const LARGE_WIDTH = 1, MEDIUM_WIDTH = 2, SMALL_WIDTH = 3;

  static InputDecoration getFormTextFieldDecoration(
    String labelText,
    String hintText,
  ) {
    return InputDecoration(
      // hintText: 'Category Name',
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
      labelText: labelText,
    );
  }

  static Text getBoldLabelText(String labelText,
      {int? fontSize, TextAlign? textAlignment}) {
    return Text(
      labelText,
      style: (TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }

  static Text getStyledText({
    required String text,
    required FontWeight weight,
    required double size,
    Color? color,
  }) {
    return Text(text, style: (TextStyle(fontSize: size, fontWeight: weight)));
  }

  static int getBodySize(BuildContext context) {
    Size bodySize = MediaQuery.sizeOf(context);

    if (bodySize.width < 600) {
      return EditPlusUiUtils.SMALL_WIDTH;
    } else if (bodySize.width < 1280) {
      return EditPlusUiUtils.MEDIUM_WIDTH;
    }

    return EditPlusUiUtils.LARGE_WIDTH;
  }

  static Widget getAppBar(Widget title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: 38, child: Row(children: [Expanded(child: title)])),
    ]);
  }

  static Widget getLeadingLogo() {
    return Container(
      width: 36,
      height: 36,
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        image: new DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset('assets/images/logo.png').image),
      ),
    );
  }
}
