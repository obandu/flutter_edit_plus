part of edit_plus;

class EditPlusDataTable extends StatefulWidget
{
  final List<String> columnNames;
  final List <Map<String, dynamic>> dataRowsSource;
  final String tableName;
  final tableStatus = new Map<String, dynamic>();
  final dataRows = new List<DataRow>();
  final Map persistenceData;
  final Map fieldEditors;
  final String selectOption;
  final bool tableEditable;

  EditPlusDataTable(
    {this.columnNames,
     this.dataRowsSource,
     this.tableName,
     this.persistenceData,
     this.selectOption,
     this.tableEditable,
     this.fieldEditors}
  );

  @override
  State<StatefulWidget> createState() {
    // create Blank Data Row for edit
    var editDataCells = List<DataCell>();
    editDataCells.add(DataCell(Text(" ")));
    for (String columnName in columnNames)
    {
      if (fieldEditors != null)
      {
        if (fieldEditors.containsKey(columnName))
        {
          editDataCells.add(DataCell(fieldEditors[columnName]));
          continue;
        }
      }
       
      editDataCells.add(DataCell(getEditField(columnName)));

    }
    var newDataRow = DataRow(cells: editDataCells);
    tableStatus['NEWBLANKROW'] = newDataRow;
    tableStatus['CREATINGROW'] = false;
    tableStatus['EDITINGROW'] = false;
    return EditPlusDataTableState();
  }

  TextFormField getEditField(String textName)
  {
    return TextFormField
    (
      key: ValueKey(textName),
      decoration: InputDecoration(
        hintText: textName,
        hintStyle: TextStyle(color: Colors.blueAccent),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a $textName';
        }
        return null;
      },
      controller: new TextEditingController(),
    );
  }

  void initLoad()
  {
    if (persistenceData != null)
    {
      print("now calling the initial data ....");
    }
  }
}

class EditPlusDataTableState extends State<EditPlusDataTable>
{
  
  @override
  Widget build(BuildContext context) 
  {
    // create a global key
    final _tableKey = GlobalKey<FormState>();

    // create the header
    var tableHeader = Text(widget.tableName);

    // make the column names widgets
    var tableColumns = List<DataColumn>();

    // Add selection column
    tableColumns.add(
        DataColumn(
            label: Text(
              "  ",
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold
                )
              ),
          ),
      );

    for (String columnName in widget.columnNames)
    {
      tableColumns.add(
        DataColumn(
            label: Text(
              columnName,
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold
                )
              ),
          ),
      );
    }

    // create rows for paginated table
    // var dataRows = SmartDataTableSource(dataSource: widget.dataRows);
    getDataRows(widget.dataRows);


    return Container(
        /*child: PaginatedDataTable(
          key: _tableKey,
          header: tableHeader,
          columns: tableColumns,
          source: dataRows,
          
        ), */

        // color: Colors.lightBlue,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent)
        ),
        margin: new EdgeInsets.all(10.0),
        padding: new EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.tableName),
                ButtonBar(
                  buttonTextTheme: ButtonTextTheme.normal,
                  buttonPadding: EdgeInsets.all(20.0),
                  children: getButtons(),
                ),
              ]
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: BlocConsumer<EditPlusTableBloc, Map<String, dynamic>>(
                      buildWhen: (previous,current) {
                        return true;
                      },
                      builder: (context, smartTableBloc) {

                        // print("data rows = ${smartTableBloc['DATAROWS']}");
                        var dataRowsList = smartTableBloc['DATAROWS'];
                        if (dataRowsList != null)
                        {
                          getDataRows(dataRowsList);
                          /*for (Map dataRowContent in dataRowsList)
                          {
                            var dataCells = List<DataCell>();
                            for (String columnName in widget.columnNames)
                            {
                              dataCells.add(DataCell(Text(dataRowContent[columnName])));
                            }

                            var dataRow = DataRow(
                              cells: dataCells, 
                              // selected: true,
                              onSelectChanged:(tf)
                              {
                                print("('row-selected: ... $tf')");
                                
                              });
                            dataRows.add(dataRow);
                          } */
                        }

                        if (smartTableBloc.containsKey("NEWROWACTION") )
                        {
                          String action = smartTableBloc['NEWROWACTION'];
                          if (action == 'INSERTROW')
                          {
                            print("YES create new row "); // + companyPayments['DISTRIBNEWROW']);
                            // tblrDistribution.add(tblrEditRow);
                            if (widget.tableStatus.containsKey('EDITINGNEWROW'))
                            widget.dataRows.add(widget.tableStatus['NEWBLANKROW']);
                          }
                          if (action == 'SAVEROW')
                          {
                            print("YES create save new row ");// + companyPayments['DISTRIBNEWROW']);
                            // tblrDistribution.remove(tblrEditRow);
                            widget.dataRows.remove(widget.tableStatus['NEWBLANKROW']);
                            widget.tableStatus['EDITINGNEWROW'] = false;
                          }
                        }
                        
                        return DataTable (
                          // headingRowColor: MaterialStateProperty.resolveWith((states) => C),
                          columns : tableColumns,
                          rows: widget.dataRows,
                          dividerThickness: 2,
                          horizontalMargin: 2,
                          showCheckboxColumn: false,
                          /*decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)
                          ), */
                        );
                      },
                      listener: (context, state) {
                        // var currentTime = DateTime.now().toString();
                        // print("SUBSCRIPTIONS DATA is updated $currentTime");
                      },
                    ),
                  ),
                ),
              ]
            )
          ]
        )
      );
    
  }

  List<DataRow> getDataRows(var dataRowsMapList)
  {
    // create DataRows for DataTable rows
    widget.dataRows.clear();
    for (Map dataRowContent in dataRowsMapList)
    {
      var dataCells = List<DataCell>();
      var dataRow = DataRow(cells: dataCells);
      // print("ROW CONTENT BEFORE is ${dataRowContent} ");
      var dcheckBox = getSelectionWidget(dataRow);
      var dcellCheckBox = DataCell(dcheckBox);
      dataCells.add(dcellCheckBox);
      for (String columnName in widget.columnNames)
      {
        var tvalue = dataRowContent[columnName] == null ? "*" : dataRowContent[columnName];
        dataCells.add(DataCell(Text(tvalue)));
      }

      
      widget.dataRows.add(dataRow);
    }

    return widget.dataRows;
  }

  Widget getSelectionWidget(DataRow dataRow)
  {
    if (widget.tableEditable == true)
    {
    if (widget.selectOption == "SINGLE")
    {
      return TableRowRadioButton(new Map<String, dynamic>(), dataRow);
    }
    else // if (widget.selectOption == "MULTIPLE")
    {
      return TableRowCheckBox(new Map<String, dynamic>(), dataRow);
    } 
    }
    else
    {
      return Text("");
    }
 
  }

  List<Widget> getButtons()
  {
    var buttonList = List<Widget>();

    var creatingRow = widget.tableStatus['CREATINGROW'] == null ? false : widget.tableStatus['CREATINGROW'];
    var editingRow = widget.tableStatus['EDITINGROW'] == null ? false : widget.tableStatus['EDITINGROW'];

    // the refresh button
    buttonList.add(
      RaisedButton(
        child: Icon(Icons.refresh),
        onPressed: ()
        {
          // cannot refresh if in editing mode
          if (creatingRow == false && editingRow == false) 
          {
            if (widget.persistenceData != null)
            {
              Map<String, dynamic> smartTableEventMap = Map<String, dynamic>();
              smartTableEventMap['EVENTNAME'] = 'REFRESHTABLEEVENT';
              smartTableEventMap['PERSISTENCEDATA'] = widget.persistenceData;
              BlocProvider.of<EditPlusTableBloc>(context).add(smartTableEventMap);
            }
          }
          else
          {
            print("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableStatus['CREATINGROW']}  || ${widget.tableStatus['EDITINGROW']}");
          }
        },
      )
    );

    // the add row button
    if (widget.tableEditable == true)
    {
      buttonList.add(
        RaisedButton(
          child: Icon(Icons.add),
          onPressed: ()
          {
            if (editingRow == false) 
            {
              widget.tableStatus['EDITINGNEWROW'] = true;
              Map<String, dynamic> smartTableEventMap = Map<String, dynamic>();
              smartTableEventMap['EVENTNAME'] = 'NEWROWEVENT';
              BlocProvider.of<EditPlusTableBloc>(context)
                            .add(smartTableEventMap);
            }
            else
            {
            // print("That action EDITINGNEWROW is not known in ${widget.tableStatus}");
            }
          },
        )
      );
    }
    if (widget.tableEditable == true)
    {
      buttonList.add(
        RaisedButton(
          child: Icon(Icons.edit),
          onPressed: ()
          {
            // cannot edit if already in editing mode
            if (editingRow == false) 
            {
              // go through the rows and find the selected row
              for (DataRow dRow in widget.dataRows)
              {
                TableRowCheckBox rcb = dRow.cells[0].child;
                Map rcbstate = rcb.row_state();
                if (rcbstate.containsKey("SELECTED") && rcbstate["SELECTED"] == true)
                {
                  print("Datarow cell 0 is $rcbstate");
                  break;
                }
                
              }
            }
            else
            {
              print("That action DELETE CANNOT be done on a table row while also editing");
            }
          },
        )
      );
    }    
    if (widget.tableEditable == true)
    {
      buttonList.add(
        RaisedButton(
          child: Icon(Icons.delete),
          onPressed: ()
          {
            // cannot delete if in editing mode
            if (editingRow == false) 
            {

            }
            else
            {
              print("That action DELETE CANNOT be done on a table row while also editing");
            }
          },
        )
      );
    }    
    if (widget.tableEditable == true)
    {
      buttonList.add(               
        RaisedButton(
          child: Icon(Icons.save),
          onPressed: ()
          {
            if (widget.tableStatus['EDITINGNEWROW'] == true) 
            {    
              // collect data
              // print("Row data is ${widget.tableStatus['NEWBLANKROW'].cells}");
              var savedata = Map<String, dynamic>();
              for (DataCell dc in widget.tableStatus['NEWBLANKROW'].cells)
              {
                if (dc.child is TextFormField)
                {
                  TextFormField tff = dc.child;
                  ValueKey valueKey = tff.key;
                  TextEditingController tec = tff.controller;
                  String value = tec.value.text;
                  String valuekey = valueKey.value;
                  // print("Cell data is $valuekey AND value is $value");
                  savedata[valuekey] = value;
                  tec.value = TextEditingValue.empty;
                  continue;
                }
              } 
              savedata['EDIT_STATE'] = "NEW ROW";

              // send data to bloc                
              Map<String, dynamic> smartTableEventMap = Map<String, dynamic>();
              smartTableEventMap['EVENTNAME'] = 'SAVEROWEVENT';
              smartTableEventMap['EVENTDATA'] = savedata;
              if (widget.persistenceData != null)
              {
                smartTableEventMap['PERSISTENCEDATA'] = widget.persistenceData;
              }
              BlocProvider.of<EditPlusTableBloc>(context)
                            .add(smartTableEventMap);
            }
          },
        )
      );
    }

    return buttonList;
  }
  
}
