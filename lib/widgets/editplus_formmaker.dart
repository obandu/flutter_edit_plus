part of edit_plus;

class EditplusFormMaker {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [],
      ),
    );
  }

  bool validate() {
    return false;
  }

  Widget renderForm(String formBody) {
    var formStructure = evaluateForm(formBody);
    var formItems = <Widget>[];

    // get FormName and return it (this is usually the first element)
    var formName = (formStructure["FORMNAME"] == null)
        ? "NO FORM NAME DEFINED"
        : formStructure["FORMNAME"];
    formItems.add(EditPlusUiUtils.getBoldLabelText(formName));

    List formElements =
        (formStructure["ELEMENTS"] == null) ? [] : formStructure["ELEMENTS"];

    for (var formElement in formElements) {
      if (formElement["TYPE"] == null) {
        continue;
      } else if (formElement["TYPE"] == "SPACE") {
        formItems.add(SizedBox(
          height: 10,
        ));
      } else if (formElement["NAME"] == null) {
        continue;
      } else if (formElement["TYPE"] == "SECTION") {
        String sectionLabel = formElement["LABEL"] != null
            ? formElement["LABEL"]
            : "ERROR : SECTION ELEMENT CREATED WITHOUT LABEL";
        formItems
            .add(EditPlusUiUtils.getBoldLabelText(sectionLabel, fontSize: 16));
      } else if (formElement["TYPE"] == "TEXTFIELD") {
        formItems.add(TextFormField(
          decoration: EditPlusUiUtils.getFormTextFieldDecoration(
              label: formElement["LABEL"], hint: formElement["LABEL"]),
        ));
      } else if (formElement["TYPE"] == "DROPDOWN") {
        formItems.add(EditPlusStringDropdown(
            hintText: formElement["LABEL"],
            valuesList: ["dynamically acquired"],
            valueContainer: {}));
      } else if (formElement["TYPE"] == "BUTTON") {
        formItems.add(OutlinedButton(
            onPressed: callFunction, child: Text(formElement["LABEL"])));
      } else {
        formItems.add(EditPlusUiUtils.getBoldLabelText(
            "Element of type ${formElement["TYPE"]} not yet factored in form maker"));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formItems,
    );
  }

  Map<String, dynamic> evaluateForm(String formBodyAsJSON) {
    var formStructure = <String, dynamic>{};
    try {
      formStructure = jsonDecode(formBodyAsJSON);
    } catch (ex) {
      print("Error is $ex");
      String errorString =
          "{\"FORMNAME\": \"ERROR\", \"SIZE\": 30, \"MESSAGE\": \"Error at evaluate form is : Format Exception\"}";
      formStructure = jsonDecode(errorString);
    }

    return formStructure;
  }

  void callFunction() {}
}
