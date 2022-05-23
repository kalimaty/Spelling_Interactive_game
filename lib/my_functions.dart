class MyFunctions {
  static String convertNumber(String number, String lang) {
    print("*" * 50);
    print(number);
    String res = "";

    final arabicsNum = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    if (lang == "ar") {
      number.split("").forEach((element) {
        if (element == ".") {
          res += ".";
        } else {
          res += arabicsNum[int.parse(element)];
        }
      });
    } else {
      res = number;
    }
    return res;
  }
}
