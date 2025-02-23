part of edit_plus;

class EditplusAlerts {
  static void showAlertDialog(BuildContext context,
      {required String message, required String title}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(8),
            child: Text(title,
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            width: 360,
          ),
          content: SizedBox(
            width: 360,
            child: Text(message),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text("  OK  "),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /* static void dismissProgressDialog(BuildContext context)
  {
    var sessionUserBloc = BlocProvider.of<SessionUser>(context, listen: false); 
    if (sessionUserBloc.state.containsKey('PROGRESSDIALOG'))
    {
      Navigator.of(context).pop();

      var progressDialogDismissEvent = {'EVENTNAME' : 'DISMISSPROGRESSDIALOG'};
      sessionUserBloc.add(progressDialogDismissEvent);
    }
    else
    {
      Logger.doConsoleLog("Nothing happened when dismissing dialog");
    }
     
  }

  static void showProgressDialog(BuildContext context) 
  {
    AlertDialog progressDialog = AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container (
        padding: const EdgeInsets.all(8),
        child:  Text('PROCESSING COMMAND', style: Theme.of(context).primaryTextTheme.headline6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        width: 240,
      ),      
      content: SizedBox(
        child: Column(
          children: const [
            LinearProgressIndicator(),
            SizedBox(height: 40,),
            Text("Please wait ...")
          ],
        ), 
        width: 240,
        height: 180,
      )
    );

    var progressDialogSaveEvent = {'EVENTNAME' : 'ADDPROGRESSDIALOG', 'PROGRESSDIALOG' : progressDialog};
    var sessionUserBloc = BlocProvider.of<SessionUser>(context, listen: false);
    sessionUserBloc.add(progressDialogSaveEvent);

    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return progressDialog;
      },
    );  
  } */

  static void showProgressDialogWithMessage(
      BuildContext context, String message) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Please wait ...."),
          content: Column(children: [
            LinearProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ]),
          actions: <Widget>[
            new TextButton(
              child: new Text("DISMISS"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void showConfirmDialog(BuildContext context, String message,
      {Function? confirmCallBack}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(8),
            child: Text('ALERT !!',
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            width: 360,
          ),
          content: SizedBox(
            width: 360,
            child: Text(message),
          ),
          actions: <Widget>[
            OutlinedButton.icon(
              icon: Icon(
                Icons.backspace_rounded,
                color: Colors.red,
              ),
              label: const Text("  CANCEL  "),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton.icon(
              icon: Icon(
                Icons.done_sharp,
                color: Colors.green,
              ),
              label: const Text("  OK  "),
              onPressed: () {
                Navigator.of(context)
                    .pop(confirmCallBack != null ? confirmCallBack() : null);
              },
            ),
          ],
        );
      },
    );
  }

  static void showChoiceDialog(
      BuildContext context, String message, List options,
      {Function? confirmChoice}) {
    var _choiceOfProductType = "STANDARD PRODUCT";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(8),
            child: Text('SELECT !',
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            width: 360,
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
                width: 360,
                child: Column(
                  children: <Widget>[
                    Text(message),
                    RadioListTile<String>(
                      title: const Text('STANDARD PRODUCT'),
                      value: 'STANDARD PRODUCT',
                      groupValue: _choiceOfProductType,
                      onChanged: (productType) {
                        _choiceOfProductType = productType.toString();
                        setState(() {});
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('OWN PRODUCT'),
                      value: "OWN PRODUCT",
                      groupValue: _choiceOfProductType,
                      onChanged: (productType) {
                        _choiceOfProductType = productType.toString();
                        setState(() {});
                      },
                    ),
                  ],
                ));
          }),
          actions: <Widget>[
            OutlinedButton.icon(
              icon: Icon(
                Icons.backspace_rounded,
                color: Colors.red,
              ),
              label: const Text("  CANCEL  "),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton.icon(
              icon: Icon(
                Icons.done_sharp,
                color: Colors.green,
              ),
              label: const Text("  OK  "),
              onPressed: () {
                Navigator.of(context).pop(confirmChoice != null
                    ? confirmChoice(_choiceOfProductType)
                    : null);
              },
            ),
          ],
        );
      },
    );
  }

  static void showInputDialog(BuildContext context,
      {required String dialogTitle,
      required String dialogMessage,
      required String inputLabel,
      Function? returnInputFunction}) {
    TextEditingController _tecTextInput = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(8),
            child: Text(dialogTitle,
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            width: 360,
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                width: 360,
                child: Column(
                  children: <Widget>[
                    Text(dialogMessage),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _tecTextInput,
                      decoration: EditPlusUiUtils.getFormTextFieldDecoration(
                          label: inputLabel, hint: inputLabel),
                    )
                  ],
                ));
          }),
          actions: <Widget>[
            OutlinedButton.icon(
              icon: Icon(
                Icons.backspace_rounded,
                color: Colors.red,
              ),
              label: const Text("  CANCEL  "),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton.icon(
              icon: Icon(
                Icons.done_sharp,
                color: Colors.green,
              ),
              label: const Text("  OK  "),
              onPressed: () {
                Navigator.of(context).pop(returnInputFunction != null
                    ? returnInputFunction(_tecTextInput.text)
                    : null);
              },
            ),
          ],
        );
      },
    );
  }
}
