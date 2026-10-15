enum Continent {
  africa('África'),
  america('América'),
  asia('Ásia'),
  europe('Europa'),
  oceania('Oceania');

  const Continent(this.label);
  final String label;
}

class Country {
  const Country({
    required this.code,
    required this.name,
    required this.continent,
    required this.flagAsset,
  });

  final String code;
  final String name;
  final Continent continent;
  final String flagAsset;

  factory Country.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Campo inválido: $key.');
      }
      return value.trim();
    }

    final code = readString('code');
    if (!RegExp(r'^[a-z]{2}$').hasMatch(code)) {
      throw const FormatException('O código deve ter duas letras minúsculas.');
    }
    final continentName = readString('continent');
    final continents = Continent.values.where((c) => c.label == continentName);
    if (continents.isEmpty) {
      throw FormatException('Continente inválido: $continentName.');
    }
    final flagAsset = readString('flagAsset');
    if (flagAsset != 'assets/flags/$code.svg') {
      throw FormatException('Caminho de bandeira inválido para $code.');
    }
    return Country(
      code: code,
      name: readString('name'),
      continent: continents.single,
      flagAsset: flagAsset,
    );
  }
}
