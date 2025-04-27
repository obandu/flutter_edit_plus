part of edit_plus;

class EditplusGraphNodeVisualizer implements EditplusGraphElement {
  final String label;

  EditplusGraphNodeVisualizer({required this.label});

  @override
  void paintOn(Canvas canvas) {
    canvas.drawCircle(Offset(5, 5), 10, new Paint());
  }
}
