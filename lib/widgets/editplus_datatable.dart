part of edit_plus;

class EditPlusDataTable extends StatefulWidget
{
  final Text tableLabel;
  final List<String> columnNames;
  final List <Map<String, dynamic>> dataRowsSource;
  final bool tableEditable;
  final String multiSelect;
  final Map fieldEditors;
  final Function saveTableFunction;
  final Function alertFunction;
  final Function refreshTableFunction;

  final tableEditStatus = new Map<String, dynamic>();
  final dataRows = new List<DataRow>();

  EditPlusDataTable(
    {this.tableLabel,
     this.columnNames,
     this.dataRowsSource,
     this.tableEditable,
     this.multiSelect,
     this.fieldEditors,
     this.saveTableFunction,
     this.alertFunction,
     this.refreshTableFunction}
  );

  @override
  State<StatefulWidget> createState() 
  { 
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
       
      editDataCells.add(DataCell(getTextFormField(columnName)));
    }
    var newDataRow = DataRow(cells: editDataCells);

    // create the table status to handle editing state
    tableEditStatus['NEWBLANKROW'] = newDataRow;
    tableEditStatus['CREATINGROW'] = false;
    tableEditStatus['EDITINGROW'] = false;
    return EditPlusDataTableState();
  }

  TextFormField getTextFormField(String textName)
  {
    return TextFormField
    (
      key: ValueKey(textName),
      decoration: InputDecoration(
        hintText: textName,
        // hintStyle: TextStyle(color: Colors.blueAccent),
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
}

class EditPlusDataTableState extends State<EditPlusDataTable>
{
  
  @override
  Widget build(BuildContext context) 
  {
    // create a global key
    final _tableKey = GlobalKey<FormState>();

    // create the header
    var tableHeader = widget.tableLabel;

    // make the column headings names widgets
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

    // create rows for table
    getDataRows(widget.dataRows);


    return Container(
        decoration: BoxDecoration(
          border: Border.all()
        ),
        margin: new EdgeInsets.all(2.0),
        padding: new EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.tableLabel, // the table label
                ButtonBar( // the table management buttons
                  buttonTextTheme: ButtonTextTheme.normal,
                  buttonPadding: EdgeInsets.all(5.0),
                  children: getButtons(),
                ),
              ]
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: BlocConsumer<EditPlusTableBloc, Map<String, dynamic>>(
                      buildWhen: (previous,current) {
                        return true;
                      },
                      builder: (context, editPlusTableBloc) {
                        var dataRowsList = editPlusTableBloc['DATAROWS'];
                        if (dataRowsList != null)
                        {
                          getDataRows(dataRowsList);
                        }

                        if (editPlusTableBloc.containsKey("NEWROWACTION") )
                        {
                          String action = editPlusTableBloc['NEWROWACTION'];
                          if (action == 'INSERTROW')
                          {
                            if (widget.tableEditStatus.containsKey('EDITINGNEWROW'))
                            widget.dataRows.add(widget.tableEditStatus['NEWBLANKROW']);
                          }
                          if (action == 'SAVEROW')
                          {
                            widget.dataRows.remove(widget.tableEditStatus['NEWBLANKROW']);
                            widget.tableEditStatus['EDITINGNEWROW'] = false;
                            widget.saveTableFunction(dataRowsList);
                          }
                        }
                        
                        return DataTable (
                          columns : tableColumns,
                          rows: widget.dataRows,
                          dividerThickness: 2,
                          horizontalMargin: 2,
                          showCheckboxColumn: false,
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
      if (widget.multiSelect == "SINGLE")
      {
        return TableRowRadioButton(new Map<String, dynamic>(), dataRow);
      }
      else
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

    var creatingRow = widget.tableEditStatus['CREATINGROW'] == null ? false : widget.tableEditStatus['CREATINGROW'];
    var editingRow = widget.tableEditStatus['EDITINGROW'] == null ? false : widget.tableEditStatus['EDITINGROW'];

    // the refresh button
    buttonList.add(
      RaisedButton(
        child: Icon(Icons.refresh),
        onPressed: ()
        {
          // cannot refresh if in editing mode
          if (creatingRow == false && editingRow == false) 
          {
            /*
            if (widget.persistenceData != null)
            {
              Map<String, dynamic> editPlusTableEventMap = Map<String, dynamic>();
              editPlusTableEventMap['EVENTNAME'] = 'REFRESHTABLEEVENT';
              BlocProvider.of<EditPlusTableBloc>(context).add(editPlusTableEventMap);
            } */

            // call the refresh table function
            widget.refreshTableFunction();
          }
          else
          {
            print("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
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
              widget.tableEditStatus['EDITINGNEWROW'] = true;
              Map<String, dynamic> editPlusTableEventMap = Map<String, dynamic>();
              editPlusTableEventMap['EVENTNAME'] = EditPlusBlocEvent.NEWROWEVENT;
              BlocProvider.of<EditPlusTableBloc>(context)
                            .add(editPlusTableEventMap);
            }
            else
            {
            // print("That action EDITINGNEWROW is not known in ${widget.tableStatus}");
            }
          },
        )
      );
    }
    /*if (widget.tableEditable == true)
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
    } */   
    if (widget.tableEditable == true)
    {
      buttonList.add(               
        RaisedButton(
          child: Icon(Icons.save),
          onPressed: ()
          {
            if (widget.tableEditStatus['EDITINGNEWROW'] == true) 
            {    
              // collect data
              // print("Row data is ${widget.tableStatus['NEWBLANKROW'].cells}");
              var savedata = Map<String, dynamic>();
              for (DataCell dc in widget.tableEditStatus['NEWBLANKROW'].cells)
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
              Map<String, dynamic> editPlusTableEventMap = Map<String, dynamic>();
              editPlusTableEventMap['EVENTNAME'] = EditPlusBlocEvent.SAVEROWEVENT;
              editPlusTableEventMap['EVENTDATA'] = savedata;
              BlocProvider.of<EditPlusTableBloc>(context)
                            .add(editPlusTableEventMap);

              // widget.saveTableFunction(savedata);
              // print("data to save is $savedata");
            }
          },
        )
      );
    }

    return buttonList;
  }
  
}
