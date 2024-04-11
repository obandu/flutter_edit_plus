part of edit_plus;

/**
 * Flutter EditPlusDataTable is a composite widget containing a material datatable and 
 * decorations that 'enhance' presentation and later allow for editing of the table contents.
 * It works on web, mobile and desktop. 
 * 
 * The widget relies on the calling or containing widgets to supply call back functions for
 * data manipulation and further communications with the rest of the application. For example
 * the calling application will provide a call back function to show a message or to copy data.
 * 
 * The EditPlusDataTable handles table records in pages
 */
class EditPlusDataTable extends StatefulWidget
{
  // presentation
  final Text tableLabel;
  final Map<String, dynamic>? columnLabels;  // ** FOR FUTURE ENHANCEMENTS

  // Row colours, alternate row colours
  List? rowColors = <Color>[];        // ** FOR FUTURE ENHANCEMENTS

  // table (data) content
  final List<String> columnNames;
  final List tableDataContent;
  final String keyColumnName;  

  // editable features
  final bool? tableEditable;                 // ** FOR FUTURE ENHANCEMENTS
  final bool tableExtensible;
  final bool canDeleteRow;
  final bool canEditRow;
  final Map? fieldsWithAlignment;
  final Map? fieldsWithFormattingFunction;
  final List? fieldsWithEditors;            // ** FOR FUTURE ENHANCEMENTS
  Map tableEditStatus = {};  

  final Function? refreshTableFunction;
  final Function? saveTableFunction;        // ** FOR FUTURE ENHANCEMENTS
  final Function? saveRowFunction;  
  final Function? deleteRowFunction;
  final Function? showMessageFunction;
  final Function? getFieldEditorFunction;
  final Function? dismissProgressDialogFunction;  

   // create a global keys
  final fieldKeys = <String, dynamic>{};

  EditPlusDataTable(
    {required this.tableLabel,
     required this.columnNames,
     required this.tableEditable,
     required this.tableExtensible,
     required this.canEditRow,
     required this.canDeleteRow,
     required this.tableDataContent,
     required this.keyColumnName,     
     this.fieldsWithEditors,
     this.fieldsWithAlignment,
     this.fieldsWithFormattingFunction,      
     this.columnLabels,
     this.refreshTableFunction,  

     this.saveTableFunction,
     this.saveRowFunction,
     this.showMessageFunction,
     this.dismissProgressDialogFunction,     
     this.getFieldEditorFunction,
     this.deleteRowFunction,

     this.rowColors
    }
  );



  @override
  _EditPlusDataTableState createState() => _EditPlusDataTableState();

}

class _EditPlusDataTableState extends State<EditPlusDataTable>
{
  List<DataCell> editDataCells = [];
  List<DataRow> dataRows = [];
  List<DataColumn> tableColumns = [];
  DataRow blankEditRow = DataRow(cells: []);

  GlobalKey<FormState> editRowFormState = GlobalKey<FormState>();

  // indicator of which row is being edited
  int rowEditIndex = -1;

  var tableWidthScrollController = ScrollController();
  var tableWidthScrollOffset = 0.0;

  int alternativeKeyAsRowIndex = 0;  

  int page = 0;
  int pageSize = 10;
  int _calculatedPages = 1;

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
    _calculatedPages = (dataRows.length ~/ pageSize)+1;

    if (widget.tableEditStatus['CREATINGROW'] == true)
    {
      // widget.showMessageFunction("Blank row length is ${blankEditRow.cells.length} and number of columns is ${tableColumns.length}");
      dataRows.add(blankEditRow);
    }

    // widget.showMessageFunction("Widget data rows are now ${widget.dataRows}");
    var nowTime = DateFormat('hh:mm:ss').format(DateTime.now());
    // widget.showMessageFunction!("$nowTime : Just befor creating the table ...");
    DataTable innerDataTable = justDataTable();
    nowTime = DateFormat('hh:mm:ss').format(DateTime.now());
    // widget.showMessageFunction!("$nowTime : .... After crating the table.");
   
    return Container(
        decoration: BoxDecoration(
          border: Border.all()
        ),
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 5,),
                Expanded(
                  child: widget.tableLabel,
                ),
                Expanded(
                  child: ButtonBar( // the table management buttons
                    buttonTextTheme: ButtonTextTheme.normal,
                    buttonPadding: const EdgeInsets.all(5.0),
                    children: getButtons(),
                  ),
                ),                                 
                SizedBox(width: 5,),
              ],
            ),                           
            Divider(),
            SizedBox(height: 5,),
            Row(
              children: [
                SizedBox(width: 5,),
                ElevatedButton.icon(
                    onPressed: ()
                    {
                      tableWidthScrollOffset = (tableWidthScrollOffset > 0) ? (tableWidthScrollOffset - 50.0) : 0;
                      tableWidthScrollController.jumpTo(tableWidthScrollOffset); //animateTo(tableWidthScrollOffset, duration: Duration(seconds: 1), curve: Curves.easeIn);
                      // widget.showMessageFunction("Table width is ${tableWidthScrollController.positions}");
                    }, 
                    icon: Icon(Icons.arrow_left_sharp), 
                    style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(16),
                              ),
                    label: Container()
                ),
                Expanded(
                  child: Text(""),
                ),
                getPageUp(),
                SizedBox(width: 5,), 
                getPageNumbersLabel(),
                SizedBox(width: 5,),                 
                getPageDown(),                              
                Expanded(
                  child: Text(""),
                ),                
                ElevatedButton.icon(
                  onPressed: ()
                  {
                    // get maxScrollExtent
                    ScrollPosition scrollPosition = tableWidthScrollController.positions.first;
                    double maxScrollExtent = scrollPosition.maxScrollExtent; 
                    tableWidthScrollOffset = (tableWidthScrollOffset < maxScrollExtent) ? (tableWidthScrollOffset + min(50.0, (maxScrollExtent-tableWidthScrollOffset))) : maxScrollExtent;
                    tableWidthScrollController.jumpTo(tableWidthScrollOffset); // .animateTo(tableWidthScrollOffset, duration: Duration(seconds: 1), curve: Curves);
                    // widget.showMessageFunction("Table width is ${tableWidthScrollController.positions} EXTENT $maxScrollExtent");                      
                  }, 
                  icon: Icon(Icons.arrow_right_sharp),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),                     
                  label: Container()
                ),
                SizedBox(width: 5,),
              ],
            ),
            const Divider(),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft, 
                child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                    controller: tableWidthScrollController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: ScrollController(),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 800),
                          child: (widget.tableEditable == true && widget.tableExtensible == true) ?
                            Form(
                              key: editRowFormState,
                              child: innerDataTable,
                            ) 
                            : innerDataTable,
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
    _calculatedPages = (dataRows.length ~/ pageSize) + 1;
    int rangebegin = page*pageSize;
    int rangeend = min(((page+1)*pageSize)-1, dataRows.length-1);
    List<DataRow> tablePage = [];
    
    for (int i = rangebegin; i <= rangeend; i++) 
    {
      tablePage.add(dataRows.elementAt(i));
    }
    // widget.showMessageFunction!("Table page no $page and range between $rangebegin and $rangeend contains ${dataRows.length}");
    return DataTable (
      columns : tableColumns,
      rows: tablePage,
      dividerThickness: 1,
      horizontalMargin: 1,
      showCheckboxColumn: false,
      columnSpacing: 12.0,
      dataRowHeight: 60,
    );
  }

  Widget getPageNumbersLabel()
  {
    if (_calculatedPages > 1)
    {
      return Text("Page ${page+1} of $_calculatedPages");
    }

    return Container();    
  }

  Widget getPageUp()
  {
    if (_calculatedPages > 1)
    {
      return ElevatedButton.icon(
        onPressed: ()
        {
          if (page-1 >= 0)
          {
            page = page-1;
          }
          setState(() {});
        }, 
        icon: Icon(Icons.arrow_upward_rounded), 
        style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
        label: Container()
      );
    }

    return Container();
  }

  Widget getPageDown()
  {
    if (_calculatedPages > 1)
    {
      return ElevatedButton.icon(
          onPressed: ()
          {
            if (page+1 < _calculatedPages)
            {
              page = page+1;
            }
            setState(() {});
          }, 
          icon: Icon(Icons.arrow_downward_sharp), 
          style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
          label: Container()
      );
    }

    return Container();
  }

  String getColumnLabel(String columnName)
  {
    if (widget.columnLabels == null)
    {
      return columnName;
    }

    var columnLabel = widget.columnLabels![columnName];

    if (columnLabel == null)
    {
      return columnName;
    }

    return columnLabel.toString();
  }

  ValueKey<String> getRowKeyValue(var dataRowContent)
  {
    String valkey = dataRowContent[widget.keyColumnName];
    if (valkey == null)
    {
      valkey = alternativeKeyAsRowIndex.toString();
      alternativeKeyAsRowIndex += 1;
      return ValueKey<String>(valkey);
    }

    return ValueKey<String>(valkey);
  }

  List<DataRow> getDataRows(var dataRowsMapList)
  {
    if (dataRowsMapList == null) { return [];}

    // create DataRows for DataTable rows
    dataRows.clear();

    int rowIndex = 0;

    // widget.showMessageFunction("The data rows map is $dataRowsMapList");

    for (var dataRowContent in dataRowsMapList)
    {
      if (dataRowContent == null) { continue; }
      List<DataCell> dataCells = [];
      var dataRow = DataRow(cells: dataCells, key: getRowKeyValue(dataRowContent)); // ValueKey<String>(dataRowContent[widget.keyColumnName].toString()));
      // widget.showMessageFunction("ROW CONTENT BEFORE ${dataRowContent} KEY IS ${widget.keyColumnName} is ${dataRowContent[widget.keyColumnName]} and key is ${dataRow.key}");
      var dcheckBox = getSelectionWidget(dataRow);
      var dcellCheckBox = DataCell(dcheckBox);
      dataCells.add(dcellCheckBox);
      for (String columnName in widget.columnNames)
      {
        var tvalue = dataRowContent[columnName] == null ? "*" : dataRowContent[columnName];
        dataCells.add(getDataCell(columnName, tvalue, rowIndex));
      }

      if (widget.canDeleteRow && widget.deleteRowFunction != null)
      {
        if (rowEditIndex == -1)
        {
          dataCells.add(
            DataCell(TextButton(
              onPressed: ()
              {
                if (widget.deleteRowFunction != null)
                {
                  widget.deleteRowFunction!(dataRowContent);
                }
                else
                {
                  // widget.showMessageFunction!("This feature - ability to delete rows is under implementation ${dataRowContent[widget.keyColumnName]}");
                }
              },
              child: Icon(Icons.delete_rounded),
            ))
          );
        }
        else
        {
          dataCells.add(DataCell(Container()));        
        }
      }


      if (widget.canEditRow != null && widget.canEditRow == true)
      {
        if (rowEditIndex == rowIndex)
        {
          dataCells.add(
            DataCell(
              Row(
                children: [
                  TextButton(
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
                          if (value == null || value.isEmpty) {continue; }
                          String valuekey = valueKey.value.toString();
                          int splitpos = valuekey.indexOf(" -");
                          List<String> valkl = valuekey.split('-');
                          valuekey = valkl[0].toString().trim();
                          // widget.showMessageFunction("Cell $splitpos - data is ${valkl[0]} AND value is $value");
                          dataToSave[valuekey] = value;                  
                          // tec.value = TextEditingValue.empty;
                          continue;
                        }
                      } 
                      dataToSave['EDIT_STATE'] = "UPDATE_ROW";
                      dataToSave['KEYVALUE'] = rowValueKey.value;
                      dataToSave['KEYNAME'] = widget.keyColumnName;

                      // widget.showMessageFunction("Data to save ${dataToSave} and function ${widget.saveRowFunction}");

                      if (widget.saveRowFunction != null)
                      {
                        widget.saveRowFunction!(dataToSave);
                      }

                      rowEditIndex = -1;
                      setState(() {});
                    },
                    child: Icon(Icons.save_rounded),
                  ),
                  TextButton(
                    onPressed: ()
                    {
                      rowEditIndex = -1;
                      setState(() {});
                    },
                    child: Icon(Icons.cancel, color: Colors.red,),
                  )
                ],
              )                
            )
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
                  setState(() {});
                }
                else
                {
                  // widget.showMessageFunction!("Another edit is currently ongoing. Please complete before editing another cell");
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

  /*List<DataRow> getDataRows(var dataRowsMapList)
  {
    if (dataRowsMapList == null) { return [];}

    // create DataRows for DataTable rows
    dataRows.clear();

    int rowIndex = 0;

    for (Map dataRowContent in dataRowsMapList)
    {
      if (dataRowContent == null) { continue; }
      List<DataCell> dataCells = [];
      var dataRow = DataRow(cells: dataCells); //, key: ValueKey<String>(dataRowContent[widget.keyColumnName].toString()));
      // widget.showMessageFunction("ROW CONTENT BEFORE ${dataRowContent} KEY IS ${widget.keyColumnName} is ${dataRowContent[widget.keyColumnName]} ");
      var dcheckBox = getSelectionWidget(dataRow);
      var dcellCheckBox = DataCell(dcheckBox);
      dataCells.add(dcellCheckBox);
      for (String columnName in widget.columnNames)
      {
        var tvalue = dataRowContent[columnName] == null ? "*" : dataRowContent[columnName];
        dataCells.add(getDataCell(columnName, tvalue, rowIndex));
      }

      if (widget.canDeleteRow)
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
                    if (value == null || value.isEmpty) {continue; }
                    String valuekey = valueKey.value.toString();
                    int splitpos = valuekey.indexOf(" -");
                    List<String> valkl = valuekey.split('-');
                    valuekey = valkl[0].toString().trim();
                    widget.showMessageFunction("Cell $splitpos - data is ${valkl[0]} AND value is $value AND value key is $valuekey");
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
  } */

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

      // return DataCell(Text(cellValue));
      return DataCell(getTextFormField(columnName, rowIndex, false, dataValue : cellValue));
    }
    else if (rowEditIndex == rowIndex)
    {
      return DataCell(getTextFormField(columnName, rowIndex, true, dataValue : cellValue));
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
    bool creatingRow = widget.tableEditStatus['CREATINGROW'] == null ? false : widget.tableEditStatus['CREATINGROW'];
    // var editingRow = widget.tableEditStatus['EDITINGROW'] == null ? false : widget.tableEditStatus['EDITINGROW'];

    // the refresh button
    if (widget.refreshTableFunction != null)
    {
      buttonList.add(
        ElevatedButton(
          child: Icon(Icons.refresh),
          onPressed: ()
          {
            // cannot refresh if in editing mode
            if (getCreateState() == false && getEditState() == false) 
            {
              /*widget.tableDataContent.clear();
              widget.tableDataContent.addAll(widget.refreshTableFunction!());
              setState(() {
                
              }); */
              // widget.showMessageFunction!("The refresh feature is currently under enhancement. It should work in future versions.");
            }
            else
            {
              // widget.showMessageFunction("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
              // widget.showMessageFunction!("The table is currently in an edit state. Cannot refresh it.");
            }
          },
        )
      );
    }

    // the csv export button
    buttonList.add(
      ElevatedButton(
        child: Icon(Icons.copy_all_outlined),
        onPressed: ()
        {
          // get table as CSV
          var csvContent = EditPlusUtils.getTableListAsCSV(widget.tableDataContent, widget.columnNames);
          // cannot refresh if in editing mode
          if (getCreateState() == false && getEditState() == false) 
          {
            _copyToClipboard(csvContent);
          }
          else
          {
            // widget.showMessageFunction!("Error on clipboard copy attemtp. What is wrong?"); // widget.showMessageFunction("That action REFRESH CANNOT be done on a table row while also editing mode ${widget.tableEditStatus['CREATINGROW']}  || ${widget.tableEditStatus['EDITINGROW']}");
          }
        },
      )
    );     

    // the add row/cancel button
    if (widget.tableEditable == true && widget.tableExtensible == true)
    {
      buttonList.add(
        ElevatedButton(
          child: creatingRow == false ? const Icon(Icons.add) : const Icon(Icons.cancel, color: Colors.red,),
          onPressed: ()
          {
            if (creatingRow == true)
            {
              widget.tableEditStatus['CREATINGROW'] = false;
              dataRows.remove(blankEditRow);
              setState(() {});
            }
            else if (getCreateState() == false && getEditState() == false) 
            {
              widget.tableEditStatus['CREATINGROW'] = true;
              blankEditRow = makeBlankEditRow();
              setState(() {});
            }
            else
            {
              // widget.showMessageFunction("Add states are $getCreateState() and $getEditState() ");
            }
          },
        )
      );
    }   
    if ((widget.tableEditable == true && creatingRow == true && widget.tableExtensible == true)  || (widget.tableEditable == true && widget.tableExtensible == false))
    {
      buttonList.add(               
        ElevatedButton(
          child: const Icon(Icons.save),
          onPressed: ()
          {
            if (getCreateState() == true) 
            {    
              // collect data
              // widget.showMessageFunction("Row data is ${widget.tableStatus['NEWBLANKROW'].cells}");
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
                  if (value == null || value.isEmpty) {return; }
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

              if (widget.saveRowFunction != null)
              {
                widget.saveRowFunction!(savedata);
              } 
              // widget.showMessageFunction("data to save is $savedata");
            }
            else
            {
              // widget.showMessageFunction("saving the whole table ...");
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
      editDataCells.add(DataCell(getTextFormField(columnName, 0, true)));

    }

    if (widget.canDeleteRow)
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

  returnGiven(var givenValue)
  {
    return givenValue;
  }

  TextFormField getTextFormField(String textName, int rowIndex, bool editEnabled, {var dataValue})
  {
    TextAlign textFieldAlignment = (widget.fieldsWithAlignment != null && widget.fieldsWithAlignment!.containsKey(textName) && widget.fieldsWithAlignment![textName] is TextAlign) ?
                                    widget.fieldsWithAlignment![textName] : TextAlign.start;

    Function textFieldFormatFunction = (widget.fieldsWithFormattingFunction != null && widget.fieldsWithFormattingFunction!.containsKey(textName) && widget.fieldsWithFormattingFunction![textName] is Function) ?
                                    widget.fieldsWithFormattingFunction![textName] : returnGiven;

    InputDecoration textFormDecoration = editEnabled ?
      InputDecoration(
          hintText: textName,
          // hintStyle: TextStyle(color: Colors.blueAccent),
          border: const OutlineInputBorder(),
          fillColor: Colors.grey[200],
        ) :
        InputDecoration(
          hintText: textName,
          hintStyle: TextStyle(color: Colors.blueAccent),
          fillColor: Colors.grey[200],
          filled: true          
        );

    var fieldValue = dataValue.toString();
    if (textFieldFormatFunction != null)
    {
      fieldValue = textFieldFormatFunction(fieldValue);
    }

    if (fieldValue != null)
    {
      TextEditingController tecInput = TextEditingController(text: fieldValue.toString());
      return TextFormField
      (
        key: ValueKey<String>("$textName - $rowIndex"),
        autovalidateMode: AutovalidateMode.always,
        decoration: textFormDecoration,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$textName';
          }
          return null;
        },
        controller: tecInput,
        textAlign: textFieldAlignment,
        enabled: editEnabled,
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
          return '$textName ??';
        }
        return null;
      },
      controller: TextEditingController(),
    );    
  }

  void updateTable()
  {

  } 

  /*List<Map>  collectData()
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
  } */

  List<Map>  collectData()
  {
    List<Map> collectedRows = [];

    for (var dataRow in dataRows)
    {
      Map mpDrow = {};

      if (widget.keyColumnName != null)
      {
        ValueKey? valueKey = dataRow.key as ValueKey;
        mpDrow[widget.keyColumnName] = valueKey.value;
      }
      else
      {
        ValueKey? valueKey = dataRow.key as ValueKey;
        mpDrow[widget.keyColumnName] = valueKey.value;        
      }

      for (var columnName in widget.columnNames)
      {
        DataCell drcell = dataRow.cells.elementAt(widget.columnNames.indexOf(columnName)+1) as DataCell;
        if (drcell.child is Text)
        {
          Text cellEntry = drcell.child as Text;
          mpDrow[columnName] = cellEntry.data;
        }
        else if (drcell.child is EditPlusStringDropdown)
        {
          EditPlusStringDropdown cellEntry = drcell.child as EditPlusStringDropdown;
          mpDrow[columnName] = cellEntry.valueContainer['VALUE'];
        }
        else if (drcell.child is TextField)
        {
          TextField cellEntry = drcell.child as TextField;
          mpDrow[columnName] = cellEntry.controller!.text;
        }
        else if (drcell.child is TextFormField)
        {
          TextFormField cellEntry = drcell.child as TextFormField;
          mpDrow[columnName] = cellEntry.controller!.text;
        }        
      }

      collectedRows.add(mpDrow);
    }

    return collectedRows;
  }
  
  // copy to clipboard and alert
  Future<void> _copyToClipboard(var csvContent ) async {
    await Clipboard.setData(ClipboardData(text: csvContent));
      widget.showMessageFunction!("FULL TABLE DATA COPIED TO CLIPBOARD");
  }    
  
}
