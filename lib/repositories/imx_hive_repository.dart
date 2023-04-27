import 'package:hive/hive.dart';

class ImcHiveRepository {
  static late Box _boxImcs;
  static const String _chaveHiveRepository = "box_imcs";

  static Future<ImcHiveRepository> carregar() async {
    if (Hive.isBoxOpen(_chaveHiveRepository)) {
      _boxImcs = Hive.box(_chaveHiveRepository);
    } else {
      _boxImcs = await Hive.openBox(_chaveHiveRepository);
    }
    return ImcHiveRepository._criar();
  }

  void salvar(String chave, dynamic valor) {
    _boxImcs.put(chave, valor);
  }

  dynamic obter(String chave) {
    return _boxImcs.get(chave) ?? "";
  }

  ImcHiveRepository._criar();
}
