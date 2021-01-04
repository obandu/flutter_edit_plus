part of edit_plus;
  
class EditPlusUtils
{
  static String getTableListAsJSON(List<Map<String, dynamic>> dataRows)
  {
    String jsoncontent = "";

    for (Map dataRow in dataRows)
    {
      jsoncontent += "{";
      for (String dkey in dataRow.keys)
      {
        jsoncontent += '"'+ dkey + '" : "' + dataRow[dkey] + '",';
      }
      jsoncontent = jsoncontent.substring(0, jsoncontent.length-1);
      jsoncontent += "},";
    }

    jsoncontent = jsoncontent.substring(0, jsoncontent.length-1);
    String jsonbloc = "{\"TABLEROWS\":[" + jsoncontent + "]}";

    return jsonbloc;
  }

  static List<Map<String, dynamic>> dataRowsFromJSON(var jsonTableList, var tableColumnNames)
  {
    // CONVERT TO LIST OF MAPS holding the key value pairs
    var tableDataRows = List<Map<String, dynamic>>();
    
    for (Map jsonItem in jsonTableList)
    {
      var rowDescription = Map <String, dynamic>();
      for (String columnName in tableColumnNames)
      {
        rowDescription[columnName] = jsonItem[columnName];
      }
      tableDataRows.add(rowDescription);
    }  

    return tableDataRows;
  }
}