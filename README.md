# tdr-trabalho

**Trabalho intermediário – Da lista ao projeto reprodutível**

## Sobre o projeto

Este repositório apresenta uma análise exploratória dos dados de acessos a academias entre 2023 e 2025. O objetivo é organizar, transformar e analisar os dados, investigando padrões de utilização, diferenças entre categorias de academias e variações ao longo do período.

O projeto foi desenvolvido em R, utilizando o pacote `targets` para organizar o pipeline de análise, `Quarto` para produzir o relatório e `renv` para registrar as dependências do ambiente.

## Dados utilizados

Os dados estão armazenados no diretório `dados/` e incluem:

- `cadastro.csv`: informações cadastrais das academias;
- `acessos_2023.csv`: registros de acessos referentes a 2023;
- `acessos_2024.csv`: registros de acessos referentes a 2024;
- `acessos_2025.csv`: registros de acessos referentes a 2025;
- `LEIA-ME.txt`: orientações e informações sobre os arquivos.

Os arquivos originais foram preservados, sem alterações.

## Etapas da análise

O projeto contempla:

1. Leitura e organização dos dados cadastrais e dos registros anuais de acesso;
2. Integração das bases por meio do código de identificação das academias;
3. Cálculo de indicadores de acesso absoluto e de acessos por metro quadrado;
4. Comparação dos resultados por unidade, categoria e ano;
5. Investigação da sazonalidade mensal;
6. Análise da variação dos indicadores entre 2023 e 2025;
7. Produção de figuras e de um relatório em HTML.

## Estrutura do projeto

- `dados/`: arquivos originais utilizados na análise;
- `R/`: funções utilizadas no processamento e na análise;
- `figuras/`: gráficos produzidos pelo pipeline;
- `analise.qmd`: documento de análise da Lista 03;
- `relatorio.qmd`: documento Quarto que apresenta os resultados;
- `_targets.R`: definição das etapas do pipeline;
- `_dependencies.R`: declaração de dependências utilizadas pelo pipeline;
- `renv.lock`: registro das versões dos pacotes;
- `.github/workflows/`: configuração da integração contínua;
- `.lintr`: configuração das verificações de estilo do código R.

## Como reproduzir a análise

É necessário ter o R e o Quarto instalados.

Após clonar o repositório, abra o projeto no diretório principal e execute os seguintes comandos no R:

```r
renv::restore()
targets::tar_make()

## Uso de ferramentas de inteligência artificial

Foi utilizado o ChatGPT (OpenAI) como ferramenta de apoio durante o desenvolvimento do trabalho, principalmente para esclarecer instruções do enunciado, auxiliar na organização do código R e do pipeline `targets`, orientar a elaboração do relatório Quarto, auxiliar na configuração do `renv` e do GitHub Actions e revisar a documentação do projeto.

As sugestões fornecidas foram avaliadas e conferidas pelo autor por meio da execução dos códigos no ambiente local, da inspeção dos resultados gerados, da execução das verificações com `lintr` e da conferência das execuções automatizadas no GitHub Actions.
