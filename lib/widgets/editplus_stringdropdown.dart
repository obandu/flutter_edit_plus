part of edit_plus;

class EditPlusStringDropdown extends StatefulWidget {
  final List<dynamic> valuesList;
  final valueContainer = new Map<String, dynamic>();
  final String hintText;
  final Function validationFunction;
  final Function onSaveFunction;
  final String saveDataKey;

  EditPlusStringDropdown(
      {@required this.valuesList,
       @required this.hintText,
      this.validationFunction,
      this.onSaveFunction,
      this.saveDataKey});

  @override
  _EditPlusStringdropdownState createState() {
    return _EditPlusStringdropdownState();
  }

  setSelectedValue(var value) {
    valueContainer['VALUE'] = value;
  }

  get values => valueContainer; 
}

class _EditPlusStringdropdownState extends State<EditPlusStringDropdown> {
  var _value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        elevation: 16,
        style: TextStyle(color: Colors.blueAccent),
        onChanged: (newValue) {
          setState(() {
            _value = newValue;
            widget.setSelectedValue(_value);
          });
        },
        validator: (value)
        {
          var validationresult = widget.validationFunction(widget.hintText, value.toString());
          return validationresult;
        },
        items: widget.valuesList.map<DropdownMenuItem>((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        hint: Text(widget.hintText),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        value: _value,
        onSaved: (savevalue) {
          widget.onSaveFunction(widget.saveDataKey, savevalue);
        });
  }
}
