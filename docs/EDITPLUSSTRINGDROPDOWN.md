# The EDITPLUSSTRINGDROPDOWN
The EditPlusStringDropdown is a modification of the material DropDownButton that maintains state.

## USAGE
The constructor takes in 

1. Hint text which is the label for input. This is @required. 
2. A values List which is the list content. Each of the items in this list should be able to return a string value with a toString function. This is @required.
3. A save key, which works with a Quick Form to save data.
4. A validation Function with the signature String f(saveKey, saveData). 
5. A save function. This is optional but would allow the processing of data in the calling application before save.

```dart

  EditPlusStringDropdown(
   valuesList: ['Africa', 'Asia', 'Australia', 'Europe', 'North America', 'South America'],
   hintText: 'PLACE OF BIRTH',
   validationFunction : formValidationFunction,
   onSaveFunction: formSaveFunction,
   saveDataKey: 'PLACEOFBIRTH');

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

  // custom save form.
  void formSaveFunction(var saveDataKey, var saveValue)
  {
    
  }

```

Note that it can also be created as an EditPlusFormWidget of type DROPDOWNBUTTON.

```dart
   EditPlusFormWidget(widgettype:EditPlusFormWidgetTypes.DROPDOWNBUTTON, label:'PLACE OF BIRTH',  savekey:'PLACEOFBIRTH',  validationFunction: formValidationFunction, otherData: ['Africa', 'Asia', 'Australia', 'Europe', 'North America', 'South America']),

```

