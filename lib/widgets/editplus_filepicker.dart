part of edit_plus;

class EditplusFilepicker {
  List<String> extensionsAllowed;
  String dialogTitle;
  List<Widget> fileFolderList = [];
  StateSetter? _setState;
  Function? selectFileFunction;

  // get a single instance of the EditplusLocalStorage
  EditplusLocalStorage localStorage = EditplusLocalStorage(
      fileName: ".", createAsNecessary: false, fullFilePathAsGiven: false);

  String chosenFolderName = ".";
  String? chosenFileName = null;

  EditplusFilepicker(
      {required this.dialogTitle, required this.extensionsAllowed}) {
    // make all extension names upper case
    for (String extensionName in extensionsAllowed) {
      extensionsAllowed.add(extensionName.toUpperCase());
      extensionsAllowed.remove(extensionName);
    }
  }

  void showFilePickerDialog(BuildContext context,
      {Function? returnInputFunction}) {
    TextEditingController _tecTextInput = TextEditingController();
    selectFileFunction = returnInputFunction;

    getCurrentFolderList(null, context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: 360,
            padding: const EdgeInsets.all(3),
            child: Text(dialogTitle,
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(color: Colors.grey, width: 2)),
          ),
          content: SizedBox(
              width: 480,
              height: 340,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                _setState = setState;
                print("Chosen folder name is $chosenFolderName");
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          flex: 1,
                          child: EditPlusUiUtils.getStyledText(
                              size: 14,
                              weight: FontWeight.bold,
                              text: "FOLDER"),
                        ),
                        Expanded(
                          flex: 3,
                          child: EditPlusUiUtils.getStyledText(
                            size: 14,
                            weight: FontWeight.normal,
                            text: chosenFolderName,
                          ),
                        )
                      ]),
                      Divider(),
                      Container(
                          width: 480,
                          height: 260,
                          child: SingleChildScrollView(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: fileFolderList,
                          ))),
                      Divider()
                    ]);
              })),
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

  void showFileSaverDialog(BuildContext context,
      {required Function doSaveFunction}) {
    TextEditingController _tecTextFileNameInput = TextEditingController();
    selectFileFunction = doSaveFunction;

    getCurrentFolderList(null, context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: 360,
            padding: const EdgeInsets.all(3),
            child: Text(dialogTitle,
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(color: Colors.grey, width: 2)),
          ),
          content: SizedBox(
              width: 480,
              height: 380,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                _setState = setState;
                // print("Chosen folder name is $chosenFolderName");
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          flex: 1,
                          child: EditPlusUiUtils.getStyledText(
                              size: 14,
                              weight: FontWeight.bold,
                              text: "FILE NAME"),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Flexible(
                          flex: 3,
                          child: TextFormField(
                            controller: _tecTextFileNameInput,
                            decoration:
                                EditPlusUiUtils.getFormTextFieldDecoration(
                                    label: "FILE NAME", hint: "FILE NAME"),
                          ),
                        )
                      ]),
                      SizedBox(
                        height: 3,
                      ),
                      Row(children: [
                        Expanded(
                          flex: 1,
                          child: EditPlusUiUtils.getStyledText(
                              size: 14,
                              weight: FontWeight.bold,
                              text: "FOLDER"),
                        ),
                        Expanded(
                          flex: 3,
                          child: EditPlusUiUtils.getStyledText(
                            size: 14,
                            weight: FontWeight.normal,
                            text: chosenFolderName,
                          ),
                        )
                      ]),
                      Divider(),
                      Container(
                          width: 480,
                          height: 240,
                          child: SingleChildScrollView(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: fileFolderList,
                          ))),
                      Divider()
                    ]);
              })),
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
                if (_tecTextFileNameInput.text.isEmpty) {
                  EditplusAlerts.showAlertDialog(context,
                      message: "Please give a file name to save",
                      title: "FILE NAME REQUIRED");
                } else {
                  Navigator.of(context).pop(doSaveFunction != null
                      ? doSaveFunction(
                          chosenFolderName, _tecTextFileNameInput.text)
                      : null);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void getCurrentFolderList(String? folderName, BuildContext dialogContext) {
    fileFolderList = [];
    var filesOnly = <Widget>[];
    var directoriesOnly = <Widget>[];

    fileFolderList.add(TextButton.icon(
      onPressed: () {
        var parentDirectory =
            localStorage.getParentDirectoryofDirectory(chosenFolderName);
        getCurrentFolderList(parentDirectory.toString(), dialogContext);
      },
      label: Text(" .."),
      icon: Icon(Icons.arrow_upward_sharp),
    ));

    localStorage.getFilesList(folderName).then((filesListData) {
      List<FileSystemEntity> filesList = filesListData["FILESYTEMENTITIES"];
      Directory currentDirectory = filesListData["CURRENTDIRECTORY"];
      String errorMessage = filesListData["ERRORMESSAGE"];

      if (errorMessage != "NONE") {
        EditplusAlerts.showAlertDialog(dialogContext,
            message: errorMessage, title: "ERROR !");
        return;
      }
      print(
          "\nReturned data is is ${filesList.length} from path $currentDirectory");
      // chosenFolderName = currentDirectory.path.toString();
      filesOnly = [];
      directoriesOnly = [];

      for (var file in filesList) {
        if (file is Directory) {
          directoriesOnly.add(TextButton.icon(
            onPressed: () {
              getCurrentFolderList(file.path.toString(), dialogContext);
            },
            label: Text(EditplusLocalStorage.fileNameOnlyFromPath(
                file.path.toString())),
            icon: Icon(Icons.folder),
          ));
        } else if (file is File) {
          var fileName =
              EditplusLocalStorage.fileNameOnlyFromPath(file.path.toString());
          var fileExtension =
              fileName.substring(fileName.indexOf(".") + 1).toUpperCase();
          if (extensionsAllowed.isEmpty ||
              extensionsAllowed.contains(fileExtension)) {
            filesOnly.add(TextButton.icon(
              onPressed: () {
                chosenFileName = file.path.toString();
                selectFile(dialogContext);
              },
              label: Text(fileName),
              icon: Icon(Icons.document_scanner),
            ));
          }
        }
      }

      chosenFolderName = currentDirectory.path.toString();
      fileFolderList.addAll(directoriesOnly);
      fileFolderList.addAll(filesOnly);
      _setState?.call(() {});
    });
  }

  selectFile(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop(selectFileFunction != null
        ? selectFileFunction?.call(chosenFolderName, chosenFileName)
        : null);
  }
}
