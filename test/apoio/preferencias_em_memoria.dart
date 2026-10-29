import 'package:shared_preferences/shared_preferences.dart';

// Simula o armazenamento da plataforma, compartilhado entre novas instâncias.
class PreferenciasEmMemoria implements SharedPreferencesAsync {
  PreferenciasEmMemoria(this.dados, {this.falharGravacao = false});
  final Map<String, String> dados;
  final bool falharGravacao;

  @override
  Future<String?> getString(String key) async => dados[key];

  @override
  Future<void> setString(String key, String value) async {
    if (falharGravacao) throw StateError('Falha simulada');
    dados[key] = value;
  }

  @override
  Future<void> remove(String key) async => dados.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocacao) => super.noSuchMethod(invocacao);
}
