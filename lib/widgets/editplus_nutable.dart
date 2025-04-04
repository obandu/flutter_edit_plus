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
  int pageSize = 20;
  int _calculatedPages = 1;  

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

    _calculatedPages = (tableRows.length ~/ pageSize) + 1;    
    /*for (var tableColumn in widget.tableColumns) {
      tableColumns.add(NuTableColumn(columnLabel: tableColumn.toString()));
    } */
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    print("The widths are screen: $screenWidth and tableWidth $tableWidth");
    return Padding(
      padding: EdgeInsets.all(widget.tableOuterMargin),
      child: SingleChildScrollView(
          child: Column(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: tableTitle,
          ),
        ]),
        Row(children: [
          (screenWidth < tableWidth + widthScrollOffsetInterval)
              ? getLeftScroller()
              : Container(),
          Expanded(
            flex: 1,
            child: getPageScroller(),
          ),
          (screenWidth < tableWidth + widthScrollOffsetInterval)
              ? getRightScroller()
              : Container(),
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
    int lastindex = min(widget.tableRows.length, (page x pageSize)+pageSize);
    List pageRows = tableRows.subList((page x pageSize), lastindex);
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
                    child: EditplusNuTableBody(
                      tableColumns: widget.tableColumns,
                      tableRowsContent: widget.tableRows,
                      bandedRowColors: widget.bandedRows,
                    )))));
  }

  Widget getTableArea() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: tableBodyWidthScrollController,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: min(tableWidth, screenWidth)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 3,
          ),
          NuTableHeader(
              tableColumns: widget.tableColumns, tableWidth: tableWidth),
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: ScrollController(),
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 200),
                  child: EditplusNuTableBody(
                    tableColumns: widget.tableColumns,
                    tableRowsContent: widget.tableRows,
                    bandedRowColors: widget.bandedRows,
                  )))
        ]),
      ),
    );
  }

  Widget getLeftScroller() {
    return ElevatedButton.icon(
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
    );
  }

  Widget getRightScroller() {
    return ElevatedButton.icon(
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
    );
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

    return buttonList;
  }

  // copy to clipboard and alert
  Future<void> _copyToClipboard(var csvContent) async {
    await Clipboard.setData(ClipboardData(text: csvContent));
    widget.showMessageFunction!("FULL TABLE DATA COPIED TO CLIPBOARD");
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

  Widget getPageScroller()
  {
              getPageUp(),
              SizedBox(width: 5),
              getPageNumbersLabel(),
              SizedBox(width: 5),
              getPageDown(),    
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
