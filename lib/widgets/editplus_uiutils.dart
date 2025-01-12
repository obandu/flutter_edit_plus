part of edit_plus;

class EditPlusUiUtils {
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

  static Text getBoldLabelText(String labelText) {
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

  static Enum SMALL_WIDTH, MEDIUM_WIDTH, LARGE_WIDTH;

  static Enum getBodySize(BuildContext context) {
    Size bodySize = MediaQuery.getSize(context);

    if (bodySize.width < 600) {
      return SMALL_WIDTH;
    } else if (bodySize.width < 1280) {
      return MEDIUMS_WIDTH;
    }

    return LARGE_WIDTH;
  }
}
