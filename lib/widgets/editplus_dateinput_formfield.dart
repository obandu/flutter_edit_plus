part of edit_plus;

class EditPlusDateInputFormField extends StatefulWidget {
  final String saveDataKey;
  final TextEditingController controller = new TextEditingController();
  final label;
  final Function onSaveFunction;
  final Function validationFunction;
 
  final Map formFieldContent = new Map();

  EditPlusDateInputFormField({
    @required this.label,
    @required this.validationFunction,
    @required this.saveDataKey,
    @required this.onSaveFunction
  });

  @override
  _EditPlusTextFormFieldDatePickerState createState() {
    return _EditPlusTextFormFieldDatePickerState();
  }
}

class _EditPlusTextFormFieldDatePickerState extends State<EditPlusDateInputFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText:  widget.label,
          border: OutlineInputBorder(),
        ),
        validator: (String value)
        {
          var validationresult = widget.validationFunction(widget.saveDataKey, value);
          return validationresult;
        },
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2099),
          ).then((date) {
            if (date == null) { return; }
            try {
              setState(() {
                widget.controller.text =
                    DateFormat('dd MMMM yyyy').format(date);
                widget.formFieldContent[widget.saveDataKey] = DateFormat('yyyy-MM-dd').format(date);
              });
            } catch (exp) {
              print("Error in EditPlusTextFormFieldDatePickerState when picking date - " + exp.toString());
            }
          });
        },
        onSaved: (savevalue) {
          widget.onSaveFunction(widget.saveDataKey, widget.formFieldContent[widget.saveDataKey]);
        });
  }
}
