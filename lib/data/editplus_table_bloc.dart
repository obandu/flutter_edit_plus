part of edit_plus;

class EditPlusTableBloc extends Bloc<Map<String, dynamic>, Map<String, dynamic>> 
{
  EditPlusTableBloc():super(new Map<String, dynamic>());  

  var _persistenceInfo;
  // @override
  // Map<String, dynamic> get initialState => new Map<String, dynamic>();

  var _emptyDataRows = List<Map<String, dynamic>>();

  getEmptyState() {
    var emptyState = Map<String, dynamic>();
    emptyState['DATAROWS'] = _emptyDataRows;
    return emptyState;
  }

  @override
  Stream<Map<String, dynamic>> mapEventToState(
      Map<String, dynamic> eventMap) async* {
    String eventname = eventMap['EVENTNAME'];
    switch (eventname) {
      case 'NEWROWEVENT':
        if (isloading == true) {
          return;
        }
        var newState = getEmptyState();
        newState.addAll(state);
        newState['NEWROWACTION'] = 'INSERTROW';
        yield newState;
        break;
      case 'REFRESHTABLEEVENT':
        // determine persistence method and persist if persistence method exists
        if (eventMap.containsKey("PERSISTENCEDATA"))
        {
          Map persistenceData = eventMap['PERSISTENCEDATA'];
          _addPersistenceInfo("PERSISTENCEDATA", persistenceData);
          _reload();
        }
        break;        
      case 'SAVEROWEVENT':
        // print("yayseee you asked to save " + eventMap.toString() + "\n ${eventMap['EVENTDATA']}");
        if (isloading == true) {
          return;
        }
        var newState = getEmptyState();
        newState.addAll(state);
        newState['NEWROWACTION'] = 'SAVEROW';
        List<Map<String, dynamic>> dataRows = newState['DATAROWS'];

        dataRows.add(eventMap['EVENTDATA']);
        // print("data rows in is now $dataRows");
        newState['DATAROWS'] = dataRows;
        yield newState;

        // determine persistence method and persist if persistence method exists
        if (eventMap.containsKey("PERSISTENCEDATA"))
        {
          Map persistenceData = eventMap['PERSISTENCEDATA'];
          _addPersistenceInfo("PERSISTENCEDATA", persistenceData);
          _persist();
        }
        break;  
      case 'RESTRESPONSE':   
        var eventData = eventMap['EVENTDATA'];
        // print("It is a RESTRESPONSE and data is \n $eventData");
        var otherParams = eventMap['OTHERPARAMS'];
        try {
          String tableContentName = eventMap['TABLECONTENTNAME'];

          // get the table content (response.body) as JSON object
          Map<String, dynamic> restResponseJSON = jsonDecode(eventData);

          var tableList = restResponseJSON[tableContentName] as List;
          // print("The table list is is \n $tableList  && $tableContentName  && ${otherParams}");

          if (tableList.isNotEmpty)
          {
            var item1 = tableList.first;
            print("The first item in the table list is is \n $item1");
          }
          var newState = getEmptyState();
          // newState.addAll(state);
          // newState['NEWROWACTION'] = 'SAVEROW';
          // List<Map<String, dynamic>> dataRows = newState['DATAROWS'];
          // dataRows.add(eventMap['EVENTDATA']);

          // print("data rows in is now $dataRows");
          newState['DATAROWS'] = tableList;
          yield newState;

        } catch (exp) {
          print("System error at mapEventToState.GETCOMPANYSUBSCRIPTIONSSDATA. Please contact developer with information below:\n $exp");
        }
        break;
      default:
        print("Event is " + eventMap.toString());
        break;
    }
  }

  void _addPersistenceInfo(String key, dynamic value)
  {
    if (_persistenceInfo == null)
    {
      _persistenceInfo = Map<String, dynamic>();
    }
    _persistenceInfo[key] = value;
  }

  bool isloading = false;

  void _persist()
  {
    // print("Persistence info is now $_persistenceInfo");
    Map persistenceData = _persistenceInfo['PERSISTENCEDATA'];
    String persistenceMethod = persistenceData['PERSISTENCEMETHOD'];
    if (persistenceMethod == "REST")
    {
      // get REST endpoint from persistenceInfo
      String restEndPoint = persistenceData['RESTENDPOINT'];

      // get REST base URL
      String restBaseURL = persistenceData['RESTBASEURL'];

      // get table data as REST BODY
      String restBody = getTableListAsJSON();

      // get the table content name
      String tableContentName = persistenceData['TABLECONTENTNAME'];

      var restBodyMap = Map();
      restBodyMap['DATA'] = restBody;
      restBodyMap['ACTION'] = "SAVETABLE";
      // print ("The REST body is\n $restBodyMap");
      _restExecute(restBaseURL, restEndPoint, restBodyMap, tableContentName);
    }
  }

  void _reload()
  {
    // print("Persistence info is now $_persistenceInfo");
    Map persistenceData = _persistenceInfo['PERSISTENCEDATA'];
    String persistenceMethod = persistenceData['PERSISTENCEMETHOD'];
    if (persistenceMethod == "REST")
    {
      // get REST endpoint from persistenceInfo
      String restEndPoint = persistenceData['RESTENDPOINT'];

      // get REST base URL
      String restBaseURL = persistenceData['RESTBASEURL'];

      // get the table content name
      String tableContentName = persistenceData['TABLECONTENTNAME'];

      var restParams = Map();
      restParams['ACTION'] = "LOADTABLE";
      restParams.addAll(persistenceData['OTHERPARAMS']);
      // print ("The REST body is\n $restBodyMap");
      _restExecute(restBaseURL, restEndPoint, restParams, tableContentName);
    }
  }  

  void _restExecute(String restBaseURL, String endPoint, Map restParams, String tableContentName) async
  {
    final response = await http.post('$restBaseURL/$endPoint', body: restParams);
    // print("Response body is " + response.body);

    var returnEventMap = new Map<String, dynamic>();
    returnEventMap["EVENTNAME"] = "RESTRESPONSE";
    returnEventMap['EVENTDATA'] = response.body;
    returnEventMap['OTHERPARAMS'] = restParams;
    returnEventMap['TABLECONTENTNAME'] = tableContentName;
    add(returnEventMap);
    if (response.statusCode == 200) {
      // return true;
    } else {
      // return false;
   }
  }

  String getTableListAsJSON()
  {
    String jsoncontent = "";

    for (Map dataRow in state['DATAROWS'])
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