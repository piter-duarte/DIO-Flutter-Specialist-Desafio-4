import 'package:dio_flutter_specialist_desafio_4/model/imc_model.dart';
import 'package:dio_flutter_specialist_desafio_4/model/pessoa_model.dart';
import 'package:dio_flutter_specialist_desafio_4/repositories/sqlite/sqlite_database.dart';
import 'package:flutter/material.dart';

class ImcSQliteRepository {
  Future<List<ImcModel>> obterDados() async {
    List<ImcModel> imcs = [];

    var db = await SqliteDatabase().obterDatabase();

    var result1 = await db.rawQuery(
        "SELECT pessoa.id as pessoa_id, pessoa.nome as pessoa_nome, pessoa.altura as pessoa_altura FROM pessoa");
    for (var element1 in result1) {
      //criando o objeto pessoa com todos os dados
      var pessoa = PessoaModel.comId(
        element1["pessoa_id"].toString(),
        element1["pessoa_nome"].toString(),
        double.parse(element1["pessoa_altura"].toString()),
      );

      var result2 = await db.rawQuery(
          "SELECT id, imc, peso, data FROM imc WHERE id_pessoa=?", [pessoa.id]);

      for (var element2 in result2) {
        ImcModel imc = ImcModel.comDados(
            element2["id"].toString(),
            double.parse(element2["imc"].toString()),
            pessoa,
            double.parse(element2["peso"].toString()),
            DateTime.parse(element2["data"].toString()));

        imcs.add(imc);
      }
    }
    return imcs;
  }

  Future<List<ImcModel>> obterDadosPessoa(int idPessoa) async {
    List<ImcModel> imcs = [];

    var db = await SqliteDatabase().obterDatabase();

    var result1 = await db.rawQuery(
        "SELECT pessoa.id as pessoa_id, pessoa.nome as pessoa_nome, pessoa.altura as pessoa_altura FROM pessoa WHERE id=?",
        [idPessoa]);
    for (var element1 in result1) {
      //criando o objeto pessoa com todos os dados
      var pessoa = PessoaModel.comId(
        element1["pessoa_id"].toString(),
        element1["pessoa_nome"].toString(),
        double.parse(element1["pessoa_altura"].toString()),
      );

      var result2 = await db.rawQuery(
          "SELECT id, imc, peso, data FROM imc WHERE id_pessoa=?", [pessoa.id]);

      for (var element2 in result2) {
        ImcModel imc = ImcModel.comDados(
            element2["id"].toString(),
            double.parse(element2["imc"].toString()),
            pessoa,
            double.parse(element2["peso"].toString()),
            DateTime.parse(element2["data"].toString()));

        imcs.add(imc);
      }
    }
    return imcs;
  }

  Future<void> salvar(ImcModel imcModel) async {
    var db = await SqliteDatabase().obterDatabase();

    var resultado = await db.rawQuery(
        "SELECT id FROM pessoa WHERE nome=? and altura=?",
        [imcModel.pessoaModel.nome, imcModel.pessoaModel.altura]);

    if (resultado.isEmpty) {
      await db.rawInsert("INSERT INTO pessoa (nome, altura) VALUES (?,?)",
          [imcModel.pessoaModel.nome, imcModel.pessoaModel.altura]);
      var queryResult = await db.rawQuery("SELECT MAX(id) as id FROM pessoa");

      for (var element in queryResult) {
        await db.rawInsert(
            "INSERT INTO imc (imc, peso, data, id_pessoa) VALUES (?,?,?,?)", [
          imcModel.imc,
          imcModel.peso,
          imcModel.data.toString(),
          element["id"]
        ]);
      }
    } else {
      for (var element in resultado) {
        await db.rawInsert(
            "INSERT INTO imc (imc, peso, data, id_pessoa) VALUES (?,?,?, ?)", [
          imcModel.imc,
          imcModel.peso,
          imcModel.data.toString(),
          element["id"]
        ]);
      }
    }
  }

  Future<List<DropdownMenuItem<String>>> obterPessoas() async {
    var itens = <DropdownMenuItem<String>>[];

    var db = await SqliteDatabase().obterDatabase();
    var result = await db.rawQuery("SELECT id, nome FROM pessoa");
    itens.add(const DropdownMenuItem(value: "0", child: Text("Todos")));
    for (var element in result) {
      itens.add(DropdownMenuItem(
        value: element['id'].toString(),
        child: Text(element['nome'].toString()),
      ));
    }
    return itens;
  }

  Future<void> deletar(ImcModel imcModel) async {
    var db = await SqliteDatabase().obterDatabase();
    db.rawDelete("DELETE FROM imc WHERE id= ?", [imcModel.id]);

    var result = await db.rawQuery(
        "SELECT * FROM imc WHERE id_pessoa=?", [imcModel.pessoaModel.id]);
    if (result.isEmpty) {
      //garantindo que caso seja retirado todos os IMC's da pessoa, ela automáticamente seja deletada do banco
      deletarPessoa(imcModel);
    }
  }

  Future<void> deletarPessoa(ImcModel imcModel) async {
    var db = await SqliteDatabase().obterDatabase();
    db.rawDelete("DELETE FROM pessoa WHERE id= ?", [imcModel.pessoaModel.id]);
  }
}
