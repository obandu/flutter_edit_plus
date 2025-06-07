part of edit_plus;

class EditPlusUtils {
  static String getTableListAsJSON(List<Map<String, dynamic>> dataRows) {
    String jsoncontent = "";

    for (Map dataRow in dataRows) {
      jsoncontent += "{";
      for (String dkey in dataRow.keys) {
        jsoncontent += '"' + dkey + '" : "' + dataRow[dkey] + '",';
      }
      jsoncontent = jsoncontent.substring(0, jsoncontent.length - 1);
      jsoncontent += "},";
    }

    jsoncontent = jsoncontent.substring(0, jsoncontent.length - 1);
    String jsonbloc = "{\"TABLEROWS\":[" + jsoncontent + "]}";

    return jsonbloc;
  }

  static List<Map<String, dynamic>> dataRowsFromJSON(
      var jsonTableList, var tableColumnNames) {
    // print ("Requested refresh with dataRowsFrom JSON");
    // CONVERT TO LIST OF MAPS holding the key value pairs
    List<Map<String, dynamic>> tableDataRows = [];

    for (Map jsonItem in jsonTableList) {
      // print ("The json item is $jsonItem");
      var rowDescription = Map<String, dynamic>();
      for (String columnName in tableColumnNames) {
        rowDescription[columnName] = jsonItem[columnName];
      }
      tableDataRows.add(rowDescription);
    }

    return tableDataRows;
  }

  static String getTableListAsCSV(List dataRows, List tableColumns) {
    String csvcontent = tableColumns.toString();

    for (var dRow in dataRows) {
      var dataRow = dRow as Map;
      csvcontent += "\n";
      for (String dkey in dataRow.keys) {
        csvcontent += dataRow[dkey].toString() + ',';
      }
      csvcontent = csvcontent.substring(0, csvcontent.length - 1);
    }

    return csvcontent;
  }

  static String getMapListAsCSV(List<Map> values, List<String> valueNames) {
    String csvcontent = "";

    for (String valueName in valueNames) {
      csvcontent += (valueName + ",");
    }
    csvcontent = csvcontent.substring(0, csvcontent.length - 1);
    csvcontent += "\n";

    for (Map valueMap in values) {
      for (String valueName in valueNames) {
        csvcontent += (valueMap[valueName].toString() + ",");
      }
      csvcontent = csvcontent.substring(0, csvcontent.length - 1);
      csvcontent += "\n";
    }
    csvcontent = csvcontent.substring(0, csvcontent.length - 1);

    return csvcontent;
  }

  static int getInteger(String intvalue) {
    try {
      return int.parse(intvalue);
    } catch (ex) {
      return 0;
    }
  }

  static double getDouble(String doublevalue) {
    try {
      return double.parse(doublevalue);
    } catch (ex) {
      return 0;
    }
  }

  static bool getBoolean(String boolvalue) {
    if (boolvalue.toUpperCase == "TRUE") {
      return true;
    }

    return false;
  }

  static String numPad(int num, int length) {
    String padded = num.toString().padLeft(length, '0');
    return padded;
  }

  static String stringPadWithNumber(String stringItem, int length) {
    String padded = stringItem.padLeft(length, '0');
    return padded;
  }
}
