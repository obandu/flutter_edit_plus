part of edit_plus;

class EditplusNuTable extends StatefulWidget {
  final double tableOuterMargin;
  final double? viewPortSize;
  final List<NuTableColumn> tableColumns;
  final List tableRows;

  const EditplusNuTable(
      {super.key,
      required this.tableOuterMargin,
      this.viewPortSize,
      required this.tableColumns,
      required this.tableRows});

  @override
  State<StatefulWidget> createState() => EditplusNuTableState();
}

class EditplusNuTableState extends State<EditplusNuTable> {
  ScrollController tableWidthScrollController = ScrollController();
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
    print("The widths are screen: $screenWidth and viewport $tableWidth");
    return Padding(
      padding: EdgeInsets.all(widget.tableOuterMargin),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        (screenWidth < tableWidth) ? getLeftScroller() : Container(),
        Expanded(
          flex: 1,
          child: getTableArea(),
        ),
        (screenWidth < tableWidth) ? getRightScroller() : Container(),
      ]),
    );
  }

  Widget getTableArea() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: tableWidthScrollController,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: min(tableWidth, screenWidth)),
        child: Column(children: [
          SizedBox(
            height: 3,
          ),
          NuTableHeader(
              tableColumns: widget.tableColumns, tableWidth: tableWidth),
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: ScrollController(),
              child: NuTableBody())
        ]),
      ),
    );
  }

  Widget getLeftScroller() {
    return ElevatedButton.icon(
      onPressed: () {
        tableWidthScrollOffset =
            (tableWidthScrollOffset > 0) ? (tableWidthScrollOffset - 50.0) : 0;
        tableWidthScrollController.jumpTo(
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
        ScrollPosition scrollPosition =
            tableWidthScrollController.positions.first;
        double maxScrollExtent = scrollPosition.maxScrollExtent;
        tableWidthScrollOffset = (tableWidthScrollOffset < maxScrollExtent)
            ? (tableWidthScrollOffset +
                min(
                  50.0,
                  (maxScrollExtent - tableWidthScrollOffset),
                ))
            : maxScrollExtent;
        tableWidthScrollController.jumpTo(
          tableWidthScrollOffset,
        ); // .animateTo(tableWidthScrollOffset, duration: Duration(seconds: 1), curve: Curves);
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
