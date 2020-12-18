import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditplusQuickform extends StatelessWidget
{
  final List<EditPlusFormWidget> widgetDescList;
  final Map savedValuesMap;
  final GlobalKey formKey;
  final double spacing;

  EditplusQuickform({this.widgetDescList, this.savedValuesMap, this.formKey, this.spacing});

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

    for (EditPlusFormWidget entry in widgetDescList)
    {
      if (entry.widgettype == 'TEXTFIELD')
      {
        var tfwidget = TextFormField(
          decoration: InputDecoration(
            labelText:  entry.label,
            border: OutlineInputBorder(),
          ),
          onSaved: (String value) {
            savedValuesMap[entry.savekey] = value;
          },
          validator: entry.validationfunction,
        );
        widgetList.add(tfwidget);
        widgetList.add(SizedBox(height: spacing,));
        continue;
      }

    }
    
    return widgetList;
  }

}

class EditPlusFormWidget
{
  final String widgettype;
  final String label;
  final String savekey;
  final Function validationfunction;

  EditPlusFormWidget({this.widgettype, this.label, this.savekey, this.validationfunction});
}