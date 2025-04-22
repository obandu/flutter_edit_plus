part of edit_plus;

class EditplusNuTable extends StatefulWidget {
  // viewport definitions
  double viewPortWidth;
  final double? viewPortHeight;

  // general table dimensions
  final double tableOuterMargin;
  final double tableInnerMargin = 3;
  double? rowSpacing;

  // table column headers and dimensions
  final List<EditplusNuTableColumn> tableColumns;
  final List<String> tableColumnNames;
  final Map<String, String> tableColumnLabels;
  Map<String, double>? columnWidths;
  double? columnSpacing;
  Map<String, dynamic>? columnsWithAlignments;

  // table rows
  final List<Map> tableRows;

  List<Color> bandedRows = [Colors.white, Colors.orangeAccent];
  final Widget? tableTitle;

  Function? refreshTableFunction;
  Function? showMessageFunction;

  EditplusNuTable(
      {super.key,
      required this.tableOuterMargin,
      required this.viewPortWidth,
      this.viewPortHeight,
      required this.tableColumns,
      required this.tableColumnLabels,
      required this.tableColumnNames,
      this.columnWidths,
      this.columnsWithAlignments,
      required this.tableRows,
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

  // dimensions
  final double widthScrollOffsetInterval = 50.0;
  final double minTableHeight = 200;
  double minTableWidth = 600;
  double minColumnWidth = 160;
  late double screenWidth;
  late double tableWidth;
  Widget tableTitle = Text("UNNAMED TABLE");

  // table columns
  List<EditplusNuTableColumn> tableColumns = [];
  List columnWidths = [];
  final double minTableColumnHeaderHeight = 40;

  // pagination and display
  int currentDisplayPage = 0;
  int preferredDisplayPageSize = 20;
  int displayPageSize = 20;
  int _calculatedPages = 1;

  // table rows
  List<Widget> tableRows = [];
  List<TextEditingController> textEditingControllers = [];
  List<TextFormField> textFormFields = [];
  late Column visualTableRows;

  // exception handling
  bool buildErrorCondition = false;
  List<String> buildErrorsFound = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("\n ....Widget is initialised ..... \n");

    buildErrorCondition = false;
    buildErrorsFound = [];

    // start by making the columns
    tableColumns = makeTableColumns(
        columnsWithAlignment: widget.columnsWithAlignments,
        tableColumnLabels: widget.tableColumnLabels,
        tableColumnNames: widget.tableColumnNames);

    minTableWidth = (tableColumns.length * minColumnWidth) +
        (tableColumns.length * widget.tableInnerMargin);
    tableWidth = 0;

    List<double> buildColumnWidths = [];
    if (widget.columnWidths == null) {
      print("No column widths given so We use default column widths");
    } else {
      //  if (widget.columnWidths?.length >= 1 && (widget.columnWidths?.length != widget.tableColumnLabels.length)) {
      print(
          "Mismatch in number of column widths and labels given so we use mixed column widths on the labels");
      // buildErrorsFound.add("Mismatch in number of column widths and labels given so we use mixed column widths on the labels");
      for (EditplusNuTableColumn column in widget.tableColumns) {
        String columnName = column.columnName;

        if (widget.columnWidths != null) {
          // there exists a given column width for column name
          double? givenColumnWidth = widget.columnWidths![columnName];
          if (givenColumnWidth == null) {
            if (column.columnWid == null) {
              tableWidth += (minColumnWidth + widget.tableInnerMargin);
            } else {
              tableWidth += (column.columnWid + widget.tableInnerMargin);
            }
          } else {
            column.columnWid = givenColumnWidth;
            tableWidth += givenColumnWidth!;
          }
        } else {
          if (column.columnWid == null) {
            tableWidth += (minColumnWidth + widget.tableInnerMargin);
          } else {
            tableWidth += (column.columnWid + widget.tableInnerMargin);
          }
        }
      }
    }

    // if space occupied by table is too small, expand it to fill initial viewport size
    columnWidths = [];
    double nutableWidth = 0;
    if (tableWidth < widget.viewPortWidth) {
      double expandSize =
          (widget.viewPortWidth - tableWidth) / widget.tableColumns.length;

      int countcolumnwid = 0;
      for (int i = 0; i < widget.tableColumns.length; i++) {
        widget.tableColumns[i].columnWid =
            (widget.tableColumns[i].columnWid + expandSize);
        columnWidths.add(widget.tableColumns[i].columnWid);
        nutableWidth += widget.tableColumns[i].columnWid;
      }
    }

    tableWidth = nutableWidth;

    tableWidth = max(minTableWidth, tableWidth);
    screenWidth = widget.viewPortWidth;

    if (widget.tableTitle != null) {
      tableTitle = widget.tableTitle!;
    }

    // page preparation
    // initialise page size
    currentDisplayPage = 0;
    determinePageSize();

    // print("Display page size at init is ${displayPageSize} and calculated pages is ${_calculatedPages} and num rows is ${widget.tableRows.length}");
    print(
        "Column wids at init = ${columnWidths}, tableWidth = $tableWidth and minimum is $minTableWidth, viewport width = ${widget.viewPortWidth} and columns are ${widget.tableColumns}");

    // initialise the display matrix
    // build display matrix
    createVisualTableRows();
  }

  void determinePageSize() {
    // determine the display page size
    if (widget.tableRows.length > 0) {
      displayPageSize = min(preferredDisplayPageSize, widget.tableRows.length);
    }

    _calculatedPages = (widget.tableRows.length ~/ displayPageSize);

    if ((widget.tableRows.length % displayPageSize) >= 1) {
      _calculatedPages += 1;
    }

    // reset current page to zero if number of total records changes without table recreation(EDGE CASE)
  }

  @mustCallSuper
  @protected
  void didUpdateWidget(covariant EditplusNuTable oldWidget) {
    print("\n ....Widget is updated ..... \n");
    currentDisplayPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (buildErrorCondition == true) {
      return Text("We have an error condition ${buildErrorsFound}");
    }

    screenWidth = MediaQuery.sizeOf(context).width;
    determinePageSize();
    print(
        "At build - The widths are screen: $screenWidth and tableWidth $tableWidth and viewportwidth ${widget.viewPortWidth}");
    return Padding(
      padding: EdgeInsets.all(widget.tableOuterMargin),
      child: SingleChildScrollView(
          child: Column(children: [
        Divider(),
        Row(children: [
          Expanded(
            flex: 1,
            child: tableTitle,
          ),
          Row(
            children: getHeaderActionButtons(),
          )
        ]),
        SizedBox(
          height: widget.tableOuterMargin,
        ),
        Divider(),
        Row(children: [
          Expanded(
            child: (tableWidth >
                    widget
                        .viewPortWidth) // (screenWidth < tableWidth + widthScrollOffsetInterval)
                ? getLeftScroller()
                : Container(),
          ),
          Expanded(
            flex: 1,
            child: getPageScroller(),
          ),
          Expanded(
            child: (tableWidth >
                    widget
                        .viewPortWidth) // (screenWidth < tableWidth + widthScrollOffsetInterval)
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
        Divider(),
        Row(
          children: [],
        ),
        Divider(),
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
            tableColumns: widget.tableColumns,
            tableWidth: tableWidth,
            columnSpacing: widget.tableInnerMargin,
          ),
        ));
  }

  Widget getTableBodyRows() {
    var pageRows = <Map>[];

    int lastIndex = 0;

    if (widget.tableRows.length >= 1) {
      lastIndex = min(widget.tableRows.length - 1,
          ((currentDisplayPage * displayPageSize) + displayPageSize) - 1);
      pageRows = widget.tableRows
          .sublist((currentDisplayPage * displayPageSize), lastIndex + 1);
    }

    // print("Page rows are from ${(currentDisplayPage * displayPageSize)} to ${lastIndex} and table length is ${widget.tableRows.length} and dp size is ${displayPageSize}");

    updateVisualTableRows(pageRows);

    // print("First page row in this group is ${pageRows.first}");
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: tableBodyWidthScrollController,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: min(tableWidth, screenWidth),
                    minHeight: minTableHeight,
                    maxHeight: 400),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: ScrollController(),
                    child: pageRows.isEmpty
                        ? Text("No data for table ..")
                        : visualTableRows))));
  }

  void createVisualTableRows() {
    // generate the text editing controllers
    textEditingControllers = List.generate(
        (displayPageSize * widget.tableColumns.length),
        (index) => TextEditingController());

    // generate the text form fields
    textFormFields = List.generate(
        (displayPageSize * widget.tableColumns.length),
        (index) => TextFormField(
            enabled: false,
            maxLines: null,
            textAlign: getTextAlign(widget
                .tableColumns[index % widget.tableColumns.length]
                .contentAlignment),
            controller: textEditingControllers[index],
            decoration: getTableCellDecoration()));

    // add text fields to rows
    var inTableRows = <Row>[];

    var inColumnWids = [];
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

      if (widgetCount ~/ widget.tableColumns.length == 0) {
        inColumnWids.add(widget.tableColumns[tableColumnIndex].columnWid);
      }

      widgetsForRow.add(SizedBox(
          width: (widget.tableColumns[tableColumnIndex].columnWid -
              widget.tableInnerMargin),
          child: tff));
      textEditingControllers[widgetCount].text = widgetCount.toString();
      widgetsForRow.add(SizedBox(width: widget.tableInnerMargin));

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
          padding: EdgeInsets.all(1.0),
          decoration: BoxDecoration(color: rowColor),
          child: inRow));
      tableRows.add(SizedBox(height: widget.tableInnerMargin));

      rowNumber += 1;
    }

    visualTableRows = Column(
      children: tableRows,
    );
    print(
        "At visualisation, Column wids = ${columnWidths} and Incolumnwids = ${inColumnWids}");
    // print("The columns are ${widget.tableColumns.length} and total, page size is ${displayPageSize} fields are ${textFormFields.length} and rows are ${tableRows.length}");
  }

  void updateVisualTableRows(var pageRows) {
    // print("Update of visual table requested ...., page size is ${displayPageSize} and number of records is ${pageRows.length} ");

    // clear all text editing controllers (make empty)
    for (TextEditingController tec in textEditingControllers) {
      tec.text = "";
    }

    int countRow = 0;
    for (var tableRowContent in pageRows) {
      int countCol = 0;
      for (var tableColumn in widget.tableColumns) {
        int index = (widget.tableColumns.length * countRow) + countCol;

        textEditingControllers[index].text =
            tableRowContent[tableColumn.columnName].toString();
        countCol += 1;
      }
      countRow += 1;
    }
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
          var csvContent = EditPlusUtils.getMapListAsCSV(
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

  List<EditplusNuTableColumn> makeTableColumns(
      {required List<String> tableColumnNames,
      required Map<String, String> tableColumnLabels,
      Map<String, dynamic>? columnsWithAlignment}) {
    List<EditplusNuTableColumn> myTableColumns = [];

    for (String columnName in tableColumnNames) {
      myTableColumns.add(EditplusNuTableColumn(
          columnName: columnName,
          columnLabel: tableColumnLabels[columnName] ?? columnName,
          contentAlignment: columnsWithAlignment?[columnName]));
    }

    return myTableColumns;
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
      return Text("Page ${currentDisplayPage + 1} of $_calculatedPages");
    }

    return Container();
  }

  Widget getPageUp() {
    if (_calculatedPages > 1) {
      return ElevatedButton.icon(
        onPressed: () {
          if (currentDisplayPage - 1 >= 0) {
            currentDisplayPage -= 1;
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
          if (currentDisplayPage + 1 < _calculatedPages) {
            currentDisplayPage += 1;
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

  InputDecoration getTableCellDecoration({String? label, String? hint}) {
    return InputDecoration(
      hintText: hint,
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      labelText: label,
    );
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
