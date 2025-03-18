part of edit_plus;

class EditplusNuTableColumn {
  final String columnLabel;
  final String columnName;

  double? columnWidth;

  EditplusNuTableColumn(
      {required this.columnName, required this.columnLabel, this.columnWidth});

  Widget getView() {
    return ConstrainedBox(
        constraints: BoxConstraints(minWidth: columnWidth!),
        child: Container(
            padding: EdgeInsets.all(2),
            color: Colors.grey,
            child: Text(columnLabel)));
  }
}
