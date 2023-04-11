import 'package:flutter/material.dart';

import '../model/imc.dart';
import '../repositories/imc_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var alturaController = TextEditingController();
  var pesoController = TextEditingController();
  var _imcs = const <Imc>[];
  var imcRepository = ImcRepository();

  @override
  void initState() {
    super.initState();
    obterImcs();
  }

  void obterImcs() async {
    _imcs = await imcRepository.listar();
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "IMC's Calculados: ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext bc) {
                            return AlertDialog(
                              title: const Center(child: Text("Informações")),
                              content: const Text(
                                  "Para calcular o IMC, deve ser pressionado o botão no canto inferior esquerdo, e informar os dados solicitados, após isto, será criado uma lista com os IMC's calculados.\n\nPara remover um item da lista basta arrasta-lo para o lado"),
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
              ],
            ),
            const Divider(),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _imcs.length,
                itemBuilder: (BuildContext bc, int index) {
                  var imc = _imcs[index];
                  return Dismissible(
                    onDismissed: (DismissDirection dismissDirection) async {
                      await imcRepository.remover(imc.id);
                      obterImcs();
                    },
                    key: Key(imc.id),
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
                            "Peso: ${imc.peso} Kg\nAltura: ${imc.altura} m\nClassificação: ${imc.classificarIMC()}"),
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
          alturaController.text = "";
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
                        controller: pesoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Peso",
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
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar"),
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

                        await imcRepository.adicionar(Imc(
                          double.parse(pesoController.text),
                          double.parse(alturaController.text),
                          DateTime.now(),
                        ));
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
