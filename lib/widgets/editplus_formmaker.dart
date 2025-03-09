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

  Widget makeForm(String formAsJSON) {
    var formStructure = evaluateForm(formAsJSON);

    return renderFormBody(formStructure);
  }

  Widget renderFormBody(var formStructure) {
    var formItems = <Widget>[];

    // get FormName and return it (this is usually the first element)
    var formName = (formStructure["FORMNAME"] == null)
        ? "NO FORM NAME DEFINED"
        : formStructure["FORMNAME"];
    formItems.add(EditPlusUiUtils.getBoldLabelText(formName));

    List formElements =
        (formStructure["ELEMENTS"] == null) ? [] : formStructure["ELEMENTS"];

    for (var formElement in formElements) {
      Widget? formElementWidget = renderFormElement(formElement);
      if (formElementWidget == null) {
        continue;
      }
      formItems.add(formElementWidget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formItems,
    );
  }

  Widget renderFormSection(var formSectionStructure) {
    var formSectionItems = <Widget>[];

    // get FormName and return it (this is usually the first element)
    var formSectionLabel = (formSectionStructure["LABEL"] == null)
        ? ""
        : formSectionStructure["LABEL"];
    // formSectionItems.add(EditPlusUiUtils.getBoldLabelText(formSectionLabel));

    List formSectionElements = (formSectionStructure["ELEMENTS"] == null)
        ? []
        : formSectionStructure["ELEMENTS"];

    for (var formSecElement in formSectionElements) {
      Widget? formSElementWidget = renderFormElement(formSecElement);
      if (formSElementWidget == null) {
        continue;
      }
      formSectionItems.add(formSElementWidget);
    }

    if (formSectionItems.isEmpty) {
      formSectionItems.add(EditPlusUiUtils.getStyledText(
          text: "No elements in this section",
          weight: FontWeight.normal,
          size: 16.0,
          color: Colors.orangeAccent));
    }

    return EditplusFormsection(
        title: formSectionLabel,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: formSectionItems,
        ));
  }

  Widget? renderFormElement(var formElement) {
    String formElementType = formElement["TYPE"];

    if (formElement["TYPE"] == null) {
      return null;
    }

    if (formElement["TYPE"] == 'SPACE') {
      return SizedBox(height: 10);
    }

    if (formElement["NAME"] == null) {
      return EditPlusUiUtils.getBoldLabelText(
          "ELEMENT '$formElementType' requires a NAME",
          fontSize: 16);
    }

    Widget returnWidget = Text("ELEMENT NOT DEFINED PROPERLY $formElementType");

    switch (formElementType) {
      case "SECTION":
        returnWidget = renderFormSection(formElement);
        break;
      case "TEXTFIELD":
        returnWidget = TextFormField(
          decoration: EditPlusUiUtils.getFormTextFieldDecoration(
              label: formElement["LABEL"], hint: formElement["LABEL"]),
        );
        break;
      case "LABEL":
        returnWidget = EditPlusUiUtils.getStyledText(
            size: 16, text: formElement["TEXT"], weight: FontWeight.bold);
        break;
      case "DROPDOWN":
        returnWidget = EditPlusStringDropdown(
            hintText: formElement["LABEL"],
            valuesList: ["dynamically acquired"],
            valueContainer: {});
        break;
      case "BUTTON":
        returnWidget = OutlinedButton(
            onPressed: callFunction, child: Text(formElement["LABEL"]));
        break;
      default:
        returnWidget = EditPlusUiUtils.getBoldLabelText(
            "Element of type ${formElement["TYPE"]} not yet factored in form maker");
    }

    return returnWidget;
  }

  Map<String, dynamic> evaluateForm(String formBodyAsJSON) {
    var formStructure = <String, dynamic>{};
    try {
      formStructure = jsonDecode(formBodyAsJSON);
    } catch (ex) {
      print("Error is $ex");

      var elementMap = {};
      elementMap["TEXT"] =
          "Error evaluating form JSON. There is a format exception. The message is below:\n $ex";
      elementMap["TYPE"] = "LABEL";
      elementMap["NAME"] = "LABEL_01";

      var elementList = [elementMap];

      formStructure["FORMNAME"] = "ERROR MESSAGE";
      formStructure["ELEMENTS"] = elementList;

      // print("Errorstring is $errorString");
      // formStructure = jsonDecode(errorString);
    }

    return formStructure;
  }

  void callFunction() {}
}
