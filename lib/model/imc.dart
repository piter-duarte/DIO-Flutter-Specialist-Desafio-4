import 'dart:math';

import 'package:flutter/material.dart';

class Imc {
  final String _id = UniqueKey().toString();
  double _peso;
  double _altura;
  DateTime _data;

  Imc(this._peso, this._altura, this._data);

  String get id => _id;

  double get peso => _peso;

  set peso(double peso) {
    _peso = peso;
  }

  double get altura => _altura;

  set altura(double altura) {
    _altura = altura;
  }

  DateTime get data => _data;

  set data(DateTime data) {
    _data = data;
  }

  double calcularImc() {
    return _peso / pow(altura, 2);
  }

  String classificarIMC() {
    if (calcularImc() < 16) {
      return "Magreza grave";
    } else if (calcularImc() < 17) {
      return "Magreza moderada";
    } else if (calcularImc() < 18.5) {
      return "Magreza leve";
    } else if (calcularImc() < 25) {
      return "Saudável";
    } else if (calcularImc() < 30) {
      return "Sobrepeso";
    } else if (calcularImc() < 35) {
      return "Obesidade Grau I";
    } else if (calcularImc() < 40) {
      return "Obesidade Grau II (severa)";
    } else {
      return "Obesidade Grau III (mórbida)";
    }
  }
}
