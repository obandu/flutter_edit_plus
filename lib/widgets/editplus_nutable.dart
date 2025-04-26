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
  // final List<EditplusNuTableColumn> tableColumns;
  final List<String> tableColumnNames;
  final Map<String, String> tableColumnLabels;
  Map<String, double>? columnWidths;
  double? columnSpacing;
  Map<String, dynamic>? columnsWithAlignments;

  // table rows
  final List<Map> tableRowContent;

  List<Color> bandedRows = [Colors.white, Colors.orangeAccent];
  final Widget? tableTitle;

  Function? refreshTableFunction;
  Function? showMessageFunction;

  EditplusNuTable(
      {super.key,
      required this.tableOuterMargin,
      required this.viewPortWidth,
      this.viewPortHeight,
      // required this.tableColumns,
      required this.tableColumnLabels,
      required this.tableColumnNames,
      this.columnWidths,
      this.columnsWithAlignments,
      required this.tableRowContent,
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
  late double tableWidth;
  Widget tableTitle = Text("UNNAMED TABLE");

  // table columns
  List<EditplusNuTableColumn> tableColumns = [];
  final double minTableColumnHeaderHeight = 40;
  final double defaultColumnWidth = 160;

  // pagination and display
  int currentDisplayPage = 0;
  int preferredDisplayPageSize = 20;
  int displayPageSize = 20;
  int _calculatedPages = 1;

  // table rows
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

    // 1. CREATE COLUMNS
    tableColumns = makeTableColumns(
        columnsWithAlignment: widget.columnsWithAlignments,
        tableColumnLabels: widget.tableColumnLabels,
        tableColumnNames: widget.tableColumnNames);

    // set default table width to be based on default column width
    minTableWidth = (tableColumns.length * defaultColumnWidth) +
        (tableColumns.length * widget.tableInnerMargin);

    // 2. SET TABLE AND COLUMN WIDTHS
    setTableWidthAndColumnSizes();

    // Set table title
    if (widget.tableTitle != null) {
      tableTitle = widget.tableTitle!;
    }

    // page preparation
    // initialise page size
    currentDisplayPage = 0;
    determinePagination();

    // print("Display page size at init is ${displayPageSize} and calculated pages is ${_calculatedPages} and num rows is ${widget.tableRows.length}");
    print(
        "Column wids at init =  tableWidth = $tableWidth and minimum is $minTableWidth, viewport width = ${widget.viewPortWidth} and columns are ${tableColumns}");

    // initialise the display matrix
    // generate the text editing controllers
    textEditingControllers = List.generate(
        (displayPageSize * tableColumns.length),
        (index) => TextEditingController());

    // generate the text form fields
    textFormFields = List.generate(
        (displayPageSize * tableColumns.length),
        (index) => TextFormField(
            enabled: false,
            maxLines: null,
            textAlign: getTextAlign(
                tableColumns[index % tableColumns.length].contentAlignment),
            controller: textEditingControllers[index],
            decoration: getTableCellDecoration()));

    createVisualTableRows();
  }

  void setTableWidthAndColumnSizes() {
    // initialise table width to zero
    tableWidth = 0;

    // initialise table widths
    if (widget.columnWidths == null) {
      tableWidth = minTableWidth;
      print(
          "No column widths given so We use default column widths to a total of ${tableWidth}");
    } else {
      print(
          "Mismatch in number of column widths and labels given so we use mixed column widths on the labels");
      for (EditplusNuTableColumn column in tableColumns) {
        String columnName = column.columnName;
        double? givenColumnWidth = widget.columnWidths![columnName];
        if (givenColumnWidth == null) {
          tableWidth += defaultColumnWidth; //  + widget.tableInnerMargin);
          column.columnWid = defaultColumnWidth;
        } else {
          column.columnWid = givenColumnWidth;
          tableWidth += givenColumnWidth!; //  + widget.tableInnerMargin);
        }
      }
    }

    // if space occupied by table is too small, expand it to fill initial viewport size
    double nutableWidth = 0;
    if (tableWidth < widget.viewPortWidth) {
      double expandSize =
          (widget.viewPortWidth - tableWidth) / tableColumns.length;

      int countcolumnwid = 0;
      for (int i = 0; i < tableColumns.length; i++) {
        tableColumns[i].columnWid = (tableColumns[i].columnWid + expandSize);
        nutableWidth += tableColumns[i].columnWid;
      }

      tableWidth = max(minTableWidth, nutableWidth);
    }
  }

  void determinePagination() {
    // determine the display page size
    if (widget.tableRowContent.length > 0) {
      displayPageSize =
          min(preferredDisplayPageSize, widget.tableRowContent.length);
    }

    _calculatedPages = (widget.tableRowContent.length ~/ displayPageSize);

    if ((widget.tableRowContent.length % displayPageSize) >= 1) {
      _calculatedPages += 1;
    }

    // reset current page to zero if number of total records changes without table recreation(EDGE CASE)
  }

  @mustCallSuper
  @protected
  void didUpdateWidget(covariant EditplusNuTable oldWidget) {
    print(
        "\n ....Widget is updated ..... and new width is ${widget.viewPortWidth} and tablewidth is ${tableWidth}\n");
    // currentDisplayPage = 0;

    setTableWidthAndColumnSizes();

    createVisualTableRows();
  }

  @override
  Widget build(BuildContext context) {
    if (buildErrorCondition == true) {
      return Text("We have an error condition ${buildErrorsFound}");
    }

    // determinePageSize();
    print(
        "At build - The widths are screen:  and tableWidth $tableWidth and viewportwidth ${widget.viewPortWidth}");
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
            child: (tableWidth > widget.viewPortWidth)
                ? getLeftScroller()
                : Container(),
          ),
          Expanded(
            flex: 1,
            child: getPageScroller(),
          ),
          Expanded(
            child: (tableWidth > widget.viewPortWidth)
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
              minWidth: tableWidth, minHeight: minTableColumnHeaderHeight),
          child: NuTableHeader(
            tableColumns: tableColumns,
            tableWidth: tableWidth,
            columnSpacing: widget.tableInnerMargin,
          ),
        ));
  }

  Widget getTableBodyRows() {
    var pageRows = <Map>[];

    int lastIndex = 0;

    if (widget.tableRowContent.length >= 1) {
      lastIndex = min(widget.tableRowContent.length - 1,
          ((currentDisplayPage * displayPageSize) + displayPageSize) - 1);
      pageRows = widget.tableRowContent
          .sublist((currentDisplayPage * displayPageSize), lastIndex + 1);
    }

    // print("Page rows are from ${(currentDisplayPage * displayPageSize)} to ${lastIndex} and table length is ${widget.tableRows.length} and dp size is ${displayPageSize}");

    updateTableRowsContent(pageRows);

    // print("First page row in this group is ${pageRows.first}");
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: tableBodyWidthScrollController,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: tableWidth,
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
    // add text fields to rows
    var inTableRows = <Row>[];
    var inColumnWids = [];
    var widgetsForRow = <Widget>[];
    int widgetCount = 0;
    int tableColumnIndex = 0;
    for (TextFormField tff in textFormFields) {
      tableColumnIndex = widgetCount % tableColumns.length;

      if (widgetCount > 0 && tableColumnIndex == 0) {
        inTableRows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgetsForRow,
        ));
        widgetsForRow = <Widget>[];
      }

      if (widgetCount ~/ tableColumns.length == 0) {
        inColumnWids.add(tableColumns[tableColumnIndex].columnWid);
      }

      widgetsForRow.add(SizedBox(
          width: (tableColumns[tableColumnIndex].columnWid), child: tff));
      textEditingControllers[widgetCount].text = widgetCount.toString();
      widgetsForRow.add(SizedBox(width: widget.tableInnerMargin));

      widgetCount += 1;
    }

    if (widgetsForRow.length >= 2) {
      widgetsForRow.removeLast();
    }

    inTableRows.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgetsForRow,
    ));

    int rowNumber = 0;
    int numColors = (widget.bandedRows?.length ?? 0);
    Color rowColor = Colors.white;

    List<Widget> tableRows = [];
    for (Row inRow in inTableRows) {
      if (widget.bandedRows != null && numColors >= 2) {
        rowColor = widget.bandedRows![rowNumber % numColors];
      }

      tableRows.add(Container(
          // padding: EdgeInsets.all(1.0),
          decoration: BoxDecoration(color: rowColor),
          child: inRow));
      tableRows.add(SizedBox(height: widget.tableInnerMargin));

      rowNumber += 1;
    }

    visualTableRows = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tableRows,
    );
    print("At visualisation, Column wids = and Incolumnwids = ${inColumnWids}");
    // print("The columns are ${widget.tableColumns.length} and total, page size is ${displayPageSize} fields are ${textFormFields.length} and rows are ${tableRows.length}");
  }

  void updateTableRowsContent(var pageRows) {
    // print("Update of visual table requested ...., page size is ${displayPageSize} and number of records is ${pageRows.length} ");

    // clear all text editing controllers (make empty)
    for (TextEditingController tec in textEditingControllers) {
      tec.text = "";
    }

    int countRow = 0;
    for (var tableRowContent in pageRows) {
      int countCol = 0;
      for (var tableColumn in tableColumns) {
        int index = (tableColumns.length * countRow) + countCol;

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
            widget.tableRowContent,
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

  // FOR EXPORT
  List<String> getColumnNamesAsList() {
    var columnNames = <String>[];

    for (var tableColumn in tableColumns) {
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
          columnWidth: defaultColumnWidth,
          columnLabel: tableColumnLabels[columnName] ?? columnName,
          contentAlignment: columnsWithAlignment?[columnName]));
    }

    print("The column alignmens are ${columnsWithAlignment}");

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
      contentPadding: EdgeInsets.all(3),
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
