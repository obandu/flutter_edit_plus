part of edit_plus;

class EditplusNuTable extends StatefulWidget {
  final double tableOuterMargin;
  final double? viewPortSize;
  final List<EditplusNuTableColumn> tableColumns;
  final List<Map> tableRows;
  double? rowSpacing;
  double? columnSpacing;
  List<Color> bandedRows = [Colors.white, Colors.orangeAccent];

  EditplusNuTable(
      {super.key,
      required this.tableOuterMargin,
      this.viewPortSize,
      required this.tableColumns,
      required this.tableRows});

  @override
  State<StatefulWidget> createState() => EditplusNuTableState();
}

class EditplusNuTableState extends State<EditplusNuTable> {
  ScrollController tableHeadWidthScrollController = ScrollController(),
      tableBodyWidthScrollController = ScrollController();
  double tableWidthScrollOffset = 0.0;
  late double screenWidth;

  late double tableWidth;
  // late List<NuTableColumn> tableColumns;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    (widget.viewPortSize == null)
        ? tableWidth = 800
        : tableWidth = widget.viewPortSize!;

    screenWidth = tableWidth;
    /*for (var tableColumn in widget.tableColumns) {
      tableColumns.add(NuTableColumn(columnLabel: tableColumn.toString()));
    } */
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    // print("The widths are screen: $screenWidth and viewport $tableWidth");
    return Padding(
      padding: EdgeInsets.all(widget.tableOuterMargin),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          (screenWidth < tableWidth) ? getLeftScroller() : Container(),
          Expanded(
            flex: 1,
            child: getTableHeaderRow(),
          ),
          (screenWidth < tableWidth) ? getRightScroller() : Container(),
        ]),
        /* Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            (screenWidth < tableWidth) ? getLeftScroller() : Container(),
            Expanded(flex: 1, child: getTableBodyRow()),
            (screenWidth < tableWidth) ? getRightScroller() : Container(),
          ]),
        ), */
        Row(children: [
          (screenWidth < tableWidth) ? Container(width: 50) : Container(),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: tableBodyWidthScrollController,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          // minWidth: min(tableWidth, screenWidth),
                          minHeight: 200,
                          maxHeight: 400),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          controller: ScrollController(),
                          child: EditplusNuTableBody(
                            tableColumns: widget.tableColumns,
                            tableRowsContent: widget.tableRows,
                            bandedRowColors: widget.bandedRows,
                          ))))),
          (screenWidth < tableWidth) ? Container(width: 50) : Container(),
        ]),
        Row(
          children: [Text("This is the bottom of the table")],
        )
      ]),
    );
  }

  Widget getTableHeaderRow() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: tableHeadWidthScrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: min(tableWidth, screenWidth)),
          child: NuTableHeader(
              tableColumns: widget.tableColumns, tableWidth: tableWidth),
        ));
  }

  Widget getTableBodyRow() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: tableBodyWidthScrollController,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: min(tableWidth, screenWidth),
                minHeight: 200,
                maxHeight: 400),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: ScrollController(),
                child: SizedBox(
                    height: 400,
                    // constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
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
        tableWidthScrollOffset =
            (tableWidthScrollOffset > 0) ? (tableWidthScrollOffset - 50.0) : 0;
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
                  50.0,
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
}
