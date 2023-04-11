import '../model/imc.dart';

class ImcRepository {
  final List<Imc> _imcs = [];

  Future<void> adicionar(Imc imc) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _imcs.add(imc);
  }

  Future<void> remover(String id) async {
    await Future.delayed(const Duration(microseconds: 100));
    _imcs.remove(_imcs.where((imc) => imc.id == id).first);
  }

  Future<List<Imc>> listar() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _imcs;
  }
}
