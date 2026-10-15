# AGENTS.md — Flag Game

## Objetivo
Desenvolver um quiz de bandeiras em Flutter/Dart para a disciplina de Programação para Dispositivos Móveis. Priorizar código simples, legível, organizado e fácil de explicar. Interface em português brasileiro com Material 3.

## Requisitos obrigatórios
- Menu inicial com Jogar por Continente (África, América, Ásia, Europa e Oceania), Jogo Aleatório e Configuração de Tempo.
- Dois formatos de pergunta selecionáveis antes da partida:
  1. **Bandeira → país**: mostrar uma bandeira e quatro nomes de países.
  2. **País → bandeira** (diferencial): mostrar o nome de um país e quatro imagens de bandeiras; exatamente uma correta.
- Tempo total de partida configurável: 30, 60, 180 ou 300 segundos. Exibir tempo restante; encerrar ao chegar a zero.
- Após cada resposta, indicar acerto/erro brevemente e avançar automaticamente; bloquear respostas duplicadas.
- Somar um ponto por acerto. Resultado: total de respostas, acertos, percentual de acertos e botão de voltar ao menu.
- Perguntas aleatórias, sem repetir país na mesma partida até esgotar o conjunto elegível. Alternativas distintas, uma correta e três incorretas, sorteadas do conjunto disponível.
- Respeitar o continente selecionado também nas alternativas. Tratar conjuntos com menos de quatro países sem travar a aplicação.

## Dados e assets
- Utilizar **somente arquivos locais** de bandeiras; nenhuma chamada de rede para jogar.
- Catálogo local em `assets/data/countries.json`, contendo, no mínimo: `code`, `name`, `continent`, `flagAsset`.
- Imagens em `assets/flags/`, referenciadas pelo catálogo e declaradas no `pubspec.yaml`.
- Adotar nomes e códigos consistentes (preferencialmente ISO 3166-1 alpha-2); validar se todo `flagAsset` existe.
- Não inventar imagens ou países ausentes. Caso o conjunto de bandeiras ainda não tenha sido fornecido, criar exemplos claramente identificados e documentar como importar o acervo completo.
- Definir claramente o tratamento de países transcontinentais no catálogo e documentar a convenção; manter os cinco continentes previstos no enunciado.

## Arquitetura simples
Organizar preferencialmente assim:

```text
lib/
  main.dart
  models/country.dart
  models/game_result.dart
  data/country_repository.dart
  services/score_storage.dart
  screens/home_screen.dart
  screens/game_screen.dart
  screens/result_screen.dart
  screens/settings_screen.dart
  screens/leaderboard_screen.dart
  widgets/answer_option.dart
assets/
  data/countries.json
  flags/
test/
```

- Usar `StatefulWidget` e `setState` para o estado local; `Navigator` para navegação.
- Evitar BLoC, Riverpod, Clean Architecture, injeção de dependências e backend sem necessidade comprovada.
- Separar carregamento dos países, regras do quiz, persistência e widgets; extrair classes apenas quando melhorarem a clareza.
- Usar `shared_preferences` para ranking local, se implementado. Não criar banco remoto.
- Preferir dependências mínimas e APIs estáveis do Flutter.

## Regras de implementação
- Antes de alterar arquivos, inspecionar a estrutura existente e preservar código funcional.
- Implementar em incrementos pequenos, explicando o objetivo, os arquivos alterados e como testar cada etapa.
- Não apagar ou substituir arquivos do usuário sem necessidade; não executar comandos destrutivos.
- Tratar corretamente o ciclo de vida do cronômetro: cancelar `Timer` em `dispose`, evitar `setState` após descarte e impedir navegação duplicada no fim da partida.
- O cronômetro é da **partida inteira**, não de cada pergunta.
- Calcular percentual como `acertos / respondidas * 100`, ou zero quando não houver respostas.
- Evitar overflow em telas pequenas e manter botões e bandeiras adequados ao toque.
- Usar comentários para regras não óbvias, não para repetir o código.

## Qualidade e testes
- Criar testes unitários para geração de perguntas, alternativas únicas, filtragem por continente, pontuação e cálculo de resultados.
- Criar ao menos um teste de widget para fluxo básico de jogo ou menu.
- Sempre que possível executar `flutter pub get`, `flutter analyze` e `flutter test` e informar resultados reais; não afirmar que testou se não executou.
- Verificar funcionamento offline, assets ausentes, fim do tempo, resposta no último segundo e retorno ao menu.

## Entrega acadêmica
- Manter `README.md` com descrição, funcionalidades, tecnologias, estrutura, instruções de execução, origem/licença das bandeiras e orientação para o vídeo demonstrativo.
- Preparar projeto para versionamento no GitHub; não incluir arquivos gerados, credenciais ou artefatos de build.
- Funcionalidades extras (ranking, dificuldade, idiomas, animações) são incrementais: primeiro concluir os requisitos essenciais e o modo País → bandeira.

## Comunicação do agente
- Responder em português brasileiro.
- Explicar decisões técnicas de forma didática, incluindo por que a solução escolhida é simples.
- Não adicionar funcionalidades fora do escopo sem consultar o usuário.
