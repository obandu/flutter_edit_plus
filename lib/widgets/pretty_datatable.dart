part of edit_plus;

/**
 * Flutter PrettyDataTable is a composite widget containing a material datatable and 
 * decorations that 'enhance' presentation and eventually allow for editing of the table contents.
 * It works on web, mobile and desktop. 
 * 
 * The widget relies on the calling or containing widgets to supply call back methods for
 * some data manipulation and further communications with the rest of the application.
 */
class PrettyDataTable extends StatefulWidget
{
  // presentation
  final Widget tableLabel;
  final Map<String, dynamic>? columnLabels; // Alternative labels, matching to column names

  // table (data) content
  final List<String> columnNames;
  final List<Map> tableDataContent;

  // essential call back methods
  final Function? showMessageFunction;
  final Function? refreshTableFunction;

  // fields to support editing/extending of the table
  final bool? tableEditable;                 // ** FOR FUTURE ENHANCEMENTS
  final bool? tableExtensible;
  final bool? canDeleteRow;
  final bool? canEditRow;

  final List? fieldsWithEditors;            // ** FOR FUTURE ENHANCEMENTS

  final Function? saveTableFunction;        // ** FOR FUTURE ENHANCEMENTS
  final Function? saveRowFunction;  
  final Function? deleteRowFunction;
  final Function? getFieldEditorFunction;

   // create a global keys
  final fieldKeys = <String, dynamic>{};

  PrettyDataTable(
    {required this.tableLabel,
     required this.columnNames,
     required this.tableDataContent,     
     this.tableEditable,
     this.tableExtensible,
     this.canEditRow,
     this.canDeleteRow,
     this.fieldsWithEditors,
     this.columnLabels,
     this.refreshTableFunction,     
     this.saveTableFunction,
     this.saveRowFunction,
     this.showMessageFunction,
     this.getFieldEditorFunction,
     this.deleteRowFunction,
    }
  );

  // Row colours, alternate row colours
  Color rowColor1 = Colors.lightGreen;        // ** FOR FUTURE ENHANCEMENTS
  Color rowColor2 = Colors.lightBlueAccent;   // ** FOR FUTURE ENHANCEMENTS

  Map tableEditStatus = {};

  @override
  _PrettyDataTableState createState() => _PrettyDataTableState();

}

class _PrettyDataTableState extends State<PrettyDataTable>
{
  List<DataCell> editDataCells = [];
  List<DataRow> dataRows = [];
  List<DataColumn> tableColumns = [];
  DataRow blankEditRow = DataRow(cells: []);

  GlobalKey<FormState> editRowFormState = GlobalKey<FormState>();

  // indicator of which row is being edited
  int rowEditIndex = -1;

  @override
  Widget build(BuildContext context) 
  {

    tableColumns.clear();
    // make the column headings names widgets
    // Add selection column
    tableColumns.add(
      const DataColumn(
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
              getColumnLabel(columnName),
              style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold
                )
              ),
          ),
      );
    }

    if (widget.canDeleteRow == true)
    {
      tableColumns.add(
      const DataColumn(
            label: Text(
              " ",
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold
                )
              ),
          ),
      );
    }

    if (widget.canEditRow == true)
    {
      tableColumns.add(
      const DataColumn(
            label: Text(
              " ",
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold
                )
              ),
          ),
      );
    }    

    // create rows for table
    dataRows = getDataRows(widget.tableDataContent);

    if (widget.tableEditStatus['CREATINGROW'] == true)
    {
      // print("Blank row length is ${blankEditRow.cells.length} and number of columns is ${tableColumns.length}");
      dataRows.add(blankEditRow);

    }

    // print("Widget data rows are now ${widget.dataRows}");
    return Container(
        decoration: BoxDecoration(
          border: Border.all()
        ),
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                widget.tableLabel, // the table label
                ButtonBar( // the table management buttons
                  buttonTextTheme: ButtonTextTheme.normal,
                  buttonPadding: const EdgeInsets.all(5.0),
                  children: getButtons(),
                ),
              ]
            ),
            const Divider(),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft, 
                child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                    controller: ScrollController(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: ScrollController(),
                        child: ConstrainedBox(
                        child: (widget.tableEditable == true && widget.tableExtensible == true) ?
                          Form(
                            key: editRowFormState,
                            child: justDataTable(),
                          ) 
                          : justDataTable(),
                        constraints: const BoxConstraints(minWidth: 800)
                      )
                    ),
                  ),
              )
            ),
          ]
        )
      );
    
  }

  DataTable justDataTable()
  {
    return DataTable (
      columns : tableColumns,
      rows: dataRows,
      dividerThickness: 1,
      horizontalMargin: 1,
      showCheckboxColumn: false,
      columnSpacing: 12.0,
    );
  }

  String getColumnLabel(String columnName)
  {
    if (widget.columnLabels == null)
    {
      return columnName;
    }

    String columnLabel = widget.columnLabels![columnName];

    if (columnLabel == null)
    {
      return columnName;
    }

    return columnLabel;
  }

  List<DataRow> getDataRows(var dataRowsMapList)
  {
    if (dataRowsMapList == null) { return [];}

    // create DataRows for DataTable rows
    dataRows.clear();

    int rowIndex = 0;

    for (Map dataRowContent in dataRowsMapList)
    {
      List<DataCell> dataCells = [];
      var dataRow = DataRow(cells: dataCells); // , key: ValueKey<String>(dataRowContent[widget.keyColumnName].toString()));
      // print("ROW CONTENT BEFORE ${dataRowContent} KEY IS ${widget.keyColumnName} is ${dataRowContent[widget.keyColumnName]} ");
      var dcheckBox = getSelectionWidget(dataRow);
      var dcellCheckBox = DataCell(dcheckBox);
      dataCells.add(dcellCheckBox);
      for (String columnName in widget.columnNames)
      {
        var tvalue = dataRowContent[columnName] == null ? "*" : dataRowContent[columnName];
        dataCells.add(getDataCell(columnName, tvalue, rowIndex));
      }

      if (widget.canDeleteRow!)
      {
        dataCells.add(
          DataCell(TextButton(
            onPressed: ()
            {
              if (widget.showMessageFunction != null)
              {
                widget.showMessageFunction!("This feature is under implementation");
              }
            },
            child: Icon(Icons.delete_rounded),
          ))
        );
      }

      if (widget.canEditRow == true)
      {
        if (rowEditIndex == rowIndex)
        {
          dataCells.add(
            DataCell(TextButton(
              onPressed: ()
              {

                DataRow dataRowToSave = dataRows.elementAt(rowEditIndex);
                ValueKey rowValueKey = dataRowToSave.key as ValueKey<String>;
                // widget.showMessageFunction!(bContext, "This feature is under implementation");

                var dataToSave = <String, String>{};
                for (DataCell dc in dataRowToSave.cells)
                {
                  if (dc.child is TextFormField)
                  {
                    TextFormField tff = dc.child as TextFormField;
                    
                    ValueKey<String> valueKey = tff.key as ValueKey<String>;
                    // valueKey.currentState.validate();

                    TextEditingController? tec = tff.controller;
                    String value = tec!.value.text;
                    if (value.isEmpty) {continue; }
                    String valuekey = valueKey.value.toString();
                    int splitpos = valuekey.indexOf(" -");
                    List<String> valkl = valuekey.split('-');
                    valuekey = valkl[0].toString().trim();
                    print("Cell $splitpos - data is ${valkl[0]} AND value is $value AND value key is $valuekey");
                    dataToSave[valuekey] = value;                  
                    // tec.value = TextEditingValue.empty;
                    continue;
                  }
                } 
                dataToSave['EDIT_STATE'] = "UPDATE_ROW";
                dataToSave['KEYVALUE'] = rowValueKey.toString();
                // dataToSave['KEYNAME'] = widget.keyColumnName;

                if (widget.saveRowFunction != null)
                {
                  widget.saveRowFunction!(dataToSave);
                }

                rowEditIndex = -1;
                setState(() {
                  
                });
              },
              child: Icon(Icons.save_rounded),
            ))
          );

        }
        else
        {
          dataCells.add(
            DataCell(TextButton(
              onPressed: (){
                // widget.showMessageFunction!(bContext, "This feature is under implementation");
                if (rowEditIndex == -1)
                {
                  rowEditIndex = dataRows.indexOf(dataRow);
                  setState(() {
                  
                  });
                }
                else
                {
                  widget.showMessageFunction!("Another edit is currently ongoing. Please complete before editing another cell");
                }
              },
              child: Icon(Icons.edit_rounded),
            ))
          );
        }
      }      

      dataRows.add(dataRow);
      rowIndex += 1;
    }

    return dataRows;
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
      // return TableRowCheckBox(new Map<String, dynamic>(), dataRow);
    }
    else
    {  
      return Text("");
    }

    return Text("");
 
  }

  DataCell getDataCell(var columnName, var cellValue, int rowIndex)
  {
    if (rowEditIndex == -1)
    {
      if (widget.fieldsWithEditors != null && widget.fieldsWithEditors!.contains(columnName))
      {
        return DataCell(widget.getFieldEditorFunction!(columnName, cellValue));
      }

      return DataCell(Text(cellValue));
    }
    else if (rowEditIndex == rowIndex)
    {
      return DataCell(getTextFormField(columnName, rowIndex, initialValue : cellValue));
    }

    return DataCell(Text(cellValue));
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
      ElevatedButton(
        child: Icon(Icons.refresh),
        onPressed: ()
        {
          // cannot refresh if in editing mode
          if (getCreateState() == false && getEditState() == false) 
          {
            widget.tableDataContent.clear();
            widget.tableDataContent.addAll(widget.refreshTableFunction!());
            setState(() {
              
            });
          }
          else
          {
            // print("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
            widget.showMessageFunction!("The table is currently in an edit state. Cannot refresh it.");
          }
        },
      )
    );

    // the add row button
    if (widget.tableEditable == true && widget.tableExtensible == true)
    {
      buttonList.add(
        ElevatedButton(
          child: const Icon(Icons.add),
          onPressed: ()
          {
            if (getCreateState() == false && getEditState() == false) 
            {
              widget.tableEditStatus['CREATINGROW'] = true;
              blankEditRow = makeBlankEditRow();
              setState(() {
                
              });
              /*Map<String, dynamic> editPlusTableEventMap = <String, dynamic>{};
              editPlusTableEventMap['EVENTNAME'] = EditPlusBlocEvent.NEWROWEVENT;
              BlocProvider.of<EditPlusTableBloc>(context)
                            .add(editPlusTableEventMap); */
            }
            else
            {
              print("Add states are $getCreateState() and $getEditState() ");
            }
          },
        )
      );
    }   
    if (widget.tableEditable == true)
    {
      buttonList.add(               
        ElevatedButton(
          child: const Icon(Icons.save),
          onPressed: ()
          {
            if (getCreateState() == true) 
            {    
              // collect data
              // print("Row data is ${widget.tableStatus['NEWBLANKROW'].cells}");
              var savedata = <String, dynamic>{};
              for (DataCell dc in widget.tableEditStatus['NEWBLANKROW'].cells)
              {
                if (dc.child is TextFormField)
                {
                  TextFormField tff = dc.child as TextFormField;
                  
                  ValueKey<String> valueKey = tff.key as ValueKey<String>;
                  // valueKey.currentState.validate();

                  TextEditingController? tec = tff.controller;
                  String value = tec!.value.text;
                  if (value.isEmpty) {return; }
                  String valuekey = valueKey.value.toString();
                  int splitpos = valuekey.indexOf(" -");
                  List<String> valkl = valuekey.split('-');
                  valuekey = valkl[0].toString().trim();
                  // print("Cell $splitpos - data is ${valkl[0]} AND value is $value");
                  savedata[valuekey] = value;
                  // tec.value = TextEditingValue.empty;
                  continue;
                }
              } 
              savedata['EDIT_STATE'] = "NEW ROW";

              if (widget.saveRowFunction != null)
              {
                widget.saveRowFunction!(savedata);
              } 
              // print("data to save is $savedata");
            }
            else
            {
              print("saving the whole table ...");
              widget.saveTableFunction!(collectData());
            }
          },
        )
      );
    }

    return buttonList;
  }

  DataRow makeBlankEditRow()
  {
    editDataCells.clear();
    editDataCells.add(const DataCell(Text(" ")));

    for (String columnName in widget.columnNames)
    {
      if (widget.fieldsWithEditors != null && widget.fieldsWithEditors!.contains(columnName))
      {
        // widget.editDataCells.add(DataCell(widget.fieldEditors[columnName]));
        continue;
      }
      
      // widget.fieldKeys[columnName] = GlobalKey<FormState>();  
      editDataCells.add(DataCell(getTextFormField(columnName, 0)));

    }

    if (widget.canDeleteRow!)
    {
      editDataCells.add(const DataCell(Text(" ")));
    }

    if (widget.canEditRow == true)
    {
      editDataCells.add(const DataCell(Text(" ")));
    }

    var newDataRow = DataRow(cells: editDataCells);

    // create the table status to handle editing state
    widget.tableEditStatus['NEWBLANKROW'] = newDataRow;

    return newDataRow;
  }

  TextFormField getTextFormField(String textName, int rowIndex, {var initialValue})
  {
    if (initialValue != null)
    {
      TextEditingController tecInput = TextEditingController(text: initialValue.toString());
      return TextFormField
      (
        key: ValueKey<String>("$textName - $rowIndex"),
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(
          hintText: textName,
          // hintStyle: TextStyle(color: Colors.blueAccent),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $textName';
          }
          return null;
        },
        controller: tecInput,
      );
    }

    return TextFormField
    (
      key: ValueKey<String>("$textName - $rowIndex"),
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        hintText: textName,
        // hintStyle: TextStyle(color: Colors.blueAccent),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $textName';
        }
        return null;
      },
      controller: TextEditingController(),
    );    
  }

  void updateTable()
  {

  } 

  List<Map>  collectData()
  {
    List<Map> collectedRows = [];

    for (var dataRow in dataRows)
    {
      Map mpDrow = {};

      for (var columnName in widget.columnNames)
      {
        DataCell drcell = dataRow.cells.elementAt(widget.columnNames.indexOf(columnName)+1) as DataCell;
        if (drcell.child is Text)
        {
          Text cellEntry = drcell.child as Text;
          mpDrow[columnName] = cellEntry.data;
        }
        if (drcell.child is EditPlusStringDropdown)
        {
          EditPlusStringDropdown cellEntry = drcell.child as EditPlusStringDropdown;
          mpDrow[columnName] = cellEntry.valueContainer['VALUE'];
        }
      }

      collectedRows.add(mpDrow);
    }

    return collectedRows;
  }
  
}
