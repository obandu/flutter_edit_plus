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
              height: 310,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                _setState = setState;
                print("Chosen folder name is $chosenFolderName");
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditPlusUiUtils.getStyledText(
                          size: 12,
                          weight: FontWeight.bold,
                          text: chosenFolderName),
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

  void getCurrentFolderList(String? folderName, BuildContext dialogContext) {
    fileFolderList = [];
    var filesOnly = <Widget>[];
    var directoriesOnly = <Widget>[];

    // initial and default folder name = "."
    if (folderName != null) {
      chosenFolderName = folderName;
    } else {
      chosenFolderName = ".";
    }

    fileFolderList.add(TextButton.icon(
      onPressed: () {
        localStorage
            .getParentDirectoryofDirectory(chosenFolderName)
            .then((parentDirectory) {
          getCurrentFolderList(parentDirectory, dialogContext);
        });
      },
      label: Text(" .."),
      icon: Icon(Icons.arrow_upward_sharp),
    ));

    localStorage.getFilesList(chosenFolderName).then((filesList) {
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

      fileFolderList.addAll(directoriesOnly);
      fileFolderList.addAll(filesOnly);

      _setState?.call(() {});
    });

    // return fileFolderList;
  }

  selectFile(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop(selectFileFunction != null
        ? selectFileFunction?.call(chosenFileName)
        : null);
  }
}
