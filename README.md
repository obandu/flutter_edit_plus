# The edit_plus flutter package

A flutter package containing material widgets enhanced or composited for convenient use in forms or input pages. The widgets can be used with both Stateless and Stateful (forms) widgets and include.

1. [EditPlusDataTable](./docs/EDITPLUSDATATABLE.md) - Data table that can be used in read only or read-write mode to display table content from various sources. Currently only from REST data sources. It uses a specific BLOC [flutter_bloc package] to create and save rows - essentially create and maintain its state. It can therefore be engineered to work with data on file systems or firebase firestore databases. 
2. [EditPlusDateInputFormField](./docs/EDITPLUSDATEINPUTFORMFIELD.md) - TextFormField from the material library composited with a date picker for easy date entry in form fields. It supports form validation. It has initial date as current date, first date as 1900 and last date as 2099
3. [EditplusQuickform](./docs/EDITPLUSQUICKFORM.md) - A class that quickly composes forms based on input widgets of named types and default values. It can generate input widgets from composition or take in standard input form widgets. Data is collected into a map object with key-value pairs representing each input widget.
4. [EditPlusFormWidget](./docs/EDITPLUSFORMWIDGET.md) - A widget that defines simple input form widgets that support form validation and save.
4. [EditPlusStringDropdown](./docs/EDITPLUSSTRINGDROPDOWN.md) - A modification of the Material DropdownButton widget that maintains state after selection.


