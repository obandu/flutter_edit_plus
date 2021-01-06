part of edit_plus;

enum EditPlusBlocEvent {
  NEWROWEVENT, SAVEROWEVENT, REFRESHTABLEEVENT

}

class EditPlusTableBloc extends Bloc<Map<String, dynamic>, Map<String, dynamic>> 
{
  EditPlusTableBloc():super(new Map<String, dynamic>());  

  

  getEmptyState() {
    var emptyState = Map<String, dynamic>();
    List<Map<String, dynamic>> _emptyDataRows = [];
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
        // List<Map<String, dynamic>> dataRows = newState['DATAROWS'];
        newState['DATAROWS'].addAll(EditPlusUtils.dataRowsFromJSON(eventMap['EVENTDATA'], eventMap['COLUMNNAMES']));
        // newState['DATAROWS'] = dataRows;
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
      default:
        print("Event is " + eventMap.toString());
        break;
    }
  }

}