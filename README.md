🌍 Flag Game
Flag Game é um jogo de perguntas e respostas desenvolvido com Flutter e Dart para testar conhecimentos sobre bandeiras e países do mundo. O jogador pode escolher um continente ou jogar com países de diferentes regiões, responder às perguntas antes que o tempo acabe e acompanhar seu desempenho ao final da partida.

O projeto foi criado como parte de um desafio acadêmico de desenvolvimento de aplicativos, com foco em funcionalidade, interface responsiva, organização do código e criatividade.
🎮 Funcionalidades
- Jogar por continente: África, América, Ásia, Europa ou Oceania.
- Jogo aleatório: perguntas com países de diferentes continentes.
- Tempo de partida configurável: 30 segundos, 60 segundos, 3 minutos ou 5 minutos.
- Modo Bandeira → País: identificar o país a partir de sua bandeira, escolhendo entre quatro nomes.
- Modo País → Bandeira: identificar a bandeira correta a partir do nome do país, escolhendo entre quatro imagens.
- Feedback das respostas: indicação visual de acerto ou erro e avanço automático.
- Pontuação e cronômetro: acompanhamento durante a partida.
- Tela de resultados: total de perguntas respondidas, acertos e percentual de acertos.
- Bandeiras locais: imagens e dados carregados dos recursos do aplicativo, sem depender de conexão para consultar as bandeiras.
🏆 Ranking local
O projeto também prevê um ranking de partidas usando shared_preferences, com nome do jogador, pontuação e informações da partida. A proposta inclui acesso pelo menu lateral, consulta dos resultados e exclusão de registros.
Status: confirme se essa funcionalidade já foi integrada à versão publicada antes de descrevê-la como concluída.

🛠️ Tecnologias
Tecnologia	Utilização
Flutter	Construção da interface e navegação entre telas
Dart	Lógica do jogo e gerenciamento de dados
JSON	Organização do catálogo local de países e representação de registros
Assets locais	Armazenamento das imagens de bandeiras
shared_preferences	Persistência local de preferências e pontuações, quando habilitada


O projeto prioriza componentes nativos do Flutter, como Scaffold, Navigator, StatefulWidget e setState, evitando complexidade desnecessária.
📱 Interface
O aplicativo utiliza uma identidade visual colorida, com fundo roxo, botões arredondados e cartões de respostas. A interface é adaptada para diferentes tamanhos de tela, preservando a organização dos elementos nos dois modos de jogo.


🚀 Como executar
Pré-requisitos
- Flutter SDK instalado e configurado.
- Dart SDK (incluído no Flutter).
- Android Studio, VS Code ou outro editor compatível.
- Emulador Android ou dispositivo compatível configurado.
Instalação
1. Clone o repositório:
git clone URL_DO_SEU_REPOSITORIO
cd NOME_DA_PASTA_DO_PROJETO
Substitua os valores acima pelo endereço e nome reais do repositório.

2. Instale as dependências:
flutter pub get
3. Verifique os dispositivos disponíveis:
flutter devices
4. Execute o aplicativo:
flutter run
Para executar em um dispositivo específico:
flutter run -d ID_DO_DISPOSITIVO
A plataforma escolhida precisa estar habilitada e configurada no projeto Flutter.


🧠 Como jogar
1. Na tela inicial, escolha a duração da partida.
2. Selecione Jogar por Continente ou Jogo Aleatório.
3. Escolha o modo de perguntas disponível.
4. Responda às questões escolhendo uma das quatro alternativas.
5. Continue até o cronômetro chegar a zero.
6. Confira seu desempenho na tela de resultados.
7. Se o ranking estiver habilitado, informe seu nome para registrar a pontuação.
🧪 Verificações de qualidade
Para formatar e verificar o código:
dart format .
flutter analyze
flutter test
Os testes disponíveis dependem da implementação presente no repositório.
📋 Requisitos do desafio
O desafio acadêmico considera os seguintes critérios de avaliação:
Critério	Peso
Funcionalidade	50%
Interface	20%
Organização do código	15%
Criatividade	15%


Além do código-fonte publicado no GitHub, a entrega prevê documentação do projeto e um vídeo demonstrativo de seu funcionamento.
📚 Referências
- Documentação do Flutter
- Linguagem Dart
- Pacote shared_preferences
- REST Countries — referência possível para informações sobre países; o jogo utiliza um catálogo local de bandeiras.
📄 Licença
Nenhuma licença foi especificada neste documento. Caso o projeto seja disponibilizado com uma licença de código aberto, adicione o arquivo LICENSE e atualize esta seção.
Flag Game — Aprenda sobre países e bandeiras enquanto joga!