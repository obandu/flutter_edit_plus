## [0.0.1] - 18 December 2020

This release contains the main widgets below and several helper widgets.
1. Edit Plus Data Table
2. Edit Plus Quick Forms
3. Edit Plus Date Input Text Form Field
4. Embedded within the EditPlus quick forms is the EditPlusFormWidget that allows for parameterised creation of form fields.
   Widgets include TextFormField as TEXTFIELD, DropdownButtonFormField as STRINGDROPDOWN

## [0.0.2] - 21 December 2020

This release ensures direct access of the widgets by only inherting edit_plus dart.
1. For the EditPlusFormWidget, added an onChangeFunction called onchangefunction that allows monitoring of input e.g for text fields.
2. Added support for password input fields under EditPlusFormWidget using obscureText=true with '*' as the obscuring character. Widget is named PASSWORDINPUTFIELD.

## [0.0.3] - 30 December 2020

1. QuickForm widget list can now have standard material widgets and also EditPlusFormWidgets which allows for maximum customisation.
