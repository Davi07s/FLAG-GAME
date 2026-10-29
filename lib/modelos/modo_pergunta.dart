enum ModoPergunta {
  bandeiraParaPais(
    'Bandeira → país',
    'Identifique o país pela bandeira exibida.',
  ),
  paisParaBandeira(
    'País → bandeira',
    'Escolha a bandeira a partir do nome do país.',
  );

  const ModoPergunta(this.rotulo, this.descricao);

  final String rotulo;
  final String descricao;
}
