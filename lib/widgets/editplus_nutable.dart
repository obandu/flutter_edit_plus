part of edit_plus;

class EditplusNuTable extends StatefulWidget {
  final double tableOuterMargin;
  double viewPortWidth;
  final double? viewPortHeight;
  final List<EditplusNuTableColumn> tableColumns;
  final List<Map> tableRows;
  double? rowSpacing;
  double? columnSpacing;
  List<Color> bandedRows = [Colors.white, Colors.orangeAccent];
  final Widget? tableTitle;

  Function? refreshTableFunction;
  Function? showMessageFunction;

  EditplusNuTable(
      {super.key,
      required this.tableOuterMargin,
      required this.tableColumns,
      required this.tableRows,
      required this.viewPortWidth,
      this.viewPortHeight,
      this.tableTitle,
      this.refreshTableFunction,
      this.showMessageFunction});

  @override
  State<StatefulWidget> createState() => EditplusNuTableState();
}

class EditplusNuTableState extends State<EditplusNuTable> {
  ScrollController tableHeadWidthScrollController = ScrollController(),
      tableBodyWidthScrollController = ScrollController();
  double tableWidthScrollOffset = 0.0;
  final double widthScrollOffsetInterval = 50.0;
  final double minTableHeight = 200;
  final double minTableWidth = 600;
  final double minTableColumnHeaderHeight = 40;
  late double screenWidth;
  late double tableWidth;
  Widget tableTitle = Text("UNNAMED TABLE");
  // late List<NuTableColumn> tableColumns;

  int page = 0;
  int displayPageSize = 20;
  int _calculatedPages = 1;

  // table rows
  List<Widget> tableRows = [];
  List<TextEditingController> textEditingControllers = [];
  List<TextFormField> textFormFields = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tableWidth = 0;

    for (EditplusNuTableColumn column in widget.tableColumns) {
      if (column.columnWidth == null) {
        tableWidth += (column.defaultColumnWidth + widget.tableOuterMargin);
      } else {
        tableWidth += (column.columnWidth! + widget.tableOuterMargin);
      }
    }

    tableWidth = max(minTableWidth, tableWidth);

    screenWidth = widget.viewPortWidth;

    if (widget.tableTitle != null) {
      tableTitle = widget.tableTitle!;
    }

    _calculatedPages = (widget.tableRows.length ~/ displayPageSize) + 1;

    // initialise the display matrix
    // build display matrix
    createTableVisualFields();

    /*for (var tableColumn in widget.tableColumns) {
      tableColumns.add(NuTableColumn(columnLabel: tableColumn.toString()));
    } */
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    // print("The widths are screen: $screenWidth and tableWidth $tableWidth");
    return Padding(
      padding: EdgeInsets.all(widget.tableOuterMargin),
      child: SingleChildScrollView(
          child: Column(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: tableTitle,
          ),
          Row(
            children: getHeaderActionButtons(),
          )
        ]),
        Row(children: [
          Expanded(
            child: (screenWidth < tableWidth + widthScrollOffsetInterval)
                ? getLeftScroller()
                : Container(),
          ),
          Expanded(
            flex: 1,
            child: getPageScroller(),
          ),
          Expanded(
            child: (screenWidth < tableWidth + widthScrollOffsetInterval)
                ? getRightScroller()
                : Container(),
          ),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 1,
            child: getTableHeaderRow(),
          ),
        ]),
        Row(children: [
          getTableBodyRows(),
        ]),
        Row(
          children: [Text("This is the bottom of the table")],
        )
      ])),
    );
  }

  Widget getTableHeaderRow() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: tableHeadWidthScrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: min(tableWidth, screenWidth),
              minHeight: minTableColumnHeaderHeight),
          child: NuTableHeader(
              tableColumns: widget.tableColumns, tableWidth: tableWidth),
        ));
  }

  Widget getTableBodyRows() {
    var pageRows = <Map>[];
    if (widget.tableRows.length >= 1) {
      int lastindex = min(widget.tableRows.length - 1,
          ((page * displayPageSize) + displayPageSize) - 1);
      pageRows = widget.tableRows.sublist((page * displayPageSize), lastindex);
    }
    // print("Page rows are from ${(page * displayPageSize)} to $lastindex and table length is ${widget.tableRows.length}");

    // print("First page row in this group is ${pageRows.first}");
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: tableBodyWidthScrollController,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    // minWidth: min(tableWidth, screenWidth),
                    minHeight: minTableHeight,
                    maxHeight: 400),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: ScrollController(),
                    child: pageRows.isEmpty
                        ? Text("No data for table ..")
                        : createTableVisualFields()))));
  }

  // getTablePageRows(pageRows)

  /*Widget getTablePageRowsA(var pageRows) {
    tableRows = <Row>[];

    for (int i = 0; i < displayPageSize; i++) {
      List<Widget> tableContent = [];
      for (var tableColumn in widget.tableColumns) {
        tableContent.add(Text(tableColumn.columnLabel));
      }
      tableRows.add(Row(children: tableContent));
    }
    return Column(
      children: tableRows,
    );
  } */

  createTableVisualFields() {
    // generate the text editing controllers
    textEditingControllers = List.generate(
        (displayPageSize * widget.tableColumns.length),
        (index) => TextEditingController());

    // generate the text form fields
    textFormFields = List.generate(
        (displayPageSize * widget.tableColumns.length),
        (index) => TextFormField(
            enabled: false,
            controller: textEditingControllers[index],
            decoration: EditPlusUiUtils.getFormTextFieldDecoration()));

    // add text fields to rows
    var inTableRows = <Row>[];

    var widgetsForRow = <Widget>[];
    int widgetCount = 0;
    int tableColumnIndex = 0;
    for (TextFormField tff in textFormFields) {
      tableColumnIndex = widgetCount % widget.tableColumns.length;

      if (widgetCount > 0 && tableColumnIndex == 0) {
        inTableRows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgetsForRow,
        ));
        widgetsForRow = <Widget>[];
      }

      widgetsForRow.add(SizedBox(
          width: widget.tableColumns[tableColumnIndex].columnWid, child: tff));
      textEditingControllers[widgetCount].text = widgetCount.toString();
      widgetsForRow.add(SizedBox(width: widget.tableOuterMargin));

      widgetCount += 1;
    }

    inTableRows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgetsForRow,
    ));

    int rowNumber = 0;
    int numColors = (widget.bandedRows?.length ?? 0);
    Color rowColor = Colors.white;

    for (Row inRow in inTableRows) {
      if (widget.bandedRows != null && numColors >= 2) {
        rowColor = widget.bandedRows![rowNumber % numColors];
      }

      tableRows.add(Container(
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(color: rowColor),
          child: inRow));
      tableRows.add(SizedBox(height: widget.tableOuterMargin));

      rowNumber += 1;
    }

    print(
        "The columns are ${widget.tableColumns.length} and total fields are ${textFormFields.length} and rows are ${tableRows.length}");
    return Column(
      children: tableRows,
    );
  }

  Widget getTablePageRows(var pageRows) {
    var tableRows = <Widget>[];
    int rowNumber = 0;
    int numColors = (widget.bandedRows?.length ?? 0);
    Color rowColor = Colors.white;
    // print("First page row during Rendering is ${pageRows.first} and colwid = ${widget.tableColumns.first.columnWid.toString()}");
    for (var tableRowContent in pageRows) {
      var tableRowWidgets = <Widget>[];
      if (widget.bandedRows != null && numColors >= 2) {
        rowColor = widget.bandedRows![rowNumber % numColors];
      }
      int colNumber = 0;
      for (var tableColumn in widget.tableColumns) {
        tableRowWidgets.add(SizedBox(
            width: tableColumn.columnWid,
            child: TextFormField(
              initialValue: tableRowContent[tableColumn.columnName].toString(),
              enabled: false,
              // initialValue: tableRowContent[tableColumn.columnName].toString(),
              decoration: EditPlusUiUtils.getFormTextFieldDecoration(),
              textAlign: getTextAlign(tableColumn.contentAlignment),
            )));
        tableRowWidgets.add(SizedBox(width: 3));
        colNumber += 1;
      }
      tableRows.add(Container(
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(color: rowColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tableRowWidgets,
          )));
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

  Widget getLeftScroller() {
    return Row(children: [
      ElevatedButton.icon(
        onPressed: () {
          tableWidthScrollOffset = (tableWidthScrollOffset > 0)
              ? (tableWidthScrollOffset - widthScrollOffsetInterval)
              : 0;
          tableHeadWidthScrollController.jumpTo(
            tableWidthScrollOffset,
          );
          tableBodyWidthScrollController.jumpTo(
            tableWidthScrollOffset,
          );
        },
        icon: Icon(Icons.arrow_left_sharp),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
        label: Container(),
      )
    ]);
  }

  Widget getRightScroller() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton.icon(
        onPressed: () {
          // get maxScrollExtent
          ScrollPosition tableHeadScrollPosition =
              tableHeadWidthScrollController.positions.first;
          ScrollPosition tableBodyScrollPosition =
              tableHeadWidthScrollController.positions.first;

          double maxScrollExtent = tableHeadScrollPosition.maxScrollExtent;
          tableWidthScrollOffset = (tableWidthScrollOffset < maxScrollExtent)
              ? (tableWidthScrollOffset +
                  min(
                    widthScrollOffsetInterval,
                    (maxScrollExtent - tableWidthScrollOffset),
                  ))
              : maxScrollExtent;
          tableHeadWidthScrollController.jumpTo(
            tableWidthScrollOffset,
          );
          tableBodyWidthScrollController.jumpTo(
            tableWidthScrollOffset,
          );
          // .animateTo(tableWidthScrollOffset, duration: Duration(seconds: 1), curve: Curves);
          // widget.showMessageFunction("Table width is ${tableWidthScrollController.positions} EXTENT $maxScrollExtent");
        },
        icon: Icon(Icons.arrow_right_sharp),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
        label: Container(),
      )
    ]);
  }

  List<Widget> getHeaderActionButtons() {
    List<Widget> buttonList = [];

    // the refresh button
    if (widget.refreshTableFunction != null) {
      buttonList.add(
        ElevatedButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            // cannot refresh if in editing mode
            if (getCreateState() == false && getEditState() == false) {
              /*widget.tableDataContent.clear();
              widget.tableDataContent.addAll(widget.refreshTableFunction!());
              setState(() {
                
              }); */
              // widget.showMessageFunction!("The refresh feature is currently under enhancement. It should work in future versions.");
            } else {
              // widget.showMessageFunction("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
              // widget.showMessageFunction!("The table is currently in an edit state. Cannot refresh it.");
            }
          },
        ),
      );
      buttonList.add(SizedBox(
        width: 3,
      ));
    }

    // the csv export button
    buttonList.add(
      ElevatedButton(
        child: Icon(Icons.copy_all_outlined),
        onPressed: () {
          // get table as CSV
          var csvContent = EditPlusUtils.getTableListAsCSV(
            widget.tableRows,
            getColumnNamesAsList(),
          );
          // cannot refresh if in editing mode
          if (getCreateState() == false && getEditState() == false) {
            _copyToClipboard(csvContent);
          } else {
            // widget.showMessageFunction!("Error on clipboard copy attemtp. What is wrong?"); // widget.showMessageFunction("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
          }
        },
      ),
    );

    buttonList.add(SizedBox(
      width: 3,
    ));

    return buttonList;
  }

  // copy to clipboard and alert
  Future<void> _copyToClipboard(var csvContent) async {
    await Clipboard.setData(ClipboardData(text: csvContent));
    if (widget.showMessageFunction != null) {
      widget.showMessageFunction!("FULL TABLE DATA COPIED TO CLIPBOARD");
    }
  }

  bool getCreateState() {
    return false;
  }

  bool getEditState() {
    return false;
  }

  List<String> getColumnNamesAsList() {
    var columnNames = <String>[];

    for (var tableColumn in widget.tableColumns) {
      columnNames.add(tableColumn.columnName);
    }

    return columnNames;
  }

  Widget getPageScroller() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      getPageUp(),
      SizedBox(width: 5),
      getPageNumbersLabel(),
      SizedBox(width: 5),
      getPageDown(),
    ]);
  }

  Widget getPageNumbersLabel() {
    if (_calculatedPages > 1) {
      return Text("Page ${page + 1} of $_calculatedPages");
    }

    return Container();
  }

  Widget getPageUp() {
    if (_calculatedPages > 1) {
      return ElevatedButton.icon(
        onPressed: () {
          if (page - 1 >= 0) {
            page = page - 1;
          }
          setState(() {});
        },
        icon: Icon(Icons.arrow_upward_rounded),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
        label: Container(),
      );
    }

    return Container();
  }

  Widget getPageDown() {
    if (_calculatedPages > 1) {
      return ElevatedButton.icon(
        onPressed: () {
          if (page + 1 < _calculatedPages) {
            page = page + 1;
          }
          setState(() {});
        },
        icon: Icon(Icons.arrow_downward_sharp),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
        label: Container(),
      );
    }

    return Container();
  }

/* List getOtherActionButtons() {
    List<Widget> buttonList = [];
    bool creatingRow = widget.tableEditStatus['CREATINGROW'] == null
        ? false
        : widget.tableEditStatus['CREATINGROW'];
    // var editingRow = widget.tableEditStatus['EDITINGROW'] == null ? false : widget.tableEditStatus['EDITINGROW'];

    // the refresh button
    if (widget.refreshTableFunction != null) {
      buttonList.add(
        ElevatedButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            // cannot refresh if in editing mode
            if (getCreateState() == false && getEditState() == false) {
              /*widget.tableDataContent.clear();
              widget.tableDataContent.addAll(widget.refreshTableFunction!());
              setState(() {
                
              }); */
              // widget.showMessageFunction!("The refresh feature is currently under enhancement. It should work in future versions.");
            } else {
              // widget.showMessageFunction("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
              // widget.showMessageFunction!("The table is currently in an edit state. Cannot refresh it.");
            }
          },
        ),
      );
    }

    // the csv export button
    buttonList.add(
      ElevatedButton(
        child: Icon(Icons.copy_all_outlined),
        onPressed: () {
          // get table as CSV
          var csvContent = EditPlusUtils.getTableListAsCSV(
            widget.tableDataContent,
            widget.columnNames,
          );
          // cannot refresh if in editing mode
          if (getCreateState() == false && getEditState() == false) {
            _copyToClipboard(csvContent);
          } else {
            // widget.showMessageFunction!("Error on clipboard copy attemtp. What is wrong?"); // widget.showMessageFunction("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
          }
        },
      ),
    );

    // the add row/cancel button
    if (widget.tableEditable == true && widget.tableExtensible == true) {
      buttonList.add(
        ElevatedButton(
          child: creatingRow == false
              ? const Icon(Icons.add)
              : const Icon(Icons.cancel, color: Colors.red),
          onPressed: () {
            if (creatingRow == true) {
              widget.tableEditStatus['CREATINGROW'] = false;
              dataRows.remove(blankEditRow);
              setState(() {});
            } else if (getCreateState() == false && getEditState() == false) {
              widget.tableEditStatus['CREATINGROW'] = true;
              blankEditRow = makeBlankEditRow();
              setState(() {});
            } else {
              // widget.showMessageFunction("Add states are $getCreateState() and $getEditState() ");
            }
          },
        ),
      );
    }
    if ((widget.tableEditable == true &&
            creatingRow == true &&
            widget.tableExtensible == true) ||
        (widget.tableEditable == true && widget.tableExtensible == false)) {
      buttonList.add(
        ElevatedButton(
          child: const Icon(Icons.save),
          onPressed: () {
            if (getCreateState() == true) {
              // collect data
              // widget.showMessageFunction("Row data is ${widget.tableStatus['NEWBLANKROW'].cells}");
              var savedata = <String, dynamic>{};
              for (DataCell dc in widget.tableEditStatus['NEWBLANKROW'].cells) {
                if (dc.child is TextFormField) {
                  TextFormField tff = dc.child as TextFormField;

                  ValueKey<String> valueKey = tff.key as ValueKey<String>;
                  // valueKey.currentState.validate();

                  TextEditingController? tec = tff.controller;
                  String value = tec!.value.text;
                  if (value.isEmpty) {
                    return;
                  }
                  String valuekey = valueKey.value.toString();
                  int splitpos = valuekey.indexOf(" -");
                  List<String> valkl = valuekey.split('-');
                  valuekey = valkl[0].toString().trim();
                  // widget.showMessageFunction("Cell $splitpos - data is ${valkl[0]} AND value is $value");
                  savedata[valuekey] = value;
                  //  tec.value = TextEditingValue.empty;
                  continue;
                }
              }
              savedata['EDIT_STATE'] = "NEW ROW";

              if (widget.saveRowFunction != null) {
                widget.saveRowFunction!(savedata);
              }
              // widget.showMessageFunction("data to save is $savedata");
            } else {
              // widget.showMessageFunction("saving the whole table ...");
              widget.saveTableFunction!(collectData());
            }
          },
        ),
      );
    }

    return buttonList;
  } */
}
