part of edit_plus;

class NuTableHeader extends StatelessWidget {
  final List<EditplusNuTableColumn> tableColumns;
  double? tableWidth;
  double? columnSpacing;

  NuTableHeader(
      {this.tableWidth, required this.tableColumns, this.columnSpacing});

  @override
  Widget build(BuildContext context) {
    List<Widget> columnList = [];
    tableColumns.forEach((tableColumn) {
      columnList.add(tableColumn.getView());
      columnList.add(SizedBox(
        width: 3,
      ));
    });

    if (columnList.length >= 2) {
      columnList.removeLast();
    }

    return Row(
      children: columnList,
    );
  }
}
