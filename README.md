# Flag Game

Projeto acadêmico de Programação para Dispositivos Móveis, em Flutter/Dart, com interface em português brasileiro e Material 3.

## Estado atual — etapa 5

Modelo de país, catálogo JSON local com 195 países (54 da África, 35 da América, 48 da Ásia, 44 da Europa e 14 da Oceania), validação de campos e arquivos, menu com carregamento e tratamento de erro. O menu permite escolher um continente ou jogo aleatório e abrir a configuração de tempo. A preparação permite selecionar os dois formatos e iniciar a partida. As bandeiras SVG locais são exibidas com flutter_svg, sem chamadas de rede.

O quiz é jogável nos dois modos, com tempo total, pontuação, indicação de acerto/erro por 800 ms e avanço automático. Ao terminar o tempo, abre a tela de resultados com respostas, acertos, pontos, percentual e botão de voltar ao menu. Conjuntos com menos de quatro países exibem aviso e não permitem iniciar.

As regras estão conectadas à partida: geração de perguntas, quatro alternativas distintas, filtragem por continente, ciclos sem repetição, bloqueio de respostas duplicadas e pontuação. O resultado usa o cálculo do modelo, com percentual zero quando não há respostas.

O tempo padrão é 60 segundos. As opções são 30, 60, 180 e 300 segundos, referentes à partida inteira. Salvar retorna a escolha ao menu; voltar sem salvar descarta a alteração. A preferência permanece somente em memória durante a sessão. Cada preparação começa no modo Bandeira → país.

## Plano de desenvolvimento

1. Estrutura básica, modelo Country e carregamento do catálogo (implementado).
2. Menu, seleção de continente, formato e duração (30, 60, 180 ou 300 segundos) (implementado).
3. Regras de perguntas e pontuação: alternativas distintas, mesmo continente e países sem repetição até esgotar o conjunto (implementado).
4. Partida nos modos bandeira → país e país → bandeira, SVGs locais, tempo total e resposta com retorno visual (implementado).
5. Resultados, testes dos casos de limite e revisão da entrega (implementado; conferência manual em dispositivo e confirmação da licença do acervo pendentes).

Cada etapa depende de autorização antes do início da próxima. Ranking é opcional e não faz parte desta implementação.

## Tecnologias e estrutura

Flutter, Dart, Material 3 e flutter_svg para renderizar os SVGs locais. Nenhum serviço online foi adicionado.

- lib/main.dart: entrada e tema.
- lib/models/country.dart: Country imutável e enum Continent.
- lib/data/country_repository.dart: leitura, conversão e validação dos assets.
- lib/models/quiz_mode.dart: enum dos dois formatos de pergunta.
- lib/models/quiz_question.dart: país da pergunta e alternativas protegidas contra alteração.
- lib/models/game_result.dart: respostas, acertos, pontos e percentual.
- lib/services/quiz_session.dart: sorteio, controle de respostas e pontuação da sessão.
- lib/screens/home_screen.dart: menu e duração escolhida na sessão.
- lib/screens/settings_screen.dart: escolha e confirmação do tempo.
- lib/screens/game_setup_screen.dart: seleção de formato e resumo da preparação.
- lib/screens/game_screen.dart: partida e cronômetro.
- lib/screens/result_screen.dart: resumo imutável da partida e retorno ao menu.
- lib/widgets/answer_option.dart: botão de alternativa com nome ou bandeira e indicação de acerto/erro.
- lib/widgets/flag_image.dart: exibição de SVG local com carregamento e mensagem de falha.
- assets/data/countries.json: catálogo utilizado pelo aplicativo.
- assets/flags/: todos os 271 SVGs extraídos do ZIP, com os nomes originais.
- test/: testes dos modelos, repositório, regras, menu, partida e resultados.

O estado das telas usa StatefulWidget/setState. Navigator.push abre as telas com MaterialPageRoute; Navigator.pop retorna o tempo salvo. Os dados são passados pelos construtores. Não há backend nem chamadas de rede para carregar países ou bandeiras.

## Regras da sessão — etapa 3

QuizSession recebe a lista do catálogo e, opcionalmente, um continente. As perguntas e suas alternativas usam somente o conjunto filtrado. Sem continente, todo o catálogo participa. Não há referência a widgets, cronômetro ou arquivos nessa classe.

- nextQuestion() retorna uma pergunta com quatro países distintos, sendo um correto. Enquanto a pergunta aguarda resposta, chamadas repetidas retornam a mesma pergunta.
- Após responder todos os países de um ciclo, a lista é embaralhada novamente. A repetição entre ciclos é permitida.
- submitAnswer(code) retorna true para acerto, false para erro e null quando a resposta é ignorada (duplicada, opção ausente, sessão encerrada ou sem pergunta). Cada resposta válida aumenta o total; cada acerto soma um ponto.
- finish() encerra a sessão e impede novas perguntas ou respostas. A tela chama esse método ao terminar o tempo total.
- result fornece uma cópia imutável das contagens. accuracy calcula acertos / respondidas * 100, ou zero sem respostas.
- Com menos de quatro países, canPlay é false e nextQuestion() retorna null. Nenhuma alternativa é inventada nem buscada fora do continente.

QuizQuestion contém objetos Country, que já fornecem nome e caminho da bandeira. Assim, a mesma regra atende aos dois formatos; só a apresentação muda. Listas são copiadas para não embaralhar o catálogo original. Random com semente nos testes permite reproduzir os sorteios.

Para validar especificamente as regras, execute `flutter test test/quiz_session_test.dart`. Esses testes usam dados sintéticos identificados como teste, sem adicionar países ou bandeiras ao catálogo real.

## Partida — etapa 4

O início substitui a tela de preparação com Navigator.pushReplacement, de modo que voltar da partida retorna ao menu. O tempo é da partida inteira e continua correndo durante a indicação de resposta. A seleção bloqueia as quatro alternativas imediatamente; uma resposta válida soma ao total, e um acerto soma um ponto.

Timer.periodic atualiza o tempo restante. Um prazo baseado em DateTime também é verificado antes de aceitar respostas e ao retomar o aplicativo, para considerar tempo em segundo plano. O encerramento é protegido contra execução duplicada. O timer principal e o timer de avanço são cancelados tanto no fim da partida quanto em dispose; callbacks verificam mounted antes de atualizar a tela.

As imagens são carregadas apenas com SvgPicture.asset. Os rótulos das bandeiras não revelam o nome do país antes da resposta. O catálogo é validado antes de abrir o menu; a imagem também apresenta mensagem caso não possa ser renderizada.

## Resultados e revisão — etapa 5

No encerramento, os timers são cancelados e a sessão produz um GameResult imutável. Navigator.pushReplacement substitui a partida pelo resultado, impedindo retornar a uma partida encerrada. A marcação de encerramento ocorre antes da navegação para impedir abertura duplicada.

ResultScreen é StatelessWidget: recebe o resultado pelo construtor e não altera a pontuação. Exibe respostas, acertos, pontos e percentual arredondado para uma casa decimal, com vírgula. O modelo mantém o valor sem arredondamento. Sem respostas, mostra 0,0% e uma mensagem explicativa. A lista permite rolar em telas pequenas e com fonte ampliada.

Voltar ao menu remove as rotas intermediárias com Navigator.popUntil. Uma nova partida cria outra QuizSession e começa com zero pontos. Sair durante a partida cancela os timers, sem abrir resultados depois.

## Executar e testar

Com o Flutter instalado e um dispositivo/emulador disponível:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

A tela deve mostrar “195 países carregados” e os botões do menu. Para testar esta etapa:

1. Abra Configuração de tempo, escolha 180 segundos e salve. Confira o tempo no menu.
2. Abra novamente, selecione 300 segundos e volte sem salvar; o menu deve manter 180 segundos.
3. Escolha um continente: a preparação deve mostrar a contagem do continente escolhido e o tempo salvo.
4. Alterne entre Bandeira → país e País → bandeira e inicie. Confira a bandeira com quatro nomes no primeiro modo, ou o nome com quatro bandeiras no segundo.
5. Responda e tente tocar outra alternativa imediatamente: deve contar apenas uma resposta. Confira o acerto/erro e o avanço automático.
6. Espere o tempo terminar, inclusive durante a indicação de resposta: deve abrir Resultado com Tempo esgotado!, respostas, acertos, pontos e percentual. Use Voltar ao menu e confira que outra partida começa com zero pontos.
7. Abra Jogo aleatório: devem aparecer 195 países disponíveis na preparação. Repita nos dois modos.
8. Confira a rolagem em uma tela pequena. Depois de instalar, abra sem conexão e jogue para conferir os assets locais. Esta conferência manual em dispositivo ainda precisa ser realizada.

Os testes verificam o catálogo empacotado, contagens e correspondências por continente, dados inválidos, códigos duplicados, arquivo ausente, menu, navegação, confirmação/cancelamento do tempo, seleção de modos e tela pequena. Também verificam ciclos de perguntas sem repetição, alternativas únicas, uma correta, filtragem por continente, conjuntos insuficientes, bloqueio de respostas, encerramento, pontuação e percentuais. A partida tem testes para os dois modos com SVGs reais, acerto/erro, avanço, cancelamento de timers ao descartar, tempo esgotado, resposta no último segundo, tela pequena e fluxo do menu até o encerramento. Execute `flutter test test/game_screen_test.dart` para os testes específicos da partida.

Os testes de resultado conferem as contagens, percentual com arredondamento, ausência de respostas e tela pequena com fonte ampliada. Execute `flutter test test/result_screen_test.dart`. O fluxo de menu verifica também retorno, início de outra partida e saída sem timers pendentes.

## Catálogo e importação do acervo

O catálogo inclui 195 países no escopo documentado, usando somente imagens fornecidas no ZIP. O acervo original em lib/assets/ foi preservado. Símbolos de organizações, subdivisões e territórios presentes no acervo não são automaticamente incluídos como países.

Para ampliar o catálogo:

1. Copie uma bandeira existente para assets/flags/<code>.svg.
2. Adicione um registro ao JSON com code (ISO alpha-2 minúsculo), name em português, continent e flagAsset.
3. Use um dos cinco valores exatos: África, América, Ásia, Europa e Oceania.
4. Use o caminho assets/flags/<code>.svg e não repita códigos.
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
7. Mostre brevemente Country, QuizSession, StatefulWidget/setState, Navigator e os testes.

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

Para validar especificamente o acervo, execute `flutter test test/full_catalog_test.dart`: cobre os 271 arquivos, códigos únicos, exclusões explícitas, correspondências de países e continentes (incluindo casos transcontinentais), ciclos completos por continente e decodificação das 195 bandeiras pelo flutter_svg. A suíte completa mantém os testes dos dois modos e do fluxo do menu.

### Compatibilidade de SVG

Os originais us.svg e um.svg desenham estrelas com marker-mid, não suportado pelo flutter_svg. Os 271 originais permanecem idênticos ao ZIP. Duas cópias derivadas em assets/flags/compatible/ substituem os marcadores por 50 paths com as mesmas formas e posições. FlagImage seleciona essas cópias somente para renderização; o catálogo mantém os caminhos originais. Não foram baixadas nem inventadas bandeiras. O teste de decodificação usa os mesmos caminhos de exibição do aplicativo.
