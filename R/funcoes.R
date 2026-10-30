# Leitura do cadastro das academias
ler_cadastro <- function(arquivo) {
  readr::read_delim(
    arquivo,
    delim = ";",
    locale = readr::locale(
      decimal_mark = ".",
      encoding = "ISO-8859-1"
    ),
    col_types = readr::cols(
      codigo = readr::col_character(),
      nome = readr::col_character(),
      plano = readr::col_character(),
      area_m2 = readr::col_double()
    ),
    show_col_types = FALSE
  )
}

# Leitura dos arquivos anuais de acessos
ler_acessos <- function(arquivo) {
  dados <- readr::read_delim(
    arquivo,
    delim = ";",
    na = "-",
    locale = readr::locale(
      decimal_mark = ".",
      encoding = "ASCII"
    ),
    col_types = readr::cols(
      codigo = readr::col_character(),
      .default = readr::col_double()
    ),
    show_col_types = FALSE
  )

  dados |>
    dplyr::mutate(
      ano = readr::parse_number(basename(arquivo))
    )
}

# Transformação e junção dos dados anuais com o cadastro
arrumar_dados <- function(anuais, cadastro) {
  meses <- c(
    "jan", "fev", "mar", "abr", "mai", "jun",
    "jul", "ago", "set", "out", "nov", "dez"
  )

  dplyr::bind_rows(anuais) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(meses),
      names_to = "mes",
      values_to = "acessos"
    ) |>
    dplyr::mutate(
      mes = factor(mes, levels = meses)
    ) |>
    dplyr::left_join(
      cadastro,
      by = "codigo",
      relationship = "many-to-one"
    ) |>
    dplyr::mutate(
      acessos_por_m2 = acessos / area_m2
    )
}

# Conferência dos dados por ano
conferir_dados <- function(dados, cadastro) {
  dados |>
    dplyr::group_by(ano) |>
    dplyr::summarise(
      linhas = dplyr::n(),
      unidades_com_medicao = dplyr::n_distinct(codigo),
      meses_sem_registro = sum(is.na(acessos)),
      soma_acessos = sum(
        tidyr::replace_na(acessos, 0)
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      unidades_no_cadastro = dplyr::n_distinct(cadastro$codigo)
    )
}

# Resumos por unidade, categoria e categoria/ano
resumir_dados <- function(dados) {
  resumo_unidade <- dados |>
    dplyr::group_by(ano, codigo, nome, plano) |>
    dplyr::summarise(
      meses_com_registro = sum(!is.na(acessos)),
      total_ano = sum(tidyr::replace_na(acessos, 0)),
      media_mensal_relativa = mean(
        tidyr::replace_na(acessos_por_m2, 0)
      ),
      .groups = "drop"
    ) |>
    dplyr::arrange(ano, dplyr::desc(media_mensal_relativa))

  resumo_categoria <- dados |>
    dplyr::group_by(plano) |>
    dplyr::summarise(
      unidades = dplyr::n_distinct(codigo),
      total_acessos = sum(tidyr::replace_na(acessos, 0)),
      media_mensal_relativa = mean(
        tidyr::replace_na(acessos_por_m2, 0)
      ),
      .groups = "drop"
    )

  resumo_categoria_ano <- dados |>
    dplyr::group_by(ano, plano) |>
    dplyr::summarise(
      unidades = dplyr::n_distinct(codigo),
      total_acessos = sum(tidyr::replace_na(acessos, 0)),
      media_mensal_relativa = mean(
        tidyr::replace_na(acessos_por_m2, 0)
      ),
      .groups = "drop"
    )

  list(
    unidade = resumo_unidade,
    categoria = resumo_categoria,
    categoria_ano = resumo_categoria_ano
  )
}

# Resumo mensal para análise da sazonalidade
resumir_sazonalidade <- function(dados) {
  dados |>
    dplyr::group_by(ano, mes) |>
    dplyr::summarise(
      media_mensal_relativa = mean(
        tidyr::replace_na(acessos_por_m2, 0)
      ),
      .groups = "drop"
    )
}

# Média anual e variação percentual entre os anos
resumir_variacao <- function(dados) {
  dados |>
    dplyr::group_by(ano) |>
    dplyr::summarise(
      media_anual = mean(
        tidyr::replace_na(acessos_por_m2, 0)
      ),
      .groups = "drop"
    ) |>
    dplyr::arrange(ano) |>
    dplyr::mutate(
      variacao_percentual = (
        media_anual / dplyr::first(media_anual) - 1
      ) * 100
    )
}

# Figura da sazonalidade mensal
criar_figura_sazonalidade <- function(dados, arquivo) {
  sazonalidade <- resumir_sazonalidade(dados)

  figura <- ggplot2::ggplot(
    sazonalidade,
    ggplot2::aes(
      x = mes,
      y = media_mensal_relativa,
      color = factor(ano),
      group = ano
    )
  ) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_point(size = 2) +
    ggplot2::labs(
      x = "Mês",
      y = "Média mensal de acessos por m²",
      color = "Ano",
      title = "Sazonalidade dos acessos às academias"
    ) +
    ggplot2::theme_minimal()

  dir.create(
    dirname(arquivo),
    recursive = TRUE,
    showWarnings = FALSE
  )

  ggplot2::ggsave(
    arquivo,
    figura,
    width = 9,
    height = 5,
    dpi = 300
  )

  arquivo
}

# Figura da distribuição por categoria
criar_figura_categorias <- function(dados, arquivo) {
  dados_figura <- dados |>
    dplyr::mutate(
      acessos_por_m2 = tidyr::replace_na(
        acessos_por_m2,
        0
      )
    )

  figura <- ggplot2::ggplot(
    dados_figura,
    ggplot2::aes(
      x = plano,
      y = acessos_por_m2,
      fill = plano
    )
  ) +
    ggplot2::geom_boxplot() +
    ggplot2::labs(
      x = "Categoria",
      y = "Acessos por m²",
      title = "Distribuição dos acessos por categoria",
      fill = "Categoria"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")

  dir.create(
    dirname(arquivo),
    recursive = TRUE,
    showWarnings = FALSE
  )

  ggplot2::ggsave(
    arquivo,
    figura,
    width = 7,
    height = 5,
    dpi = 300
  )

  arquivo
}
