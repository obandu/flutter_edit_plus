part of edit_plus;

class EditplusTextformField extends StatefulWidget 
{
  final String label;
  final String saveDataKey;
  final Function validationFunction;
  final Function onChangeFunction;
  final Function onSaveFunction;

  EditplusTextformField(
    {@required this.label,
     @required this.saveDataKey,
     this.validationFunction,
     this.onSaveFunction,
     this.onChangeFunction});

  @override
  _EditplusTextformFieldState createState() {
    return _EditplusTextformFieldState();
  }
 
}

class _EditplusTextformFieldState extends State<EditplusTextformField> 
{
  @override
  Widget build(BuildContext context) {
    return TextFormField(
            decoration: InputDecoration(
              labelText:  widget.label,
              border: OutlineInputBorder(),
            ),
            onSaved: widget.onSaveFunction,
            validator: (String value)
            {
              var validationresult = widget.validationFunction(widget.label, value);
              return validationresult;
            },
            onChanged: widget.onChangeFunction,
            autofocus: true,
          );
  }
}