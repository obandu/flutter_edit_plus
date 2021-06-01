part of edit_plus;

class EditplusQuickform extends StatefulWidget
{
  final List widgetDescList;
  final Map dataContainer;
  final GlobalKey formKey;
  final double spacing;

  final Map textEditingControllers = new Map<String, TextEditingController>();

  EditplusQuickform({@required this.widgetDescList, this.dataContainer, @required this.formKey, this.spacing});
   State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EditPlusQuickFormState();
  }


}

class _EditPlusQuickFormState extends State<EditplusQuickform>
{
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: getElements(),
        )
    );
  }

  clearForm()
  { 
    setState(() {
      widget.textEditingControllers.forEach((key, value) 
        { 
          TextEditingController vl = value;
          vl.clear();
        });
    });
  }

  List<Widget> getElements()
  {
    List<Widget> widgetList = [];

    for (var entry in widget.widgetDescList)
    {
      if (entry is EditPlusFormWidget)
      {
        if (entry.widgettype == EditPlusFormWidgetTypes.TEXTINPUTFIELD)
        {
          var tfwidget = TextFormField(
            decoration: InputDecoration(
              labelText:  entry.label,
              border: OutlineInputBorder(),
            ),
            onSaved: (value) 
            {
              getSaveFunction(entry)(entry.savekey, value);
            },
            validator: (String value)
            {
              var validationresult = entry.validationFunction(entry.label, value);
              return validationresult;
            },
            controller: getEditingController(entry.label),
            /* onChanged: (value)
            {
              print("change value is $value");
            } */
          );
          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: widget.spacing,));
          continue;
        } 
        if (entry.widgettype == EditPlusFormWidgetTypes.PASSWORDINPUTFIELD)
        {
          var tfwidget = TextFormField(
            decoration: InputDecoration(
              labelText:  entry.label,
              border: OutlineInputBorder(),
            ),
            onSaved:  (value) 
            {
              getSaveFunction(entry)(entry.savekey, value);
            },
            validator: (String value)
            {
              var validationresult = entry.validationFunction(entry.label, value);
              return validationresult;
            },
            controller: getEditingController(entry.label),
            // onChanged: entry.onChangeFunction,
            obscureText: true,
            obscuringCharacter: "*",
            /* onChanged: (value)
            {
              try {
              print("change value is $value");
              }
              catch (exp)
              {
                print("Error when on change $exp");
              }
            } */
          );
          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: widget.spacing,));
          continue;
        }
        if (entry.widgettype == EditPlusFormWidgetTypes.DATEINPUTFIELD)
        {
          var tfwidget = EditPlusDateInputFormField(
              validationFunction: entry.validationFunction,
              label: entry.label,
              saveDataKey: entry.savekey,
              onSaveFunction: getSaveFunction(entry),
            );

          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: widget.spacing,));
          continue;
        }    
        if (entry.widgettype == EditPlusFormWidgetTypes.DROPDOWNBUTTON)
        {
          print("The values are ${entry.otherData['VALUES']} \n\n and Widgets ${entry.otherData['WIDGETS']}");
          List dataValues = entry.otherData['VALUES'] == null ? [] :  entry.otherData['VALUES'];
          var tfwidget = EditPlusStringDropdown(
            valuesList: dataValues,
            validationFunction: entry.validationFunction,
            hintText: entry.label,
            saveDataKey: entry.savekey,
            onSaveFunction: getSaveFunction(entry),
          );

          List<Widget> otherWidgetList = entry.otherData['WIDGETS'] == null ? [] :  entry.otherData['WIDGETS'];

          if (otherWidgetList.isEmpty)
          {
            widgetList.add(tfwidget);
          }
          else
          {
            List<Widget> allWidgetList = [];
            allWidgetList.add(tfwidget);
            allWidgetList.addAll(otherWidgetList);
            widgetList.add(
              Row (
                children: allWidgetList,
              )
            );
          }
          
          widgetList.add(SizedBox(height: widget.spacing,));
          continue;
        }    
      }
      if (entry is Widget)
      {
        widgetList.add(entry);
        widgetList.add(SizedBox(height: widget.spacing,));
      }

    }
    return widgetList; 
  }

  Function getSaveFunction(EditPlusFormWidget entry)
  {
    if (entry.saveFunction == null)
    {
      return saveFunction;
    }

    return entry.saveFunction;
  }

  /*Function getChangeFunction(EditPlusFormWidget entry)
  {
    if (entry.onChangeFunction == null)
    {
      return saveFunction;
    }

    return entry.saveFunction;
  } */

  void saveFunction(var saveDataKey, var saveValue)
  {
    if (widget.dataContainer != null)
    {
      widget.dataContainer[saveDataKey] = saveValue;
    }
  }

  TextEditingController getEditingController(entryLabel)
  {
    if (widget.textEditingControllers[entryLabel] == null)
    {
      widget.textEditingControllers[entryLabel] == new TextEditingController();
    }

    return widget.textEditingControllers[entryLabel];
  }

}

enum EditPlusFormWidgetTypes {
  DATEINPUTFIELD, TEXTINPUTFIELD, PASSWORDINPUTFIELD, DROPDOWNBUTTON

}

class EditPlusFormWidget
{
  final EditPlusFormWidgetTypes widgettype;
  final String label;
  final String savekey;
  final Function validationFunction;
  final Function saveFunction;
  // final Function onChangeFunction;
  final int size; /// Valid for text inputs which have a maximum size
  final otherData;

  EditPlusFormWidget({@required this.widgettype, @required this.label, @required this.savekey, @required this.validationFunction, this.saveFunction, this.size, this.otherData});
}