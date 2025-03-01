part of edit_plus;

class EditplusLocalStorage {
  final String fileName;
  final bool createAsNecessary;
  final bool fullFilePathAsGiven;
  String? initialStoredValue;

  EditplusLocalStorage(
      {required this.fileName,
      required this.createAsNecessary,
      required this.fullFilePathAsGiven,
      this.initialStoredValue});

  /**
   * Private Utility function to get the application's or system's "DOCUMENTS" directory.
   * 
   * The default save location for the given user on the system
   */
  Future<String> get _documentHomeDirectory async {
    final documentHomeDirectory = await getApplicationDocumentsDirectory();

    return documentHomeDirectory.path;
  }

  Future<Map<String, dynamic>> getFilesList(String? folderPath) async {
    String errorMessage = "NONE";
    Directory thisDir = Directory.fromUri(Uri.file("."));
    List<FileSystemEntity> entities = [];

    try {
      if (folderPath == null || folderPath == ".") {
        final homeDir = await _documentHomeDirectory;
        thisDir = Directory.fromUri(Uri.file(homeDir));
      } else {
        thisDir = Directory.fromUri(Uri.file(folderPath));
      }

      print("The home dir is $thisDir");
      entities = await thisDir.list().toList();
    } catch (ex) {
      errorMessage = "Exception or Error : ${ex.toString()}";
    }
    return {
      "FILESYTEMENTITIES": entities,
      "CURRENTDIRECTORY": thisDir,
      "ERRORMESSAGE": errorMessage
    };
  }

  String getParentDirectoryofDirectory(String directoryPath) {
    Directory thisDir = Directory.fromUri(Uri.file(directoryPath));

    print("\nThe entity chosen is $thisDir from path $directoryPath");

    return thisDir.parent.path;
  }

  /*Future<File> get _localFile async {
    final pathAsFile = await _localPathAsURI.then((localPath)
    {
      print("The local path is $localPath and URI is $localPath/$fileName");      
      Uri fileURI = Uri.file('$localPath/$fileName');

      File thisFile = File('$localPath/$fileName');
      print("The file, this file is $thisFile");      
      if (thisFile == null && createAsNecessary == true)
      {
        thisFile.create();
        if (initialStoredValue != null)
        {
          thisFile.writeAsBytes(utf8.encode(''));
        }

      }
      return File('$localPath/$fileName');
    },
    onError: (errormessage){
      print("Attempt to get the local file leads to the error $errormessage");
    });

    return pathAsFile; // File('$path/$fileName');
  } */

  Future<File> get _fileFromLocalPath async {
    final fileFromLocalPath = await _documentHomeDirectory.then((localPath) {
      print("The local path is $localPath and URI is $localPath/$fileName");
      String localFileName = '$localPath/$fileName';
      if (localPath.contains("\\")) {
        localFileName = '$localPath\\$fileName';
      }

      File thisFile = File(localFileName);
      // print("The file, this file is $thisFile");
      thisFile.exists().then((value) {
        if (value == false && createAsNecessary == true) {
          thisFile.create();
          if (initialStoredValue == null) {
            initialStoredValue = '';
          } else {
            thisFile.writeAsBytes(utf8.encode(initialStoredValue!));
          }
        }

        return true;
      });
      return File(localFileName);
    }, onError: (errormessage) {
      print("Attempt to get the local file leads to the error $errormessage");
    });

    return fileFromLocalPath; // File('$path/$fileName');
  }

  Future<File> get _fileFromFullPath async {
    try {
      File thisFile = File(fileName);
      thisFile.exists().then((value) {
        if (value == false && createAsNecessary == true) {
          thisFile.create();
          if (initialStoredValue == null) {
            initialStoredValue = '';
          } else {
            thisFile.writeAsBytes(utf8.encode(initialStoredValue!));
          }
        }

        return true;
      });
    } catch (errormessage) {
      print("Attempt to get the local file leads to the error $errormessage");
    }

    return File(fileName);
  }

  Future<String> readData() async {
    try {
      final file = await _fileFromLocalPath;

      // Read the file
      final content = await file.readAsString();
      return content;
    } catch (errormessage) {
      // If encountering an error, return 0
      print(
          "Attempt to read the file contents leads to the error ${errormessage}");
      return '';
    }
  }

  Future<File> writeStringData(String contents) async {
    if (fullFilePathAsGiven == true) {
      return await _fileFromFullPath.then((file) {
        return file.writeAsString('$contents');
      });
    } else {
      return await _fileFromLocalPath.then((file) {
        return file.writeAsString('$contents');
      });
    }
  }

  static String fileNameOnlyFromPath(String path) {
    if (path.contains("\\")) {
      var filename = path.substring(path.lastIndexOf("\\") + 1);
      return filename;
    }
    if (path.contains("/")) {
      var filename = path.substring(path.lastIndexOf("/") + 1);
      return filename;
    }

    return path;
  }
}
