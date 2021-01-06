part of edit_plus;

class EditPlusDataTable extends StatefulWidget
{
  final Text tableLabel;
  final List<String> columnNames;
  final bool tableEditable;
  final Map<String, Widget> fieldEditors;
  final Function refreshTableFunction;

  final tableEditStatus = new Map<String, dynamic>();
  final List<DataRow> dataRows = [];
  final List<DataCell> editDataCells = [];

   // create a global keys
  final fieldKeys = new Map<String, dynamic>();
  // final _tableKey = GlobalKey<FormState>();


  EditPlusDataTable(
    {@required this.tableLabel,
     @required this.columnNames,
     @required this.tableEditable,
     @required this.refreshTableFunction,
     this.fieldEditors}
  );

  @override
  State<StatefulWidget> createState() 
  { 
    // create Blank Data Row for editing based on the field editors.
    // var editDataCells = List<DataCell>();
    editDataCells.add(DataCell(Text(" ")));
    for (String columnName in columnNames)
    {
      if (fieldEditors != null && fieldEditors.containsKey(columnName))
      {
        editDataCells.add(DataCell(fieldEditors[columnName]));
        continue;
      }
      
      fieldKeys[columnName] = GlobalKey<FormState>();  
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
      key: GlobalObjectKey<FormState>(textName),
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        hintText: textName,
        // hintStyle: TextStyle(color: Colors.blueAccent),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
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

    // make the column headings names widgets
    List<DataColumn> tableColumns = [];

    // Add selection column
    tableColumns.add(
        DataColumn(
            label: Text(
              " ",
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold
                )
              ),
          ),
      );

    // Add all other columns.
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
        margin: new EdgeInsets.all(1.0),
        padding: new EdgeInsets.all(1.0),
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
                            if (getCreateState() == true) // widget.tableEditStatus.containsKey('EDITINGNEWROW') && widget.tableEditStatus['EDITINGNEWROW'] == true)
                            {
                              widget.dataRows.add(widget.tableEditStatus['NEWBLANKROW']);
                            }
                          }
                          if (action == 'SAVEROW')
                          {
                            widget.dataRows.remove(widget.tableEditStatus['NEWBLANKROW']);
                            widget.tableEditStatus['CREATINGROW'] = false;
                            widget.tableEditStatus['EDITINGROW'] = false;
                            blankEditRow();
                            // widget.saveTableFunction(dataRowsList);
                          }
                        }
                        
                        return DataTable (
                          columns : tableColumns,
                          rows: widget.dataRows,
                          dividerThickness: 1,
                          horizontalMargin: 1,
                          showCheckboxColumn: false,
                          columnSpacing: 12.0,
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
      List<DataCell> dataCells = [];
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
      /*if (widget.multiSelect == "SINGLE")
      {
        return TableRowRadioButton(new Map<String, dynamic>(), dataRow);
      }
      else
      {
        return TableRowCheckBox(new Map<String, dynamic>(), dataRow);
      } */
      return TableRowCheckBox(new Map<String, dynamic>(), dataRow);
    }
    else
    {  
      return Text("");
    }
 
  }

  bool getCreateState()
  {
    return widget.tableEditStatus['CREATINGROW'] == null ? false : widget.tableEditStatus['CREATINGROW'];
  }

  bool getEditState()
  {
    return widget.tableEditStatus['EDITINGROW'] == null ? false : widget.tableEditStatus['EDITINGROW'];
  }

  List<Widget> getButtons()
  {
    List<Widget> buttonList = [];

    // var creatingRow = widget.tableEditStatus['CREATINGROW'] == null ? false : widget.tableEditStatus['CREATINGROW'];
    // var editingRow = widget.tableEditStatus['EDITINGROW'] == null ? false : widget.tableEditStatus['EDITINGROW'];

    // the refresh button
    buttonList.add(
      RaisedButton(
        child: Icon(Icons.refresh),
        onPressed: ()
        {
          // cannot refresh if in editing mode
          if (getCreateState() == false && getEditState() == false) 
          {
            widget.refreshTableFunction(BlocProvider.of<EditPlusTableBloc>(context));
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
            if (getCreateState() == false && getEditState() == false) 
            {
              widget.tableEditStatus['CREATINGROW'] = true;
              Map<String, dynamic> editPlusTableEventMap = Map<String, dynamic>();
              editPlusTableEventMap['EVENTNAME'] = EditPlusBlocEvent.NEWROWEVENT;
              BlocProvider.of<EditPlusTableBloc>(context)
                            .add(editPlusTableEventMap);
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
            if (getCreateState() == true) 
            {    
              // collect data
              // print("Row data is ${widget.tableStatus['NEWBLANKROW'].cells}");
              var savedata = Map<String, dynamic>();
              for (DataCell dc in widget.tableEditStatus['NEWBLANKROW'].cells)
              {
                if (dc.child is TextFormField)
                {
                  TextFormField tff = dc.child;
                  
                  GlobalObjectKey<FormState> valueKey = tff.key;
                  // valueKey.currentState.validate();

                  TextEditingController tec = tff.controller;
                  String value = tec.value.text;
                  if (value == null || value.isEmpty) {return; }
                  String valuekey = valueKey.value;
                  print("Cell data is $valuekey AND value is $value");
                  savedata[valuekey] = value;
                  // tec.value = TextEditingValue.empty;
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

              /*if (widget.saveTableFunction != null)
              {
                widget.saveTableFunction(savedata);
              } */
              // print("data to save is $savedata");
            }
          },
        )
      );
    }

    return buttonList;
  }

  void blankEditRow()
  {
    widget.editDataCells.clear();

    widget.editDataCells.add(DataCell(Text(" ")));
    for (String columnName in widget.columnNames)
    {
      if (widget.fieldEditors != null && widget.fieldEditors.containsKey(columnName))
      {
        widget.editDataCells.add(DataCell(widget.fieldEditors[columnName]));
        continue;
      }
      
      widget.fieldKeys[columnName] = GlobalKey<FormState>();  
      widget.editDataCells.add(DataCell(widget.getTextFormField(columnName)));

    }
    var newDataRow = DataRow(cells: widget.editDataCells);

    // create the table status to handle editing state
    widget.tableEditStatus['NEWBLANKROW'] = newDataRow;
  }
  
}
