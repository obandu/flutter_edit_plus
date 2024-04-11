# The EDITPLUSDATEINPUTFORMFIELD
The EditPlusDateInputFormField is a composite of the material widgets TextInputFormField and a date picker (as at version 1.5.10).

## BACKGROUND
The objective was to have a simple date picker that displays the date in an anambigous way while at the same time, onSave, it provides the date in the format YYYY-MM-DD that can be directly saved into an SQL database. Different Locales display dates differently so this widget displays the date in long format dd MMMM yyyy

## FUNCTIONS
This is a simple date picker that can be function as a child of a Material form supporting form validation and form saving. As at version 1.5.10 it only has minimal decoration.

It takes in 4 mandatory inputs
1. A label which shows as the input prompt
2. A saveDataKey which is a data label used to return data onSave or onValidate to the calling application.
3. A validation function, this can be implemented separately or inline as shown in the example below. The widget passes in the value held by the TextFormField and the saveDataKey which tells the calling application the DateInputFormField that generated the validation request. 
4. A save function that is like the validation function above and is called by the Material form.save function. It passes a saveDataKey and the date value in the form of YYYY-MM-DD that can be directly used

## SAMPLE DATEINPUTFORMFIELD CONTAINING WIDGET
The code below can be copied and used as home screen in your main application as the home widget in a Material App.
```dart
import 'package:edit_plus/edit_plus.dart';
import 'package:flutter/material.dart';

class EditplusDateInputExampleHomePage extends StatelessWidget
{
  final List<String> tableColumnNames = [];

  Widget build(BuildContext context)
  {
    GlobalKey _formKey = new GlobalKey();
      return Scaffold(
      appBar: AppBar(
        title: Text("DATE INPUT EXAMPLES"),
      ),
      body: Center
      (
        child: Container
        (
          width: 600,
          padding: EdgeInsets.all(5),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Text("Date input with external validation and save functions"),
                  SizedBox(height: 30.0),
                  EditPlusDateInputFormField(
                    label: "Payment Date",
                    validationFunction: validationFunction,
                    onSaveFunction: saveFunction,
                    saveDataKey: 'PAYDATE'
                  ),
                  SizedBox(height: 30.0),
                  Text("Date input with inline validation and save functions"),
                  SizedBox(height: 30.0),
                  EditPlusDateInputFormField(
                    label: "Date of Birth",
                    validationFunction: (var saveDataKey, String value)
                    {
                      if (value == null || value.isEmpty)
                      {
                        return "Please select a date of birth";
                      }
                      else
                      {
                        return null;
                      }
                    },
                    onSaveFunction: (var saveDataKey, String saveValue)
                    {
                      print ("The data to save for $saveDataKey is $saveValue");
                    },
                    saveDataKey: 'BIRTHDATE'
                  ),
                  SizedBox(height: 30.0),
                  Text("Simple button to trigger form save"),
                  SizedBox(height: 30.0),
                  RaisedButton(
                    onPressed:()
                    { 
                      _processForm(_formKey);
                    },
                    child: Text("Press to SAVE"),
                  ), 
               ]
                )
              )
          )
      )
      )
    );
  }

  // Process form function specific to your application that responds to button press on your form
  // this triggers the form.save function which then triggers the DateInputFormField to call the save 
  // function in your application
  void _processForm(var saveFormKey)
  {
    final saveform = saveFormKey.currentState;
    if (saveform.validate()) {
      saveform.save();
    }
  }


  // save function as expected by the EditPlusDateInputFormField. It is called by the widget which
  // in turn is triggered by the form.save function in the parent form.
  // it takes in a key that indicates which field it is returning data and the value and allows
  // flexibility on how to handle the data onSave() with the posibility of using one function to save data
  // from multiple widgets. Note that a standard TextFormField save function only takes a string value
  void saveFunction (var saveDataKey, String saveValue)
  {
    print ("The data to save for $saveDataKey is $saveValue");
  }

  // validation function as expected by the EditPlusDateInputFormField. It is called by the widget which
  // in turn is triggered by the form.save function in the parent form.
  // it takes in a key that indicates which field it is returning data and the value and allows
  // flexibility on how to handle the data onSave() with the posibility of using one function to validate
  // multiple widgets. Note that a standard TextFormField validator function only takes a string value
  // and returns a string value with error message or null if it validates
  String validationFunction(var saveDataKey, String value)
  {
    if (value == null || value.isEmpty)
    {
      return "Please tap on the text field $saveDataKey select a date";
    }
    else
    {
      return null;
    }
  }
}

```