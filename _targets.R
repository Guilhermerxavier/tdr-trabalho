library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "readr",
    "dplyr",
    "tidyr",
    "purrr",
    "ggplot2"
  )
)

tar_source("R")

list(
  tar_target(
    cadastro_arquivo,
    "dados/cadastro.csv",
    format = "file"
  ),

  tar_target(
    acessos_2023_arquivo,
    "dados/acessos_2023.csv",
    format = "file"
  ),

  tar_target(
    acessos_2024_arquivo,
    "dados/acessos_2024.csv",
    format = "file"
  ),

  tar_target(
    acessos_2025_arquivo,
    "dados/acessos_2025.csv",
    format = "file"
  ),

  tar_target(
    cadastro,
    ler_cadastro(cadastro_arquivo)
  ),

  tar_target(
    anuais,
    list(
      ler_acessos(acessos_2023_arquivo),
      ler_acessos(acessos_2024_arquivo),
      ler_acessos(acessos_2025_arquivo)
    )
  ),

  tar_target(
    dados,
    arrumar_dados(anuais, cadastro)
  ),

  tar_target(
    conferencia,
    conferir_dados(dados, cadastro)
  ),

  tar_target(
    resumos,
    resumir_dados(dados)
  ),

  tar_target(
    sazonalidade,
    resumir_sazonalidade(dados)
  ),

  tar_target(
    variacao,
    resumir_variacao(dados)
  ),

  tar_target(
    figura_sazonalidade,
    criar_figura_sazonalidade(
      dados,
      "figuras/sazonalidade.png"
    ),
    format = "file"
  ),

  tar_target(
    figura_categorias,
    criar_figura_categorias(
      dados,
      "figuras/categorias.png"
    ),
    format = "file"
  ),

  tarchetypes::tar_quarto(
    relatorio,
    "relatorio.qmd"
  )
)
