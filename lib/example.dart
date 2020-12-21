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
    var widgetDescList = List<EditPlusFormWidget>();

    var textFieldPIN = EditPlusFormWidget(widgettype:'TEXTFIELD', label:'-- PIN --',  savekey:'DEVPIN',  validationfunction:  simpleValidationFunction);
    widgetDescList.add(textFieldPIN);

    var textFieldDATE = EditPlusFormWidget(widgettype:'DATETEXTFIELD', label:'DATE OF BIRTH', savekey:'DOB', validationfunction:  simpleValidationFunction); 
    widgetDescList.add(textFieldDATE);  

    return EditplusQuickform(widgetDescList:widgetDescList, savedValuesMap:saveFormData, formKey:saveFormKey, spacing : 20);
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
