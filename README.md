# Flag Game

Projeto acadêmico de Programação para Dispositivos Móveis, em Flutter/Dart, com interface em português brasileiro e Material 3.

## Estado atual — etapa 5

Modelo de país, catálogo JSON local com 195 países (54 da África, 35 da América, 48 da Ásia, 44 da Europa e 14 da Oceania), validação de campos e arquivos, menu com carregamento e tratamento de erro. O menu permite escolher um continente ou jogo aleatório e definir o tempo diretamente na tela inicial. A preparação permite selecionar os dois formatos e iniciar a partida. As bandeiras SVG locais são exibidas com flutter_svg, sem chamadas de rede.

O quiz é jogável nos dois modos, com tempo total, pontuação, indicação de acerto/erro por 800 ms e avanço automático. Ao terminar o tempo, abre a tela de resultados com respostas, acertos, pontos, percentual e botão de voltar ao menu. Conjuntos com menos de quatro países exibem aviso e não permitem iniciar.

As regras estão conectadas à partida: geração de perguntas, quatro alternativas distintas, filtragem por continente, ciclos sem repetição, bloqueio de respostas duplicadas e pontuação. O resultado usa o cálculo do modelo, com percentual zero quando não há respostas.

O tempo padrão é 60 segundos. As opções são 30, 60, 180 e 300 segundos, referentes à partida inteira. A escolha nas cápsulas do menu é aplicada imediatamente, sem abrir outra tela ou confirmar. A preferência permanece somente em memória durante a sessão. Cada preparação começa no modo Bandeira → país.

## Plano de desenvolvimento

1. Estrutura básica, modelo Pais e carregamento do catálogo (implementado).
2. Menu, seleção de continente, formato e duração (30, 60, 180 ou 300 segundos) (implementado).
3. Regras de perguntas e pontuação: alternativas distintas, mesmo continente e países sem repetição até esgotar o conjunto (implementado).
4. Partida nos modos bandeira → país e país → bandeira, SVGs locais, tempo total e resposta com retorno visual (implementado).
5. Resultados, testes dos casos de limite e revisão da entrega (implementado; conferência manual em dispositivo e confirmação da licença do acervo pendentes).

Cada etapa depende de autorização antes do início da próxima. Ranking é opcional e não faz parte desta implementação.

## Tecnologias e estrutura

Flutter, Dart, Material 3 e flutter_svg para renderizar os SVGs locais. Nenhum serviço online foi adicionado.

- lib/main.dart: entrada e tema.
- lib/modelos/pais.dart: Pais imutável e enum Continente.
- lib/dados/repositorio_paises.dart: leitura, conversão e validação dos arquivos.
- lib/modelos/modo_pergunta.dart: enum dos dois formatos de pergunta.
- lib/modelos/pergunta.dart: país da pergunta e alternativas protegidas contra alteração.
- lib/modelos/resultado_partida.dart: respostas, acertos, pontos e percentual.
- lib/servicos/sessao_quiz.dart: sorteio, controle de respostas e pontuação da sessão.
- lib/telas/tela_inicial.dart: menu e duração escolhida na sessão.
- A seleção de tempo fica em lib/telas/tela_inicial.dart; não há tela separada.
- lib/telas/tela_preparacao.dart: seleção de formato e resumo da preparação.
- lib/telas/tela_jogo.dart: partida e cronômetro.
- lib/telas/tela_resultado.dart: resumo imutável da partida e retorno ao menu.
- lib/componentes/alternativa_resposta.dart: botão de alternativa com nome ou bandeira e indicação de acerto/erro.
- lib/componentes/imagem_bandeira.dart: exibição de SVG local com carregamento e mensagem de falha.
- assets/data/countries.json: catálogo utilizado pelo aplicativo.
- assets/flags/: todos os 271 SVGs extraídos do ZIP, com os nomes originais.
- test/: testes dos modelos, repositório, regras, menu, partida e resultados.

O estado das telas usa StatefulWidget/setState. Navigator.push abre as telas com MaterialPageRoute; Navigator.pop retorna o continente escolhido. Os dados são passados pelos construtores. Não há backend nem chamadas de rede para carregar países ou bandeiras.

## Regras da sessão — etapa 3

SessaoQuiz recebe a lista do catálogo e, opcionalmente, um continente. As perguntas e suas alternativas usam somente o conjunto filtrado. Sem continente, todo o catálogo participa. Não há referência a widgets, cronômetro ou arquivos nessa classe.

- proximaPergunta() retorna uma pergunta com quatro países distintos, sendo um correto. Enquanto a pergunta aguarda resposta, chamadas repetidas retornam a mesma pergunta.
- Após responder todos os países de um ciclo, a lista é embaralhada novamente. A repetição entre ciclos é permitida.
- responder(codigo) retorna true para acerto, false para erro e null quando a resposta é ignorada (duplicada, opção ausente, sessão encerrada ou sem pergunta). Cada resposta válida aumenta o total; cada acerto soma um ponto.
- encerrar() encerra a sessão e impede novas perguntas ou respostas. A tela chama esse método ao terminar o tempo total.
- resultado fornece uma cópia imutável das contagens. percentualAcertos calcula acertos / respondidas * 100, ou zero sem respostas.
- Com menos de quatro países, podeJogar é false e proximaPergunta() retorna null. Nenhuma alternativa é inventada nem buscada fora do continente.

Pergunta contém objetos Pais, que já fornecem nome e caminho da bandeira. Assim, a mesma regra atende aos dois formatos; só a apresentação muda. Listas são copiadas para não embaralhar o catálogo originais. Random com semente nos testes permite reproduzir os sorteios.

Para validar especificamente as regras, execute `flutter test test/sessao_quiz_test.dart`. Esses testes usam dados sintéticos identificados como teste, sem adicionar países ou bandeiras ao catálogo real.

## Partida — etapa 4

O início substitui a tela de preparação com Navigator.pushReplacement, de modo que voltar da partida retorna ao menu. O tempo é da partida inteira e continua correndo durante a indicação de resposta. A seleção bloqueia as quatro alternativas imediatamente; uma resposta válida soma ao total, e um acerto soma um ponto.

Timer.periodic atualiza o tempo restante. Um prazo baseado em DateTime também é verificado antes de aceitar respostas e ao retomar o aplicativo, para considerar tempo em segundo plano. O encerramento é protegido contra execução duplicada. O temporizador principal e o temporizador de avanço são cancelados tanto no fim da partida quanto em dispose; callbacks verificam mounted antes de atualizar a tela.

As imagens são carregadas apenas com SvgPicture.asset. Os rótulos das bandeiras não revelam o nome do país antes da resposta. O catálogo é validado antes de abrir o menu; a imagem também apresenta mensagem caso não possa ser renderizada.

## Resultados e revisão — etapa 5

No encerramento, os timers são cancelados e a sessão produz um ResultadoPartida imutável. Navigator.pushReplacement substitui a partida pelo resultado, impedindo retornar a uma partida encerrada. A marcação de encerramento ocorre antes da navegação para impedir abertura duplicada.

TelaResultado é StatelessWidget: recebe o resultado pelo construtor e não altera a pontuação. Exibe respostas, acertos, erros, pontos e percentual arredondado para uma casa decimal, com vírgula. O modelo mantém o valor sem arredondamento. Sem respostas, mostra 0,0% e uma mensagem explicativa. A lista permite rolar em telas pequenas e com fonte ampliada.

Voltar ao menu remove as rotas intermediárias com Navigator.popUntil. Uma nova partida cria outra SessaoQuiz e começa com zero pontos. Sair durante a partida cancela os timers, sem abrir resultados depois.

## Executar e testar

Com o Flutter instalado e um dispositivo/emulador disponível:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

A tela deve mostrar “195 países carregados” e os botões do menu. Para testar esta etapa:

1. Toque em 3 min no menu e confira o resumo de 180 segundos.
2. Toque em 5 min e confira a mudança imediata para 300 segundos; selecione novamente 3 min para continuar.
3. Escolha um continente: a preparação deve mostrar a contagem do continente escolhido e o tempo salvo.
4. Alterne entre Bandeira → país e País → bandeira e inicie. Confira a bandeira com quatro nomes no primeiro modo, ou o nome com quatro bandeiras no segundo.
5. Responda e tente tocar outra alternativa imediatamente: deve contar apenas uma resposta. Confira o acerto/erro e o avanço automático.
6. Espere o tempo terminar, inclusive durante a indicação de resposta: deve abrir Resultado com Tempo esgotado!, respostas, acertos, pontos e percentual. Use Voltar ao menu e confira que outra partida começa com zero pontos.
7. Abra Jogo aleatório: devem aparecer 195 países disponíveis na preparação. Repita nos dois modos.
8. Confira a rolagem em uma tela pequena. Depois de instalar, abra sem conexão e jogue para conferir os arquivos locais. Esta conferência manual em dispositivo ainda precisa ser realizada.

Os testes verificam o catálogo empacotado, contagens e correspondências por continente, dados inválidos, códigos duplicados, arquivo ausente, menu, navegação, seleção direta do tempo no menu, seleção de modos e tela pequena. Também verificam ciclos de perguntas sem repetição, alternativas únicas, uma correta, filtragem por continente, conjuntos insuficientes, bloqueio de respostas, encerramento, pontuação e percentuais. A partida tem testes para os dois modos com SVGs reais, acerto/erro, avanço, cancelamento de timers ao descartar, tempo esgotado, resposta no último segundo, tela pequena e fluxo do menu até o encerramento. Execute `flutter test test/tela_jogo_test.dart` para os testes específicos da partida.

Os testes de resultado conferem as contagens, percentual com arredondamento, ausência de respostas e tela pequena com fonte ampliada. Execute `flutter test test/tela_resultado_test.dart`. O fluxo de menu verifica também retorno, início de outra partida e saída sem timers pendentes.

## Catálogo e importação do acervo

O catálogo inclui 195 países no escopo documentado, usando somente imagens fornecidas no ZIP. O acervo originais em lib/assets/ foi preservado. Símbolos de organizações, subdivisões e territórios presentes no acervo não são automaticamente incluídos como países.

Para ampliar o catálogo:

1. Copie uma bandeira existente para assets/flags/<codigo>.svg.
2. Adicione um registro ao JSON com code (ISO alpha-2 minúsculo), name em português, continent e flagAsset. Os nomes desses campos permanecem no formato original do catálogo.
3. Use um dos cinco valores exatos: África, América, Ásia, Europa e Oceania.
4. Use o caminho assets/flags/<codigo>.svg e não repita códigos.
5. Execute flutter test para verificar o carregamento. Ao ampliar a amostra, atualize as contagens esperadas nos testes.

Convenção do projeto: América reúne Norte, Central e Sul; cada país pertence a um único continente. Egito fica na África; Rússia na Europa; Turquia, Cazaquistão, Azerbaijão, Geórgia, Armênia, Chipre, Indonésia e Timor-Leste na Ásia. Essas escolhas são convenções pedagógicas para evitar duplicidade, não uma afirmação de fronteiras incontestáveis.

## Origem e licença das bandeiras

Os 271 SVGs foram extraídos do ZIP fornecido chamado “lipis flag-icons main flags-4x3”. O nome indica o projeto lipis/flag-icons (https://github.com/lipis/flag-icons), conhecido pela licença MIT. O acervo recebido não inclui um arquivo de licença: a procedência e o aviso de copyright da versão utilizada precisam ser confirmados e incluídos antes da distribuição acadêmica. Nenhuma imagem foi baixada ou inventada nesta etapa.

## Versionamento e vídeo

A pasta ainda precisa ser inicializada como repositório Git. Confira o .gitignore antes de publicar; não inclua credenciais, configurações locais, .dart_tool/ ou build/.

O .gitignore da raiz e os arquivos das plataformas excluem builds, caches, configurações do SDK e arquivos gerados. A raiz também exclui .codex/, arquivos .env e chaves de assinatura. Mantenha pubspec.lock no versionamento do aplicativo. Não foi criado repositório remoto nem publicada a aplicação.

Roteiro sugerido para o vídeo:

1. Apresente o objetivo acadêmico e o catálogo local de 195 países.
2. Configure 30 segundos e escolha um continente.
3. Jogue Bandeira → país, mostrando acerto, erro e bloqueio de toque repetido.
4. Aguarde o tempo total terminar e explique as estatísticas do resultado.
5. Volte ao menu e jogue País → bandeira no modo aleatório.
6. Demonstre uma partida sem conexão, com o aplicativo já instalado.
7. Mostre brevemente Pais, SessaoQuiz, StatefulWidget/setState, Navigator e os testes.

Antes da entrega, ainda é necessário conferir em dispositivo/emulador os dois modos offline, passagem para segundo plano e retorno após o prazo, botão de voltar do sistema e legibilidade. Confirme e inclua o aviso de licença das bandeiras fornecidas. A aprovação de testes automatizados não substitui essa conferência manual.


## Acervo completo e critério de inclusão

A implementação inicial usava uma amostra explícita de 20 registros no JSON: carregar o catálogo não descobre imagens automaticamente. Essa limitação foi removida.

O ZIP `lipis flag-icons main flags-4x3.zip` contém 271 SVGs. Todos foram extraídos para assets/flags/ com os nomes originais; o diretório original em lib/assets/ foi preservado. O catálogo countries.json contém 195 países, com código ISO 3166-1 alpha-2 em minúsculas, nome em português brasileiro, continente e caminho do SVG.

Escopo: os [193 membros da ONU](https://research.un.org/en/unmembers/currentmembers) mais [Palestina e Santa Sé](https://research.un.org/en/unmembers/observers). Para a Santa Sé, usa-se o nome exibido Vaticano e o código va. As convenções continentais seguem as regiões [M49 da ONU](https://unstats.un.org/unsd/methodology/m49/overview/), agrupando as Américas. A classificação serve ao jogo; não resolve disputas territoriais.

| Continente | Países jogáveis |
| --- | ---: |
| África | 54 |
| América | 35 |
| Ásia | 48 |
| Europa | 44 |
| Oceania | 14 |
| Total | 195 |

Os 76 SVGs restantes estão identificados em assets/data/other_flags.json, com nome, categoria, caminho, código ISO quando aplicável e motivo de exclusão do quiz. São 54 entradas na categoria territory (áreas com código ISO fora do escopo), 14 em region (subdivisões e outros códigos), sete organizações e uma bandeira genérica. Essas categorias são de inventário, não definições de soberania: Taiwan, Kosovo, Saara Ocidental, Ilhas Cook e Niue permanecem identificados separadamente. Organizações como ONU, União Europeia e Comunidade do Pacífico nunca são alternativas de países.

O pubspec.yaml declara assets/data/ e assets/flags/. Os dois formatos usam o mesmo catálogo completo e continuam exibindo as imagens com flutter_svg, sem acesso à rede durante a partida.

Para validar especificamente o acervo, execute `flutter test test/catalogo_completo_test.dart`: cobre os 271 arquivos, códigos únicos, exclusões explícitas, correspondências de países e continentes (incluindo casos transcontinentais), ciclos completos por continente e decodificação das 195 bandeiras pelo flutter_svg. A suíte completa mantém os testes dos dois modos e do fluxo do menu.

### Compatibilidade de SVG

Os originais us.svg e um.svg desenham estrelas com marker-mid, não suportado pelo flutter_svg. Os 271 originais permanecem idênticos ao ZIP. Duas cópias derivadas em assets/flags/compatible/ substituem os marcadores por 50 paths com as mesmas formas e posições. ImagemBandeira seleciona essas cópias somente para renderização; o catálogo mantém os caminhos originais. Não foram baixadas nem inventadas bandeiras. O teste de decodificação usa os mesmos caminhos de exibição do aplicativo.

## Interface visual — menu principal

A primeira tela foi adaptada ao PDF “Flag Game — Modelo de Interface”: fundo roxo-escuro, título amarelo/rosa, globo decorativo feito com widgets, botões arredondados com sombra e seleção rápida de 30s, 60s, 3 min e 5 min. Nenhuma dependência foi adicionada e o AGENTS.md foi preservado.

O tema é local ao menu; as demais telas ainda aguardam suas etapas visuais. Jogar por Continente abre a tela dedicada de seleção. As quatro opções de Tempo de jogo são configuradas diretamente no menu, sem tela ou ícone de ajustes. Ranking e idiomas não foram acrescentados; PT-BR é apenas um rótulo. A tipografia usa a fonte disponível no sistema, com peso forte, aproximando o modelo sem carregar fontes pela rede.

Arquivos: tela_inicial.dart, componentes/acao_menu.dart e componentes/globo_menu.dart. SingleChildScrollView permite rolagem, ConstrainedBox limita a largura em telas grandes e Wrap acomoda os tempos em telas pequenas. StatefulWidget/setState e Navigator continuam controlando estado e navegação.

Para conferir: execute flutter run, altere os quatro tempos no menu, abra a seleção de continentes e inicie partidas nos dois modos. Confira também a rolagem com tela pequena e fonte ampliada. A seleção de continentes também foi implementada na etapa seguinte.


## Interface visual — seleção de continentes

TelaContinentes segue a segunda página do PDF: fundo roxo, título amarelo, botão de voltar, cartões arredondados com sombra e ícones em círculos brancos. África é laranja; América, verde; Ásia, rosa; Europa, azul; Oceania, ciano e ocupa a largura inteira no layout de duas colunas.

LayoutBuilder calcula a largura dos cartões, e Wrap organiza duas colunas ou uma coluna quando a tela é estreita ou a fonte está ampliada. SingleChildScrollView permite acessar todos os cartões. A altura dos cartões acompanha o texto, sem grade com altura fixa.

A tela usa StatelessWidget porque apenas devolve uma escolha. Navigator.pop retorna um Continente ao menu, que abre TelaPreparacao com o catálogo local completo e o tempo já selecionado. Voltar sem selecionar mantém o menu e o tempo. O fluxo aleatório continua abrindo a preparação diretamente.

Arquivos: lib/telas/tela_continentes.dart, lib/telas/tela_inicial.dart e test/tela_inicial_test.dart. Nenhuma dependência, regra de jogo ou arquivo AGENTS.md foi alterado.

Para testar: escolha 3 min, abra Jogar por Continente e selecione cada cartão. A preparação deve mostrar respectivamente 54, 35, 48, 44 ou 14 países, mantendo 180 segundos. Confira também voltar sem selecionar e a rolagem em tela pequena com fonte ampliada. A tela de perguntas foi adaptada na etapa seguinte.


## Interface visual — perguntas

A partida segue a terceira página do PDF: fundo roxo com elementos decorativos, botão de sair, placar amarelo, relógio rosa no formato minutos:segundos e barra verde representando a fração do tempo total restante. O modo e o continente continuam identificados na tela.

Em Bandeira → país, a imagem local aparece em um cartão branco arredondado e as quatro alternativas exibem nomes. Em País → bandeira, o nome aparece no enunciado e as quatro imagens locais ficam em duas colunas, ou em uma coluna para telas estreitas/fontes ampliadas. As alternativas têm altura ajustável e a tela permite rolagem.

Antes de responder, os botões são brancos. Depois, a alternativa correta fica verde com confirmação, a escolhida incorreta fica rosa com ícone de erro e as demais ficam apagadas. A mensagem de acerto/erro continua acessível com Semantics.liveRegion. O indicador do tempo possui descrição para leitores de tela. Os nomes dos países não são revelados nos rótulos acessíveis das imagens antes da resposta.

Arquivos alterados: lib/telas/tela_jogo.dart, lib/componentes/alternativa_resposta.dart e test/tela_jogo_test.dart. O layout usa Theme local, Container/BoxDecoration, ClipRRect, Wrap/LayoutBuilder e LinearProgressIndicator. Estado, sorteio, pontuação, prazo total, bloqueio de respostas e descarte de timers permanecem com a implementação existente. Não há nova dependência nem alteração no AGENTS.md ou no catálogo.

Para conferir, execute flutter run e inicie partidas nos dois modos. Responda certo e errado, observe as cores/ícones, aguarde o avanço e confira que o relógio não reinicia. Teste também a rolagem com fonte ampliada e o botão de sair. Os testes verificam os dois formatos em tela pequena com fonte ampliada, os estados das alternativas, a barra e o relógio, além dos casos de limite já existentes. A tela de resultados foi adaptada na etapa seguinte.


## Interface visual — resultados

TelaResultado segue a quarta página do PDF: fundo roxo, título amarelo, indicador circular verde com percentual central, estrelas decorativas e cartões roxos para respondidas, acertos e erros. A pontuação e a mensagem de tempo esgotado continuam visíveis. O percentual é calculado pelo ResultadoPartida, preservando a regra de zero quando não há respostas; a apresentação usa uma casa decimal com vírgula.

CircularProgressIndicator usa percentualAcertos / 100 e uma descrição acessível. Os cartões possuem rótulos Semantics com as contagens, e as estrelas são apenas decoração, sem criar regra de premiação. LayoutBuilder e Wrap passam os cartões para uma coluna quando a largura ou a fonte exigem. SingleChildScrollView permite acessar as ações em telas pequenas.

Jogar de novo inicia uma nova TelaJogo com os mesmos países, continente, formato e duração, substituindo o resultado com Navigator.pushReplacement. A nova SessaoQuiz começa com zero pontos e respostas. Voltar ao menu mantém Navigator.popUntil. O resultado recebe um WidgetBuilder opcional para a repetição, sem dependência das regras ou do estado da partida; a partida real sempre fornece esse construtor.

Arquivos alterados: tela_resultado.dart, tela_jogo.dart, test/tela_resultado_test.dart e test/tela_jogo_test.dart. Nenhuma dependência, catálogo ou AGENTS.md foi alterado.

Para testar: termine uma partida, confira o percentual e as três contagens, use Jogar de novo e confirme a configuração preservada e os pontos zerados. Termine outra partida e volte ao menu. Confira também ausência de respostas, 100% de acertos e rolagem com fonte ampliada. As quatro telas do PDF estão adaptadas; o tempo é escolhido diretamente no menu; a preparação também recebeu o tema visual na correção seguinte.


## Interface visual — preparação da partida

A tela intermediária de preparação também utiliza fundo roxo, título amarelo, cartão de resumo e botão verde de iniciar. Os dois formatos são cartões selecionáveis: ciano para Bandeira → país e rosa para País → bandeira. Texto, borda e ícone indicam o modo selecionado, inclusive com Semantics.selecionado.

TelaPreparacao mantém StatefulWidget/setState, os dados recebidos pelo construtor e a navegação existente. SingleChildScrollView, largura máxima e textos em Expanded permitem rolagem e quebra de linha. O bloqueio para conjuntos com menos de quatro países permanece. Nenhuma dependência, regra, catálogo ou AGENTS.md foi alterado.

Para conferir: abra um continente ou Jogo aleatório, alterne os dois formatos e inicie. O continente, o tempo e a quantidade de países devem permanecer corretos. Confira a tela também em dispositivo pequeno.

## Refatoração: português, simplificação e responsividade

A refatoração preserva o visual, os dois modos, os 195 países e todos os SVGs. Não foram adicionadas dependências. O AGENTS.md permaneceu intacto.

### Organização atual

```text
lib/
  main.dart
  modelos/       # Pais, Continente, Pergunta, ModoPergunta e ResultadoPartida
  dados/         # RepositorioPaises e leitura do catálogo
  servicos/      # SessaoQuiz: sorteio, respostas e pontuação
  telas/         # TelaInicial, TelaContinentes, TelaPreparacao, TelaJogo e TelaResultado
  componentes/   # AlternativaResposta, ImagemBandeira, AcaoMenu, GloboMenu e temaJogo
test/
  catalogo_completo_test.dart
  repositorio_paises_test.dart
  sessao_quiz_test.dart
  tela_inicial_test.dart
  tela_jogo_test.dart
  tela_resultado_test.dart
  responsividade_jogo_test.dart
```

Os identificadores próprios usam português sem acentos: quantidadePaises, proximaPergunta, caminhoBandeira e percentualAcertos. Permanecem os nomes obrigatórios das APIs, como build, initState, dispose, setState, context e Navigator. Também permanecem main.dart, test/, diretórios das plataformas, códigos ISO, nomes dos SVGs e as chaves code/name/continent/flagAsset do JSON. Não é necessário migrar os dados.

### Simplificações

O tema repetido nas cinco telas fica em componentes/tema_jogo.dart. A decoração do globo está no próprio componente, sem classe auxiliar. A escolha da cor da alternativa usa if/else explícitos. acertou representa um valor booleano; acertos representa uma contagem. Esses ajustes mantêm StatefulWidget/setState e Navigator, sem camadas intermediárias.

### Quiz sem rolagem nos celulares comuns

O cabeçalho com pontuação e cronômetro fica fora da parte rolável. SafeArea desconta as barras do sistema; LayoutBuilder fornece a altura útil. A altura do texto é medida com TextPainter, respeitando a escala da fonte, para reservar espaço para o enunciado, nomes completos e indicação de resposta. A bandeira é reduzida proporcionalmente antes de comprometer as alternativas.

No modo Bandeira → país, as quatro alternativas dividem o espaço restante com Expanded. No modo País → bandeira, as imagens ficam sempre em uma grade 2 × 2, com altura proporcional à área disponível. Os botões mantêm pelo menos 48 pontos lógicos de altura nos cenários de celular validados. Não há corte de nomes ou redução da escala de acessibilidade.

Quando a altura é excepcionalmente pequena ou a fonte está ampliada, apenas a área da pergunta usa SingleChildScrollView; o cabeçalho continua visível. A rolagem de segurança não é bloqueada. Estas regras substituem as descrições anteriores de uma coluna ou de rolagem geral da partida.

Os testes de responsividade verificam as quatro alternativas inteiras antes/depois da resposta, grade 2 × 2, áreas de toque, barras do sistema e nomes longos reais, em 360 × 640, 375 × 667, 390 × 844 e 412 × 915. Também verificam rolagem de segurança em 320 × 480 e 640 × 360 com fonte 1,6 vezes maior, sem mover o placar e o relógio.

Execute dart format lib test, flutter analyze e flutter test. Para verificar somente o layout: flutter test test/responsividade_jogo_test.dart. Os testes de widget simulam tamanhos lógicos; a conferência manual em dispositivos físicos continua recomendada para a entrega.


### Resultados das verificações desta refatoração

| Etapa | dart format | flutter analyze | flutter test |
| --- | --- | --- | --- |
| 1 — renomeação | Executado | Sem problemas | 42 aprovados |
| 2 — simplificação | Executado | Sem problemas | 42 aprovados |
| 3 — responsividade e revisão final | Executado | Sem problemas | 54 aprovados |

As verificações de responsividade foram automatizadas em testes de widgets; não representam execução manual em todos os dispositivos físicos. A refatoração não publicou commits no GitHub.

## Ajuste visual após a refatoração

Os botões e cartões das bandeiras recuperaram o estilo anterior: bordas de 30 pontos e sombras de 6 pontos nas alternativas, imagem recortada com cantos arredondados, indicadores circulares maiores e confirmação abaixo da imagem. O cartão da bandeira da pergunta usa a moldura branca de 16 pontos, cantos externos de 32, internos de 20 e sombra de 8.

O dimensionamento responsivo foi mantido. A tipografia dos nomes começa em 20 pontos e só reduz quando necessário para acomodar as quatro opções. Nas células menores do modo inverso, ícone e texto de confirmação ficam lado a lado abaixo da bandeira. A grade continua 2 × 2, com placar e cronômetro fixos e rolagem de segurança apenas quando necessária.

No modo País → bandeira, a margem interna dos cartões foi reduzida para 8 pontos e os cantos externos para 20. A altura acompanha a proporção 4:3 das imagens em vez de preencher toda a altura livre da grade; após responder, há espaço adicional para a confirmação. Fontes ampliadas preservam o espaço e a rolagem de segurança. O cartão da pergunta e os botões do modo Bandeira → país não foram alterados neste ajuste.
