# The EDITPLUSDATATABLE
The EditPlusDataTable is a composite of a title (a text widget), a collection of editing buttons, a collection of input fields (only material TextFormField as at version 1.5.10) and a Material DataTable. 

## BACKGROUND
This is an extension of the  Material library based [Datatable](https://api.flutter.dev/flutter/material/DataTable-class.html) with editing convenience and a little decoration. It displays data from a JSON list in a datatable. It allows the ability to edit and/or delete the rows of data from the data rows. It uses call back methods to provide to your application the data/content of the row to be deleted or the row that is changed after editing. Call back methods are also used to refresh the table data or possible to save the contents of the whole table.

## THE CONSTRUCTOR
```dart
  EditPlusDataTable(
    {
     String tableLabel,                   // the title of the composite widget
     List<String> columnNames,            // the names of the columns. These correspond to the names
     bool tableExtensible,                // REQUIRED - determine whether or not a row can be added
     bool canEditRow,                     // REQUIRED - determine whether the row can be edited
     bool canDeleteRow,                   // REQUIRED - determine whether the row can be deleted
     List tableDataContent,               // REQUIRED - the content of the table. This is a list of Map, where each map contains key value pairs whose keys are the columnNames
     Function? refreshTableFunction,      // OPTIONAL - function called to refresh the table     
     Function? saveRowFunction,           // ASSERT - function must be provided if can editrow==true
     Function? showMessageFunction,       // OPTIONAL - function to pass messages back to calling widget
     Function? getFieldEditorFunction,    // OPTIONAL - function to get field editor for each field to be edited in row. If null, returns TextFormField
     Function? deleteRowFunction,         // ASSERT - function to perform deletion of data. Must be provided if canDeleteRow is true
    }
  );
```

The refreshTableFunction, saveRowFunction and deleteRowFunction return an updated tableDataContent

## SAMPLE EDITABLE TABLE
An editable table currently (as at version 1.5.10) includes the ability to add a new row, modify existing rows and also to refresh the table from an external source. 

![Editable Table](editable_table.jpg)

```dart
EditPlusDataTable(
  columnNames: ["ITEMNAME", "CODE", "PRICE"], 
  tableLabel : Text("EXOTIC ANIMAL EGGS"), 
  tableExtensible : true, 
  canEditRow : true,
  canDeleteRow : true,
  tableDataContent : [{"ITEMNAME" : "CROCODILE EGG", "CODE" : "CROCOEGG", "PRICE": "40.00"}, {"ITEMNAME" : "OSTRITCH EGG", "CODE" : "OSTREGG", "PRICE": "50.00"}],
  deleteRowFunction : deleteRow,
  saveRowFunction : saveRow,
  refreshTableFunction: refreshTable)
```

## SAMPLE READ ONLY TABLE
A read only table currently (as at version 1.5.10) includes ONLY the ability to refresh the table from an external source. 

![Read Only Table](readonly_table.jpg)

```dart
EditPlusDataTable(
  columnNames: ["ITEMNAME", "CODE", "PRICE"], 
  tableLabel : Text("EXOTIC ANIMAL EGGS FOR SALE"), 
  tableExtensible : false, 
  canEditRow : false,
  canDeleteRow : false,
  tableDataContent : [{"ITEMNAME" : "CROCODILE EGG", "CODE" : "CROCOEGG", "PRICE": "40.00"}, {"ITEMNAME" : "OSTRITCH EGG", "CODE" : "OSTREGG", "PRICE": "50.00"}]
  refreshTableFunction: refreshTable)
```

## REFRESHING, SAVING AND DELETING DATA - THE FUNCTION SIGNATURES
A refresh function is required with this version (1.5.10). 

#### Our table constructor pointing to refresh function
```dart
EditPlusDataTable(
  columnNames: tableColumnNames, 
  tableLabel : Text("SALES ITEMS"), 
  tableEditable : false, 
  refreshTableFunction: refreshTable)
```
#### The refresh function should return an updated data table
```dart
  List refreshTable ()
  {
    // get data from a custom external source
    List updatedDataTable = getTableFromExternalSource();


    return updatedDataTable;
  }
```

#### The delete row function should return an updated data table
```dart
  List deleteRow (var rowData, var tableData)
  {
    // delete data from original data table, return updaed data table


    return updatedDataTable;
  }
```

#### The save row function should return an updated data table
```dart
  List saveRow (var rowData, var tableData)
  {
    // append data to original data table, return updaed data table


    return updatedDataTable;
  }
```