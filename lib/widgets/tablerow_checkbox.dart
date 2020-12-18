part of edit_plus;

class TableRowCheckBox extends StatefulWidget
{
  final Map<String, dynamic> rowState;
  final DataRow dataRow;

  TableRowCheckBox (this.rowState, this.dataRow);

  Map row_state() => rowState;

  @override
  _TableRowCheckBoxState createState() 
  {
    rowState["SELECTED"] = false;
    return _TableRowCheckBoxState();
  }

}

class _TableRowCheckBoxState extends State<TableRowCheckBox>
{
  @override
  Widget build(BuildContext context) {
    var rowsel = widget.rowState["SELECTED"];
    // print("ROWSELVALUE is $rowsel AND ROWSTATE ${widget.rowState}");
    if (rowsel == null) rowsel = false;
    return Checkbox(
      value: rowsel,
      onChanged: (value)
      {
        // print("Change value is $value");
        setState(()
        {
          widget.rowState["SELECTED"] = value;
        });
      },
    );
  }

}