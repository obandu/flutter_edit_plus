part of edit_plus;

enum EditPlusBlocEvent {
  NEWROWEVENT, SAVEROWEVENT, REFRESHTABLEEVENT

}

class EditPlusTableBloc extends Bloc<Map<String, dynamic>, Map<String, dynamic>> 
{
  EditPlusTableBloc():super(new Map<String, dynamic>());  

  var _emptyDataRows = List<Map<String, dynamic>>();

  getEmptyState() {
    var emptyState = Map<String, dynamic>();
    emptyState['DATAROWS'] = _emptyDataRows;
    return emptyState;
  }

  @override
  Stream<Map<String, dynamic>> mapEventToState(
      Map<String, dynamic> eventMap) async* {
    var eventname = eventMap['EVENTNAME'];
    switch (eventname) {
      case EditPlusBlocEvent.NEWROWEVENT:
        var newState = getEmptyState();
        newState.addAll(state);
        newState['NEWROWACTION'] = 'INSERTROW';
        yield newState;
        break;
      case EditPlusBlocEvent.REFRESHTABLEEVENT:
        var newState = getEmptyState();
        newState.addAll(state);
        List<Map<String, dynamic>> dataRows = newState['DATAROWS'];
        dataRows.add(eventMap['EVENTDATA']);
        newState['DATAROWS'] = dataRows;
        yield newState;
        break;        
      case EditPlusBlocEvent.SAVEROWEVENT:
        var newState = getEmptyState();
        newState.addAll(state);
        newState['NEWROWACTION'] = 'SAVEROW';
        List<Map<String, dynamic>> dataRows = newState['DATAROWS'];
        dataRows.add(eventMap['EVENTDATA']);
        newState['DATAROWS'] = dataRows;
        yield newState;
        break;  
        /* case 'RESTRESPONSE':   
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
        break; */
      default:
        print("Event is " + eventMap.toString());
        break;
    }
  }


}