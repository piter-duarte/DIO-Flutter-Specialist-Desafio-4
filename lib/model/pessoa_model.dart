import 'package:flutter/material.dart';

class PessoaModel {
  String _id = UniqueKey().toString();
  String _nome = "";
  double _altura = 0;

  PessoaModel(this._nome, this._altura);
  PessoaModel.comId(this._id, this._nome, this._altura);

  String get id => _id;

  set id(String id) {
    _id = id;
  }

  String get nome => _nome;

  set nome(String nome) {
    _nome = nome;
  }

  double get altura => _altura;

  set altura(double altura) {
    _altura = altura;
  }
}
