enum QuizMode {
  flagToCountry('Bandeira → país', 'Identifique o país pela bandeira exibida.'),
  countryToFlag(
    'País → bandeira',
    'Escolha a bandeira a partir do nome do país.',
  );

  const QuizMode(this.label, this.description);

  final String label;
  final String description;
}
