part of edit_plus;

class EditplusFormMaker {
  Function? formSubmitFunction;
  Function functionBroker;
  late Function contentProviderFunction;
  var formValuesContainer = {};

  EditplusFormMaker({this.formSubmitFunction, required this.functionBroker});

  bool validate() {
    return false;
  }

  Widget makeForm(String formAsJSON) {
    // evaluate form structure for well-formedness
    var formStructure = evaluateForm(formAsJSON);

    Widget formBody = renderFormBody(formStructure);

    // initialise form content
    contentProviderFunction = functionBroker("GET_CONTENTPROVIDER");

    return formBody;
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

    if (formSectionElements.isEmpty) {
      formSectionItems.add(EditPlusUiUtils.getStyledText(
          text: "No elements in this section",
          weight: FontWeight.normal,
          size: 16.0,
          color: Colors.orangeAccent));
    } else {
      for (var formSecElement in formSectionElements) {
        Widget? formSElementWidget = renderFormElement(formSecElement);
        if (formSElementWidget == null) {
          continue;
        }
        formSectionItems.add(formSElementWidget);
      }
    }

    return EditplusFormsection(
        title: formSectionLabel,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: formSectionItems,
        ));
  }

  Widget renderFormWrapLayout(var formWrapLayoutStructure) {
    var formLayoutItems = <Widget>[];

    List formLayoutElements = (formWrapLayoutStructure["ELEMENTS"] == null)
        ? []
        : formWrapLayoutStructure["ELEMENTS"];

    if (formLayoutElements.isEmpty) {
      formLayoutItems.add(EditPlusUiUtils.getStyledText(
          text: "Wrap layout has no children",
          weight: FontWeight.normal,
          size: 16.0,
          color: Colors.orangeAccent));
    } else {
      for (var formLyElement in formLayoutElements) {
        Widget? formLElementWidget = renderFormElement(formLyElement);
        if (formLElementWidget == null) {
          continue;
        }
        formLayoutItems.add(formLElementWidget);
      }
    }

    return Container(
        child: Wrap(spacing: 15, runSpacing: 10, children: formLayoutItems));
  }

  Widget? renderFormElement(var formElement) {
    String formElementType = formElement["TYPE"];

    if (formElement["TYPE"] == null) {
      return null;
    }

    if (formElement["TYPE"] == 'SPACE') {
      return SizedBox(height: 10);
    }

    if (formElement["TYPE"] == 'LAYOUT_WRAP') {
      return renderFormWrapLayout(formElement);
    }

    // some form elements are required to have names
    if (formElement["NAME"] == null) {
      return EditPlusUiUtils.getBoldLabelText(
          "ELEMENT '$formElementType' requires a NAME",
          fontSize: 16);
    } else {
      // form elements that require names must have unique names
      // 1. Check if given element name is already in values container, if so Error
      // 2. Add each form element name as key in value containers but with null value
      if (formValuesContainer.containsKey(formElement["NAME"])) {
        return EditPlusUiUtils.getBoldLabelText(
            "Form element name ${formElement["NAME"]} used for element of type '$formElementType' has already been used. Form elements must have unique names for evaluation and data collection.",
            fontSize: 12);
      }
    }

    Widget returnWidget = Text("ELEMENT NOT DEFINED PROPERLY $formElementType");

    // DETERMINE THE REQUIRED STATUS
    bool isRequired = false;
    var isRequiredText = formElement["REQUIRED"].toString();
    if (isRequiredText.toUpperCase() == "YES") {
      isRequired = true;
    }

    // DETERMINE THE WIDTH
    double actualWidth = 360;
    var givenWidth = formElement["WIDTH"].toString().toUpperCase();
    if (givenWidth != "NULL") {
      if (givenWidth == "COL8") {
        actualWidth = 720;
      }
    }

    switch (formElementType) {
      case "SECTION":
        returnWidget = renderFormSection(formElement);
        break;
      case "TEXTFIELD":
        TextEditingController _tecTextInput = TextEditingController();
        formValuesContainer[formElement["NAME"]] = _tecTextInput;

        // textfield length
        var textWidth = formElement["TEXTLENGTH"];
        int textLen = EditPlusUtils.getInteger(textWidth.toString());
        textLen = (textLen == 0) ? TextField.noMaxLength : textLen;

        // textfield is editable
        var textEnabledStr = formElement["ENABLED"].toString().toUpperCase();
        bool textEnabled = EditPlusUtils.getBoolean(textEnabledStr);

        returnWidget = ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: actualWidth,
            ),
            child: TextFormField(
              decoration: EditPlusUiUtils.getFormTextFieldDecoration(
                  label: formElement["LABEL"], hint: formElement["LABEL"]),
              maxLength: textLen,
              enabled: (textEnabledStr == "NULL") ? true : false,
              controller: _tecTextInput,
            ));
        break;
      case "PASSWORDFIELD":
        TextEditingController _tecPasswordInput = TextEditingController();
        formValuesContainer[formElement["NAME"]] = _tecPasswordInput;
        returnWidget = TextFormField(
          decoration: EditPlusUiUtils.getFormTextFieldDecoration(
              label: formElement["LABEL"], hint: formElement["LABEL"]),
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          // suffixIcon : get
          controller: _tecPasswordInput,
        );
        break;
      case "LABEL":
        returnWidget = EditPlusUiUtils.getStyledText(
            size: 14, text: formElement["TEXT"], weight: FontWeight.bold);
        break;
      case "DROPDOWN":
        String valuesType = formElement["VALUES"].runtimeType.toString();
        List valuesList = ["EMPTY LIST"];
        if (valuesType == "STRING" &&
            formElement["VALUES"].toUpperCase() == "DYNAMIC") {
          valuesList = contentProviderFunction(formElement['NAME'], "LIST");
        }
        if (valuesType.toUpperCase().startsWith("LIST")) {
          valuesList = formElement["VALUES"];
        }
        print("The dropdown data type is ${valuesType}");
        returnWidget = EditPlusStringDropdown(
            hintText: formElement["LABEL"],
            valuesList: valuesList,
            dropdownName: formElement['NAME'],
            valueContainer: formValuesContainer);
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

  getFormValues() {
    var returnData = {};

    formValuesContainer.forEach((key, value) {
      print("Key is $key");
      if (value is TextEditingController) {
        returnData[key] = value.text;
      } else {
        returnData[key] = value;
      }
    });
    return returnData;
  }
}
