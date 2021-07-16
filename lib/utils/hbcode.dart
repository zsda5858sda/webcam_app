import 'dart:math';

class HBCode {
  static String code = "";

  static String getCode() {
    code = "";
    for (var i = 0; i < 6; i++) {
      code = code + Random().nextInt(9).toString();
    }
    return code;
  }
}
