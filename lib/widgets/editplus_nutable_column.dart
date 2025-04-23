part of edit_plus;

class EditplusNuTableColumn {
  final String columnLabel;
  final String columnName;
  final TextAlign? contentAlignment;

  double? columnWidth;
  final double defaultColumnWidth = 180;

  EditplusNuTableColumn(
      {required this.columnName,
      required this.columnLabel,
      this.columnWidth,
      this.contentAlignment});

  Widget getView() {
    // print("Column name $columName width $columnWidth");
    if (columnWidth == null || columnWidth == 0) {
      columnWidth = defaultColumnWidth;
    }
    return ConstrainedBox(
        constraints: BoxConstraints(minWidth: columnWid),
        child: Container(
            padding: EdgeInsets.all(2),
            color: Colors.grey,
            child: Text(columnLabel)));
  }

  get columName => columnName;

  double get columnWid =>
      (columnWidth == null) ? defaultColumnWidth : columnWidth!;

  void set columnWid(double colwid) => columnWidth = colwid;

  String toString() {
    return "$columName:$columnWid";
  }
}
