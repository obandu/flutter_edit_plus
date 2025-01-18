part of edit_plus;

class EditplusLogger {
  static doConsoleLog(var toLog) {
    print("$toLog");
  }

  static doTimedLog(var toLog) {
    DateTime dtNow = DateTime.now();
    var timeStamp =
        "${dtNow.day}-${dtNow.month}-${dtNow.year} ${dtNow.hour}:${dtNow.minute}:${dtNow.second}";

    doConsoleLog("$timeStamp $toLog");
  }
}
