part of edit_plus;

class EditplusFilepicker {
  List<String> extensionsAllowed;
  String dialogTitle;
  List<Widget> fileFolderList = [];
  StateSetter? _setState;
  EditplusFilepicker(
      {required this.dialogTitle, required this.extensionsAllowed}) {
    getCurrentFolderList(null);
  }

  void showFilePickerDialog(BuildContext context,
      {Function? returnInputFunction}) {
    TextEditingController _tecTextInput = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: 360,
            padding: const EdgeInsets.all(8),
            child: Text(dialogTitle,
                style: Theme.of(context).primaryTextTheme.headlineSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return Container(
                width: 360,
                height: 320,
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fileFolderList,
                )));
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

  void getCurrentFolderList(String? folderName) {
    fileFolderList = [];
    var filesOnly = <Widget>[];
    var directoriesOnly = <Widget>[];

    EditplusLocalStorage localStorage = EditplusLocalStorage(
        fileName: ".", createAsNecessary: false, fullFilePathAsGiven: false);

    fileFolderList.add(TextButton.icon(
      onPressed: () {
        String dirname = ".";
        if (folderName != null) {
          dirname = folderName;
        }

        localStorage
            .getParentDirectoryofDirectory(dirname)
            .then((parentDirectory) {
          // print("\nThe current folder name is ${dirname}");
          // print("And ... The parent folder name is ${parentDirectory}");
          getCurrentFolderList(parentDirectory);
        });
      },
      label: Text(" .."),
      icon: Icon(Icons.arrow_upward_sharp),
    ));

    localStorage.getFilesList(folderName).then((filesList) {
      filesOnly = [];
      directoriesOnly = [];

      for (var file in filesList) {
        if (file is Directory) {
          directoriesOnly.add(TextButton.icon(
            onPressed: () {
              getCurrentFolderList(file.path.toString());
            },
            label: Text(EditplusLocalStorage.fileNameOnlyFromPath(
                file.path.toString())),
            icon: Icon(Icons.folder),
          ));
        } else if (file is File) {
          var fileName =
              EditplusLocalStorage.fileNameOnlyFromPath(file.path.toString());
          var fileExtension = fileName.substring(fileName.indexOf(".") + 1);
          if (extensionsAllowed.isNotEmpty &&
              !extensionsAllowed.contains(fileExtension)) {
            continue;
          }
          filesOnly.add(TextButton.icon(
            onPressed: () {},
            label: Text(fileName),
            icon: Icon(Icons.document_scanner),
          ));
        }
      }

      fileFolderList.addAll(directoriesOnly);
      fileFolderList.addAll(filesOnly);

      _setState?.call(() {});
    });

    // return fileFolderList;
  }
}
