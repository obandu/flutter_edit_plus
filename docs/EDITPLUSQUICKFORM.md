# The EDITPLUSQUICKFORM
The EditPlusQuickForm is a Material Form widget that takes in [EditPlusFormWidget](./EDITPLUSFORMWIDGET.md) widget definitions and creates a form with widgets that support validation and saving. This is useful to create simple forms that are of a uniform appearance.

## BACKGROUND
Most of the time input forms require a simple design to perform the function of entering data, validating data as either correct or available and saving the data to the form state. This widget allows easy composing of forms by entering widgets by name and type.

It requires as parameters
A List of Widgets. These are either standard Material Widgets or EditPlusFormWidget. This is @requied
A data container which is a Map of key value pairs containing the data from the form fields
A GlobalKey to act as the form key. This is @required
A spacing value defining the vertical space between form widgets

## FORM CREATION
The form is constructed (composed) of the widgets. The widgets are either already constructed Material form widgets or a description of the widgets using an EditPlusFormWidget. The use of an EditPlusFormWidget saves space and makes the form more readable as can be seen in the code below combining 4 EditPlusWidget and one TextFormField widget. 

Further information on widget creation and validation can be seen in the documentation for the [EditPlusFormWidget](./EDITPLUSFORMWIDGET.md)

You can copy and paste the code below and run it directly.

```dart
import 'package:edit_plus/edit_plus.dart';
import 'package:flutter/material.dart';

class EditplusQuickFormHomeScreen extends StatelessWidget
{

  Widget build(BuildContext context)
  {
    // Reference used to access form for validation and save
    final _formKey = GlobalKey<FormState>();

    // container of form data made of key value pairs
    final _saveFormData = Map<String, dynamic>();

    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT PLUS QUICK FORM EXAMPLE"),
      ),
      body: Center
      (
        child: Container
        (
          width: 600,
          padding: EdgeInsets.all(5),
          child: Form (
            child: ListView (

              children:
              [
                Text("Please enter or select values in the inputs below and then CONFIRM DATA to validate and save."), 
                SizedBox (height: 5,),
                // FORM WITH LIST OF DIFFERENT WIDGETS (EDITPLUS WIDGET ALL FIT INTO ONE LINE EACH)
                EditplusQuickform(
                  widgetDescList:[
                    EditPlusFormWidget(widgettype:EditPlusFormWidgetTypes.TEXTINPUTFIELD, label:'USER NAME',  savekey:'USERNAME',  validationFunction: formValidationFunction),  
                    EditPlusFormWidget(widgettype:EditPlusFormWidgetTypes.PASSWORDINPUTFIELD, label:'PASSWORD',  savekey:'DEVPASSWORD',  validationFunction: formValidationFunction),
                    EditPlusFormWidget(widgettype:EditPlusFormWidgetTypes.DROPDOWNBUTTON, label:'PLACE OF BIRTH',  savekey:'PLACEOFBIRTH',  validationFunction: formValidationFunction, otherData: ['Africa', 'Asia', 'Australia', 'Europe', 'North America', 'South America']),
                    EditPlusFormWidget(widgettype:EditPlusFormWidgetTypes.DATEINPUTFIELD, label:'DATE OF BIRTH',  savekey:'DATEOFBIRTH',  validationFunction: formValidationFunction),

                    Text("The standard widget below is able to use independent decoration and requires independent call to validation and save function. Validation and save are however triggerd by the form save call."), 
                    SizedBox (height: 5,),     
                    TextFormField
                    (
                     validator: (String value)
                     {
                       return formValidationFunction("COMMENTS", value);
                     },
                     onSaved :(String value)
                     {
                       _saveFormData['COMMENTS'] = value;
                     },
                     decoration: InputDecoration(
                        labelText: "COMMENTS",
                        hintText: "Your comments",
                        suffix: IconButton(
                           icon: Icon(Icons.check_circle),
                           onPressed: () {},
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                     ),
                    ),
                  ], 
                  dataContainer : _saveFormData, 
                  formKey: _formKey, 
                  spacing : 5),
                  SizedBox (height: 5,),
                  // BUTTON TO TRIGGER FORM VALIDATION AND SAVING. THE DATA COLLECTED IS IN THE 
                  RaisedButton(
                    onPressed:()
                    { 
                      final saveform = _formKey.currentState;
                      if (saveform.validate()) {
                        saveform.save();
                        print("Save result is $_saveFormData");
                      }
                    },
                    child: Text("CONFIRM DATA"),
                  )
              ],
            )
          )
        )
      )
    );
  }

  /// Sample form validation function that can be used by multiple form widgets
  String formValidationFunction(var saveDataKey, String value)
  {
    if (value == null || value.isEmpty)
    {
      return "Please tap on the text field $saveDataKey enter or select a value";
    }
    else
    {
      return null;
    }
  } 
}

```

## SAVING THE DATA
As shown in the sample code above and below. To save data, a call is made to validate the form after which a call is made to save the form. Data is stored in the data container map and can thus be access for further processing. Note that the data container is not required but if not given then each form widget must handle saving separately or not data entered will be saved.

```dart

  // VALIDATE ENTRIES BEFORE SAVING
  RaisedButton(
    onPressed:()
    { 
      final saveform = _formKey.currentState;
      if (saveform.validate()) {
        saveform.save();
        print("Save result is $_saveFormData");
      }
    },
    child: Text("CONFIRM DATA"),
  )
```