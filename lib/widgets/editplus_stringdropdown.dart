part of edit_plus;

class EditPlusStringDropdown extends StatefulWidget {
  // List of values for the dropdown. All the classes for the values should have a 'toString' function that yields a string value for the objects
  final List<dynamic> valuesList;

  // valueContainer is useful when working with
  final Map valueContainer;
  final String hintText;
  final String? dropdownName;
  final Function? validationFunction;
  final Function? onSaveFunction;
  final Function? onSelectFunction;
  final String? saveDataKey;

  EditPlusStringDropdown(
      {required this.valuesList,
      required this.hintText,
      required this.valueContainer,
      this.dropdownName,
      this.validationFunction,
      this.onSaveFunction,
      this.saveDataKey,
      this.onSelectFunction});

  @override
  _EditPlusStringdropdownState createState() {
    return _EditPlusStringdropdownState();
  }

  setSelectedValue(var value) {
    if (dropdownName != null) {
      valueContainer[dropdownName] = value;
    } else {
      valueContainer[hintText] = value;
    }

    if (onSelectFunction != null) {
      onSelectFunction!(value);
    }
  }

  get values => valueContainer;

  get instanceCopy => EditPlusStringDropdown(
      valuesList: valuesList,
      hintText: hintText,
      valueContainer: valueContainer);
}

class _EditPlusStringdropdownState extends State<EditPlusStringDropdown> {
  var _value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        elevation: 16,
        style: TextStyle(color: Colors.blueAccent),
        onChanged: (newValue) {
          setState(() {
            _value = newValue;
            widget.setSelectedValue(_value);
          });
        },
        validator: (value) {
          var validationresult =
              widget.validationFunction!(widget.hintText, value.toString());
          return validationresult;
        },
        items: widget.valuesList.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        hint: Text(widget.hintText),
        decoration: InputDecoration(
            constraints: BoxConstraints(maxWidth: 720),
            border: OutlineInputBorder(),
            labelText: widget.hintText),
        value: widget.valueContainer['VALUE'],
        onSaved: (savevalue) {
          widget.onSaveFunction!(widget.saveDataKey, savevalue);
        });
  }
}
