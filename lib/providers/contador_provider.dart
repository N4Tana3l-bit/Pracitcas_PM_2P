import 'package:flutter/foundation.dart';

class ContadorProvider extends ChangeNotifier {
  int _valor = 0;
  int get valor => _valor;

  void incrementar() {
    _valor++;
    notifyListeners();
  }

  void reiniciar() {
    _valor = 0;
    notifyListeners();
  }
}