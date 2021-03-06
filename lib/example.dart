import 'package:edit_plus/edit_plus.dart';
import 'package:flutter/material.dart';


class ExampleApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EDIT PLUS EXAMPLE APP",
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget
{

  Widget build(BuildContext context)
  {
    // Reference used to access form for validation and save
    final _formKey = GlobalKey<FormState>();

    // content of form onsave made of key value pairs
    final _saveFormData = Map<String, dynamic>();

    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT PLUS EXAMPLE APP"),
      ),
      body: Center
      (
        child: Container
        (
          width: 600,
          padding: EdgeInsets.all(12),
          child: Form (
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:
              [
                Text("Please note that the initial device PIN is 6 digits 000000. After that you will need to change it."), 
                _testForm(_formKey, _saveFormData),
                _buttonBar(_formKey, _saveFormData),
              ],
            )
          )
        )
      )
    );
  }


  // The actual form
  Widget _testForm(var saveFormKey, var saveFormData)
  {
    List<EditPlusFormWidget> widgetDescList = [];

    var textFieldPIN = EditPlusFormWidget(widgettype : EditPlusFormWidgetTypes.TEXTINPUTFIELD, label:'-- PIN --',  savekey:'DEVPIN',  validationFunction:  simpleValidationFunction);
    widgetDescList.add(textFieldPIN);

    var textFieldDATE = EditPlusFormWidget(widgettype: EditPlusFormWidgetTypes.DATEINPUTFIELD, label:'DATE OF BIRTH', savekey:'DOB', validationFunction:  simpleValidationFunction); 
    widgetDescList.add(textFieldDATE);  

    return EditplusQuickform(widgetDescList:widgetDescList, dataContainer:saveFormData, formKey:saveFormKey, spacing : 20);
  }

  // this particular button bar has a button that saves the form content
  ButtonBar _buttonBar(var saveFormKey, var saveFormData)
  {
    return ButtonBar(
      buttonTextTheme: ButtonTextTheme.normal,
      buttonPadding: EdgeInsets.all(20.0),
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            final saveform = saveFormKey.currentState;
            if (saveform.validate()) {
              saveform.save();
              print("Save result is $saveFormData");
            }
          },
          child: Text("SAVE DATA"),
        ),
      ]
    );
  }

  // a validation function used with form widgets that require validation
  String simpleValidationFunction(var value)
  {
    if (value.isEmpty) {
      return 'Please enter some data';
    }

    return null;
  }
}


        /*if (entry.widgettype == EditPlusFormWidgetTypes.TEXTINPUTFIELD)
        {
          var tfwidget = EditplusTextformField(
            label: entry.label, 
            saveDataKey: entry.savekey, 
            validationFunction : (String value)
            {
              var validationresult = entry.validationFunction(entry.label, value);
              return validationresult;
            },
            onSaveFunction : (value) 
            {
              getSaveFunction(entry)(entry.savekey, value);
            },
            onChangeFunction: entry.onChangeFunction,
          );
          widgetList.add(tfwidget);
          widgetList.add(SizedBox(height: spacing,));
          continue;
        } */