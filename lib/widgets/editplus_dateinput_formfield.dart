part of edit_plus;

class EditPlusDateInputFormField extends StatefulWidget {
  // final DateTime initialDate, firstDate, lastDate;
  final String saveDataKey;
  final TextEditingController controller;
  final label;
  final Function onSaveFunction;
  final Function validationFunction;

  EditPlusDateInputFormField({
    this.controller,
    this.label,
    this.validationFunction,
    this.saveDataKey,
    this.onSaveFunction
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
        // enabled: false,
        decoration: InputDecoration(
          labelText:  widget.label,
          border: OutlineInputBorder(),
        ),
        validator: widget.validationFunction,
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2099),
            // barrierDismissible: false,
          ).then((date) {
            try {
              setState(() {
                widget.controller.text =
                    DateFormat('dd MMMM yyyy').format(date);
                // widget.formDataContainer[widget.saveDataKey] = DateFormat('yyyy-MM-dd').format(date);
                widget.onSaveFunction(widget.saveDataKey, DateFormat('yyyy-MM-dd').format(date));
              });
            } catch (exp) {
              // print("Error at date picker - " + exp.toString());
            }
          });
        },
        onChanged: (value) {
          // print("There was a change in date $value");
        },
        onSaved: (savevalue) {
          // print("Controller text date is  $savevalue");
          widget.onSaveFunction(widget.saveDataKey, savevalue);
        });
  }
}
