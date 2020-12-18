import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPlusTextFormFieldDatePicker extends StatefulWidget {
  final DateTime initialDate, firstDate, lastDate;
  final Map<String, dynamic> saveDataMap;
  final String saveDataKey;
  final TextEditingController controller;
  final TextStyle style;
  final hintText;
  final BuildContext context;
  final validationText;

  EditPlusTextFormFieldDatePicker({
    this.controller,
    this.style,
    this.hintText,
    this.context,
    this.validationText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.saveDataMap,
    this.saveDataKey,
  });

  @override
  _EditPlusTextFormFieldDatePickerState createState() {
    return _EditPlusTextFormFieldDatePickerState();
  }
}

class _EditPlusTextFormFieldDatePickerState extends State<EditPlusTextFormFieldDatePicker> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.controller,
        style: widget.style,
        // enabled: false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.blueAccent),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return widget.validationText;
          } else {
            // print('payment date value is  $value');
          }
          return null;
        },
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: widget.initialDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            // barrierDismissible: false,
          ).then((date) {
            try {
              setState(() {
                widget.controller.text =
                    DateFormat('dd MMMM yyyy').format(date);
                widget.saveDataMap[widget.saveDataKey] =
                    DateFormat('yyyy-MM-dd').format(date);
              });
            } catch (exp) {
              print("Error at date picker - " + exp.toString());
            }
          });
        },
        onChanged: (value) {
          print("There was a change in date $value");
        },
        onSaved: (savevalue) {
          // widget.saveDataMap[widget.saveDataKey] =  widget.storevalue['STOREDATE'];
        });
  }
}
