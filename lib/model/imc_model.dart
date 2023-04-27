import 'dart:math';

import 'package:dio_flutter_specialist_desafio_4/model/pessoa_model.dart';
import 'package:flutter/material.dart';

class ImcModel {
  String _id = UniqueKey().toString();
  late double _imc;
  PessoaModel _pessoaModel;
  double _peso;
  DateTime _data;

  ImcModel(this._pessoaModel, this._peso, this._data);

  ImcModel.comDados(
      this._id, this._imc, this._pessoaModel, this._peso, this._data);

  String get id => _id;

  set id(String id) {
    _id = id;
  }

  PessoaModel get pessoaModel => _pessoaModel;

  set pessoaModel(PessoaModel pessoaModel) {
    _pessoaModel = pessoaModel;
  }

  double get peso => _peso;

  set peso(double peso) {
    _peso = peso;
  }

  DateTime get data => _data;

  set data(DateTime data) {
    _data = data;
  }

  double get imc => _imc;

  double calcularImc() {
    return _imc = _peso / pow(_pessoaModel.altura, 2);
  }

  String classificarIMC() {
    if (_imc < 16) {
      return "Magreza grave";
    } else if (_imc < 17) {
      return "Magreza moderada";
    } else if (_imc < 18.5) {
      return "Magreza leve";
    } else if (_imc < 25) {
      return "Saudável";
    } else if (_imc < 30) {
      return "Sobrepeso";
    } else if (_imc < 35) {
      return "Obesidade Grau I";
    } else if (_imc < 40) {
      return "Obesidade Grau II (severa)";
    } else {
      return "Obesidade Grau III (mórbida)";
    }
  }
}
