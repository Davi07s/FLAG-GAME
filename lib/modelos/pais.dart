enum Continente {
  africa('África'),
  america('América'),
  asia('Ásia'),
  europa('Europa'),
  oceania('Oceania');

  const Continente(this.rotulo);
  final String rotulo;
}

class Pais {
  const Pais({
    required this.codigo,
    required this.nome,
    required this.continente,
    required this.caminhoBandeira,
  });

  final String codigo;
  final String nome;
  final Continente continente;
  final String caminhoBandeira;

  factory Pais.deJson(Map<String, dynamic> json) {
    String lerTexto(String chave) {
      final valor = json[chave];
      if (valor is! String || valor.trim().isEmpty) {
        throw FormatException('Campo inválido: $chave.');
      }
      return valor.trim();
    }

    final codigo = lerTexto('code');
    if (!RegExp(r'^[a-z]{2}$').hasMatch(codigo)) {
      throw const FormatException(
        'O candidato código deve ter duas letras minúsculas.',
      );
    }
    final nomeContinente = lerTexto('continent');
    final continentes = Continente.values.where(
      (candidato) => candidato.rotulo == nomeContinente,
    );
    if (continentes.isEmpty) {
      throw FormatException('Continente inválido: $nomeContinente.');
    }
    final caminhoBandeira = lerTexto('flagAsset');
    if (caminhoBandeira != 'assets/flags/$codigo.svg') {
      throw FormatException('Caminho de bandeira inválido para $codigo.');
    }
    return Pais(
      codigo: codigo,
      nome: lerTexto('name'),
      continente: continentes.single,
      caminhoBandeira: caminhoBandeira,
    );
  }
}
