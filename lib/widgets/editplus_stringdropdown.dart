part of edit_plus;

class EditPlusStringDropdown extends StatefulWidget {
  final List<dynamic> valuesList;
  final Map<String, dynamic> valueContainer;
  final String hinttext;
  final String validationHint;
  final Map<String, dynamic> saveDataMap;
  final String saveDataKey;

  EditPlusStringDropdown(
      {this.valuesList,
      this.valueContainer,
      this.hinttext,
      this.validationHint,
      this.saveDataMap,
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
        validator: (value) {
          if (value == null) {
            return widget.validationHint;
          }

          // print("String drop down value at validation " + value.toString());
          return null;
        },
        items: widget.valuesList.map<DropdownMenuItem>((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        hint: Text(widget.hinttext),
        decoration: InputDecoration(
          // hintText: "SUBSCRIPTION NAME",
          hintStyle: TextStyle(color: Colors.blueAccent),
          border: OutlineInputBorder(),
        ),
        value: _value,
        onSaved: (savevalue) {
          widget.saveDataMap[widget.saveDataKey] = savevalue;
        });
  }
}
