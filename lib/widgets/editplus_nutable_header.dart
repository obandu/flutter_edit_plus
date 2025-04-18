part of edit_plus;

class NuTableHeader extends StatelessWidget {
  final List<EditplusNuTableColumn> tableColumns;
  double? tableWidth;
  double? columnSpacing = 3;

  NuTableHeader(
      {this.tableWidth, required this.tableColumns, this.columnSpacing});

  @override
  Widget build(BuildContext context) {
    List<Widget> columnList = [];
    tableColumns.forEach((tableColumn) {
      columnList.add(tableColumn.getView());
      columnList.add(SizedBox(
        width: columnSpacing,
      ));
    });

    if (columnList.length >= 2) {
      columnList.removeLast();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: columnList,
    );
  }
}
