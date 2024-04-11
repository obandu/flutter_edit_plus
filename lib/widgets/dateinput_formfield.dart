part of edit_plus;

class DateInputFormField extends StatefulWidget {
  final String saveDataKey;
  final label;
  final Function onSaveFunction;
  final Function validationFunction;
  final Function onChangedFunction;
  final String? initialDate;
  final Map formFieldContent = new Map();

  DateInputFormField({
    required this.label,
    required this.validationFunction,
    required this.saveDataKey,
    required this.onSaveFunction,
    required this.onChangedFunction,
    this.initialDate
  });

  @override
  _EditPlusTextFormFieldDatePickerState createState() {
    return _EditPlusTextFormFieldDatePickerState();
  }
}

class _EditPlusTextFormFieldDatePickerState extends State<DateInputFormField> 
{
  TextEditingController _dateInputController = new TextEditingController();
  DateTime dtInitialDate = DateTime.now();

  @override
  Widget build(BuildContext context) 
  {

    if (widget.initialDate != null)
    {
      dtInitialDate = DateFormat('yyyy-MM-dd').parse(widget.initialDate!);
    }

    _dateInputController.text = DateFormat('dd MMMM yyyy').format(dtInitialDate);

    return TextFormField(
        controller: _dateInputController,
        // initialValue: DateFormat('dd MMMM yyyy').format(initialDate),
        decoration: InputDecoration(
          labelText:  widget.label,
          border: OutlineInputBorder(),
        ),
        // enabled: false,
        validator: (value)
        {
          return widget.validationFunction(widget.label, value);
          // return validationresult;
        },
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: dtInitialDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2099),
          ).then((date) {
            if (date == null) { return; }
            try {
              dtInitialDate = date;
              // setState(() {
                _dateInputController.text = DateFormat('dd MMMM yyyy').format(date);
                var saveDate = DateFormat('yyyy-MM-dd').format(date);
                widget.formFieldContent[widget.saveDataKey] = saveDate;
                widget.onChangedFunction(widget.saveDataKey, saveDate);
                
              // });
            } catch (exp) {
              print("Error in DateInputFormField when picking date - " + exp.toString());
            }
          });
        },
        onSaved: (savevalue) {
          widget.onSaveFunction(widget.saveDataKey, widget.formFieldContent[widget.saveDataKey]);
        }
    );
  }
}
