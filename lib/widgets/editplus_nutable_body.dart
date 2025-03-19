part of edit_plus;

class EditplusNuTableBody extends StatelessWidget {
  final List<EditplusNuTableColumn> tableColumns;
  final List<Map> tableRowsContent;

  const EditplusNuTableBody(
      {required this.tableRowsContent, required this.tableColumns});

  @override
  Widget build(BuildContext context) {
    var tableRows = <Widget>[];
    for (var tableRowContent in tableRowsContent) {
      var tableRowWidgets = <Widget>[];
      for (var tableColumn in tableColumns) {
        tableRowWidgets.add(SizedBox(
            width: tableColumn.columnWidth,
            child: Text(tableRowContent[tableColumn.columnName])));
        tableRowWidgets.add(SizedBox(width: 3));
      }
      tableRows.add(Row(
        children: tableRowWidgets,
      ));
      tableRows.add(SizedBox(height: 3));
    }

    return Column(
      children: tableRows,
    );
  }
}
