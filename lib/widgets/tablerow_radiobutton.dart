part of edit_plus;

class TableRowRadioButton extends StatefulWidget
{
  final Map<String, dynamic> rowState;
  final DataRow dataRow;

  TableRowRadioButton (this.rowState, this.dataRow);

  @override
  _RowRadioButtonState createState() 
  {
    rowState["SELECTED"] = false;
    return _RowRadioButtonState();
  }

}

class _RowRadioButtonState extends State<TableRowRadioButton>
{
  bool groupvalue;

  @override
  Widget build(BuildContext context) {
    var rowsel = widget.rowState["SELECTED"];
    print("ROWSELVALUE is $rowsel AND ROWSTATE ${widget.rowState}");
    if (rowsel == null) rowsel = false;
    return Radio(
      value: rowsel,
      groupValue: "MYTABLE",
      onChanged: (value)
      {
        print("radio button Change value is $value");
        setState(()
        {
          widget.rowState["SELECTED"] = value;
          // widget.groupvalue = value;
        });
      },
    );
  }

}