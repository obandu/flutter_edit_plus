part of edit_plus;

class EditplusCollectionUtils {
  // convert a list of doubles represented as a string of the format [double, double, double]
  // to a list of double values
  static List<double> stringAsListToDoubleList(String doubleRepresenation) {
    List<double> doubleValues = [];

    // remove end and beginning '[' ']'
    doubleRepresenation.trim();
    if (doubleRepresenation.startsWith("[")) {
      doubleRepresenation = doubleRepresenation.substring(1);
    }

    if (doubleRepresenation.endsWith("]")) {
      doubleRepresenation =
          doubleRepresenation.substring(0, doubleRepresenation.length - 1);
    }

    // remove '"' where they exist
    doubleRepresenation.replaceAll("\"", "");

    // split the remaining string on comma' values
    List strDoubleValues = doubleRepresenation.split(",");

    for (var strDoubleValue in strDoubleValues) {
      doubleValues.add(EditPlusUtils.getDouble(strDoubleValue.trim()));
    }

    return doubleValues;
  }

  // convert a list of integers represented as a string of the format [integer, integer, integer]
  // to a list of integer values
  static List<int> stringAsListToIntegerList(String integerRepresenation) {
    List<int> integerValues = [];

    // remove end and beginning '[' ']'
    integerRepresenation.trim();
    if (integerRepresenation.startsWith("[")) {
      integerRepresenation = integerRepresenation.substring(1);
    }

    if (integerRepresenation.endsWith("]")) {
      integerRepresenation =
          integerRepresenation.substring(0, integerRepresenation.length - 1);
    }

    // remove '"' where they exist
    integerRepresenation.replaceAll("\"", "");

    // split the remaining string on comma' values
    List strIntValues = integerRepresenation.split(",");

    for (var strIntValue in strIntValues) {
      integerValues.add(EditPlusUtils.getInteger(strIntValue.trim()));
    }

    return integerValues;
  }

  static List<int> integerToBitList({required int value, int? bitMapWidth}) {
    List<int> intList = [];
    if (bitMapWidth == null) {
      bitMapWidth = 32;
    }

    // Convert integer to a string of bits
    String bitString = value.toRadixString(2);
    if (bitString.length > bitMapWidth) {
      bitString = bitString.substring(bitString.length - bitMapWidth);
    } else {
      bitString = bitString.padLeft(bitMapWidth, '0');
    }

    // Split the string into individual bits
    List<String> bitsList = bitString.split('');

    // Print the list of individual bits
    print(bitsList);

    for (var bitAsString in bitsList) {
      intList.add(EditPlusUtils.getInteger(bitAsString));
    }

    return intList;
  }
}
