# The EDITPLUSFORMWIDGET
The EditPlusFormWidget is a widget generator used with Edit for quickly adding inputs into forms especially where the inputs are of a simple nature e.g. TextFormField, DateInputFormField or DropDownButton that maintains state.

## BACKGROUND
The EditPlusFormWidget is a widget definition for common Material widgets used in forms. It is a child of [EditplusQuickform](./EDITPLUSQUICKFORM.md) which is then responsible for turning the definition into a visible widget.

## USAGE
The constructor takes in 
1. Widgettype, an enum value from the class EditPlusFormWidgetTypes. This is @required. 
   With this version the supported values are :
   DATEINPUTFIELD => corresponding to an EditPlusDateInputField
   TEXTINPUTFIELD => corresponding to a TextFormField
   PASSWORDINPUTFIELD => corresponding to TextFormField with obscured text
   DROPDOWNBUTTON => corresponding to an EditPlusStringDropdown
2. A string label which is the prompt text to be displayed for input. This is @required.
3. A save key, which works with the Quick Form to save data. This is @required.
4. A validation Function with the signature String f(saveKey, saveData). This is @required.
5. A save function. This is optional but would allow the processing of data in the calling application before save.
6. An onChange function. This is optional but can allow for the processing of data on input. For example allow application to react on entering 4-digit PIN.
7. A size value. This is valid for text inputs with a maximum size e.g. TextFormField. At current version, this is not yet used.
8. Other data. This is any other data for form field. For example the drop down button will have its values in a list as other data.

