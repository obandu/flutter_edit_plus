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
}