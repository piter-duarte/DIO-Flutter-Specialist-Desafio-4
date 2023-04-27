import 'package:dio_flutter_specialist_desafio_4/model/pessoa_model.dart';
import 'package:dio_flutter_specialist_desafio_4/repositories/imx_hive_repository.dart';
import 'package:dio_flutter_specialist_desafio_4/repositories/sqlite/imc_sqlite_repository.dart';
import 'package:dio_flutter_specialist_desafio_4/repositories/sqlite/sqlite_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../model/imc_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var nomeController = TextEditingController();
  var pesoController = TextEditingController();
  var alturaController = TextEditingController();
  var _imcs = const <ImcModel>[];
  late ImcHiveRepository imcHiveRepository;
  ImcSQliteRepository imcSQliteRepository = ImcSQliteRepository();
  late Database db;
  List<DropdownMenuItem<String>> itens = [];
  String dropDownSelected = "0";

  @override
  void initState() {
    super.initState();
    obterImcs();
  }

  void obterImcs() async {
    //Obtendo nome e altura por meio de Hive
    imcHiveRepository = await ImcHiveRepository.carregar();
    nomeController.text = imcHiveRepository.obter("nome");
    alturaController.text = imcHiveRepository.obter("altura");

    db = await SqliteDatabase().obterDatabase();

    _imcs = await imcSQliteRepository.obterDados();
    itens = await imcSQliteRepository.obterPessoas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Calculadora de IMC"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext bc) {
                            return AlertDialog(
                              title: const Center(child: Text("Informações")),
                              content: const Text(
                                  "Para calcular o IMC, deve ser pressionado o botão no canto inferior esquerdo, e informar os dados solicitados, após isto, será criado uma lista com os IMC's calculados.\n\nApós o cálculo de algum IMC, será possivel realizar uma filtragem por IMC's por pessoa, basta selecionar a pessoa que deseja, e apenas os cálculos dela irão aparecer.\n\nPara remover um IMC calculado, é necessário deslizar o item da lista para a esquerda, e aceitar a confirmação\n\nPara remover todos os cálculos de uma pessoa, é necessário deslizar o item da lista para a direita, e aceitar a confirmação"),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok"),
                                ),
                              ],
                            );
                          });
                    },
                    child: const Icon(
                      Icons.info,
                      size: 20,
                    )),
                const SizedBox(width: 10),
                Text(
                  dropDownSelected == "0"
                      ? "IMC's Calculados: "
                      : "IMC's Calculados de: ",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w400),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1.5,
                              color: Theme.of(context).primaryColor))),
                  child: DropdownButton(
                    underline: Container(
                      height: 0,
                      color: Theme.of(context).primaryColor,
                    ),
                    items: itens,
                    onChanged: (value) async {
                      if (value != "0") {
                        _imcs = await imcSQliteRepository
                            .obterDadosPessoa(int.parse(value.toString()));
                        dropDownSelected = value!;
                        setState(() {});
                      } else {
                        _imcs = await imcSQliteRepository.obterDados();
                        dropDownSelected = value!;
                        setState(() {});
                      }
                    },
                    value: dropDownSelected,
                    isExpanded: false,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _imcs.length,
                itemBuilder: (BuildContext bc, int index) {
                  var imc = _imcs[index];
                  return Dismissible(
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Theme.of(context).primaryColorLight,
                      child: const Icon(
                        Icons.person_off_rounded,
                        size: 32,
                      ),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Theme.of(context).primaryColorLight,
                      child: const Icon(
                        Icons.delete,
                        size: 32,
                      ),
                    ),
                    onDismissed: (DismissDirection dismissDirection) async {
                      if (dismissDirection == DismissDirection.endToStart) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Center(
                                      child: Text("Excluir IMC calculado ?")),
                                  content: const Text(
                                      "Caro usuário, você está preste a excluir este cálculo de IMC, tem certeza que deseja fazer isso ?"),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                      child: const Text("Não"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await imcSQliteRepository.deletar(imc);
                                        obterImcs();
                                        dropDownSelected = "0";
                                        setState(() {});
                                      },
                                      child: const Text("Sim"),
                                    ),
                                  ],
                                ));
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Center(
                                      child: Text("Excluir Pessoa ?")),
                                  content: Text(
                                      "Caro usuário, você está preste a excluir todos os dados referentes à ${imc.pessoaModel.nome}, tem certeza que deseja fazer isso ?"),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        obterImcs();
                                        setState(() {});
                                      },
                                      child: const Text("Não"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await imcSQliteRepository
                                            .deletarPessoa(imc);
                                        obterImcs();
                                        dropDownSelected = "0";
                                        setState(() {});
                                      },
                                      child: const Text("Sim"),
                                    ),
                                  ],
                                ));
                      }
                    },
                    key: UniqueKey(),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: ListTile(
                        trailing: Text(
                          //Fazendo conversão para melhor exibição dos dados
                          "${imc.data.day < 10 ? '0${imc.data.day}' : imc.data.day}/${imc.data.month < 10 ? '0${imc.data.month}' : imc.data.month}/${imc.data.year}\n${imc.data.hour < 10 ? '0${imc.data.hour}' : imc.data.hour}:${imc.data.minute < 10 ? '0${imc.data.minute}' : imc.data.minute}:${imc.data.second < 10 ? '0${imc.data.second}' : imc.data.second}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        title: Text(
                          "IMC: ${imc.calcularImc().toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "Nome: ${imc.pessoaModel.nome}\nAltura: ${imc.pessoaModel.altura} m\nPeso: ${imc.peso} Kg\nClassificação: ${imc.classificarIMC()}"),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          pesoController.text = "";
          showDialog(
              context: context,
              builder: (BuildContext bc) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Center(child: Text("IMC")),
                  actionsAlignment: MainAxisAlignment.center,
                  content: Wrap(
                    runSpacing: 10,
                    children: [
                      TextField(
                        controller: nomeController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: "Nome",
                          hintStyle: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextField(
                        controller: alturaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Altura",
                          hintStyle: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextField(
                        controller: pesoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Peso",
                          hintStyle: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (pesoController.text.contains(",")) {
                          pesoController.text =
                              pesoController.text.replaceAll(",", ".");
                        }
                        if (alturaController.text.contains(",")) {
                          alturaController.text =
                              alturaController.text.replaceAll(",", ".");
                        }

                        if (nomeController.text.trim() == "" ||
                            nomeController.text.isEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Erro! O nome não pode ser nulo!")));
                          return;
                        }
                        if (alturaController.text.trim() == "") {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Erro! A altura não pode ser nula!")));
                          return;
                        }
                        if (double.parse(alturaController.text) == 0) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Erro! A altura não pode ser igual a zero!")));
                          return;
                        }
                        if (pesoController.text.trim() == "") {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Erro! O peso não pode ser nulo!")));
                          return;
                        }
                        if (double.parse(pesoController.text) == 0) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Erro! O peso não pode ser igual a zero!")));
                          return;
                        }
                        imcHiveRepository.salvar("nome", nomeController.text);
                        imcHiveRepository.salvar(
                            "altura", alturaController.text);

                        var imcModel = ImcModel(
                            PessoaModel(
                              nomeController.text,
                              double.parse(alturaController.text),
                            ),
                            double.parse(pesoController.text),
                            DateTime.now());
                        imcModel.calcularImc();
                        await imcSQliteRepository.salvar(imcModel);
                        obterImcs();
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text("Calcular"),
                    )
                  ],
                );
              });
        },
      ),
    ));
  }
}
