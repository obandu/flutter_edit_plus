## [0.1.1] - 08 February 2021
1. Updates to EditPlusDateInputFormField to include possibility for onChangeFunction called when changes made even if widget is not part of a form. Function takes in widget key (name) and date (value)

## [0.1.0] - 22 January 2021
1. Updates to TextFormField to fix bugs.

## [0.0.9] - 16 January 2021
1. Stable API for the EditplusQuickForm, EditPlusFormWidget, EditPlusDateInput, EditPlusStringDropdown and associated documentation including full example.

## [0.0.8] - 15 January 2021
1. Stable API for the EditplusDateInputFormField and matching documentation including full example widget.

## [0.0.7] - 09 January 2021
1. Bug fixes and performance improvements for EditPlusTable.
2. Interface finalized for EditPlusTable. Constructor requires label, column names, refresh function and whether or not table is editable. 
   Optionally, field editors from the edit_plus library are accepted for new row inputs.

## [0.0.6] - 04 January 2021
1. Null safety for the EditPlusTable.
2. Improvements and bug fixes for EditPlusTable.

## [0.0.5] - 04 January 2021
1. Added the ability to refresh table from REST source. REST source must have list of JSON items with matching tableName values. Excess values will not be picked.

## [0.0.4] - 01 January 2021
1. Changes to design of the EditPlusTableBloc and separation of JSON processing into the EditPlusUtils class.
2. Direct REST connection removed from BLOC, now to be handled within the end-user applications.

## [0.0.3] - 30 December 2020
1. QuickForm widget list can now have standard material widgets and also EditPlusFormWidgets which allows for maximum customisation.

## [0.0.2] - 21 December 2020
This release ensures direct access of the widgets by only inherting edit_plus dart.
1. For the EditPlusFormWidget, added an onChangeFunction called onchangefunction that allows monitoring of input e.g for text fields.
2. Added support for password input fields under EditPlusFormWidget using obscureText=true with '*' as the obscuring character. Widget is named PASSWORDINPUTFIELD.

## [0.0.1] - 18 December 2020
This release contains the main widgets below and several helper widgets.
1. Edit Plus Data Table
2. Edit Plus Quick Forms
3. Edit Plus Date Input Text Form Field
4. Embedded within the EditPlus quick forms is the EditPlusFormWidget that allows for parameterised creation of form fields.
   Widgets include TextFormField as TEXTFIELD, DropdownButtonFormField as STRINGDROPDOWN

