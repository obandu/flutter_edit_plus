part of edit_plus;

class EditplusQuickform extends StatelessWidget
{
  final List widgetDescList;
  final Map dataContainer;
  final GlobalKey formKey;
  final double spacing;

  EditplusQuickform({this.widgetDescList, this.dataContainer, this.formKey, this.spacing});

  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: getElements(),
        )
    );
  }

  List<Widget> getElements()
  {
    var widgetList = List<Widget>();

    for (var entry in widgetDescList)
    {
      if (entry is EditPlusFormWidget)
      {
        if (entry.widgettype == 'TEXTFIELD')
        {
          var tfwidget = TextFormField(
            decoration: InputDecoration(
              labelText:  entry.label,
              border: OutlineInputBorder(),
            ),
            onSaved: (String value) {
              dataContainer[entry.savekey] = value;
            },
            validator: entry.validationfunction,
            onChanged: entry.onchangefunction,
          );
          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: spacing,));
          continue;
        }
        if (entry.widgettype == 'PASSWORDINPUTFIELD')
        {
          var tfwidget = TextFormField(
            decoration: InputDecoration(
              labelText:  entry.label,
              border: OutlineInputBorder(),
            ),
            onSaved: (String value) {
              onSavedFunction(entry.savekey, value);
            },
            validator: entry.validationfunction,
            onChanged: entry.onchangefunction,
            obscureText: true,
            obscuringCharacter: "*",
          );
          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: spacing,));
          continue;
        }
        if (entry.widgettype == 'DATEINPUTFIELD')
        {
          var tfwidget = EditPlusDateInputFormField(
              controller: new TextEditingController(),
              validationFunction: entry.validationfunction,
              label: entry.label,
              saveDataKey: entry.savekey,
              onSaveFunction: onSavedFunction,
              // formDataContainer: dataContainer,
            );

          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: spacing,));
          continue;
        }    
        if (entry.widgettype == 'DROPDOWNLIST')
        {
          var tfwidget = EditPlusStringDropdown(
              valuesList: entry.otherData,
              validationFunction: entry.validationfunction,
              hintText: entry.label,
              saveDataKey: entry.savekey,
              onSaveFunction: onSavedFunction,
              // formDataContainer: dataContainer,
            );

          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: spacing,));
          continue;
        }    
      }
      if (entry is Widget)
      {
        widgetList.add(entry);
      }

    }
    
    return widgetList;
  }

  onSavedFunction(var key, var value)
  {
    dataContainer[key] = value;
  }

}

class EditPlusFormWidget
{
  final String widgettype;
  final String label;
  final String savekey;
  final Function validationfunction;
  final Function onchangefunction;
  final int size; /// Valid for text inputs which have a maximum size
  final otherData;

  EditPlusFormWidget({this.widgettype, this.label, this.savekey, this.validationfunction, this.onchangefunction, this.size, this.otherData});
}