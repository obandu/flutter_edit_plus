part of edit_plus;

class EditplusGraphPainter extends CustomPainter {
  final List<EditplusGraphElement> elements;

  EditplusGraphPainter({required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    for (EditplusGraphElement graphElement in elements) {
      graphElement.paintOn(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
