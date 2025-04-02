part of edit_plus;

class EditplusNuTableBody extends StatelessWidget {
  final List<EditplusNuTableColumn> tableColumns;
  final List<Map> tableRowsContent;
  List<Color>? bandedRowColors;

  EditplusNuTableBody(
      {required this.tableRowsContent,
      required this.tableColumns,
      this.bandedRowColors});

  @override
  Widget build(BuildContext context) {
    var tableRows = <Widget>[];
    int rowNumber = 0;
    int numColors = (bandedRowColors?.length ?? 0);
    Color rowColor = Colors.white;
    for (var tableRowContent in tableRowsContent) {
      var tableRowWidgets = <Widget>[];
      if (bandedRowColors != null && numColors >= 2) {
        rowColor = bandedRowColors![rowNumber % numColors];
      }
      for (var tableColumn in tableColumns) {
        tableRowWidgets.add(Container(
            padding: EdgeInsets.all(3.0),
            color: rowColor,
            width: tableColumn.columnWidth,
            child: TextFormField(
              enabled: false,
              initialValue: tableRowContent[tableColumn.columnName].toString(),
              decoration: EditPlusUiUtils.getFormTextFieldDecoration(),
              textAlign: getTextAlign(tableColumn.contentAlignment),
            )));
        tableRowWidgets.add(SizedBox(width: 3));
      }
      tableRows.add(Row(
        children: tableRowWidgets,
      ));
      tableRows.add(SizedBox(height: 3));
      rowNumber += 1;
    }

    return Column(
      children: tableRows,
    );
  }

  TextAlign getTextAlign(var alignment) {
    if (alignment == null) {
      return TextAlign.start;
    }

    /*if (alignment.toString().toUpperCase() == "RIGHT") {
      return TextAlign.end;
    } */

    return alignment;
  }
}
