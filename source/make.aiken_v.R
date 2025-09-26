local({
# --- PRE-FLIGHT CHECK ---
# Stop if the user is accidentally running this inside an existing plugin folder
if(basename(getwd()) == "rk.aiken.v") {
  stop("Your current working directory is already 'rk.aiken.v'. Please navigate to the parent directory ('..') before running this script to avoid creating a nested folder structure.")
}

# Require "rkwarddev" and set the minimum required version
require(rkwarddev)
rkwarddev.required("0.08-1")

# ---===================================---
# --- SHARED PLUGIN PACKAGE METADATA    ---
# ---===================================---
about_author <- person(
  given = "Alfonso",
  family = "Cano Robles",
  email = "alfonso.cano@correo.buap.mx",
  role = c("aut", "cre")
)

about_plugin_list <- list(
  name = "rk.aiken.v",
  author = about_author,
  about = list(
    desc = "An RKWard plugin to calculate Aiken's coefficients for content validity (V) and homogeneity (H).",
    version = "0.02.7", # Incremented version for output formatting
    date = format(Sys.Date(), "%Y-%m-%d"),
    url = "https://github.com/AlfCano/",
    license = "GPL (>= 3)",
    dependencies = "R (>= 3.00)"
  )
)

about_node <- rk.XML.about(
  name = about_plugin_list$name,
  author = about_plugin_list$author,
  about = about_plugin_list$about
)

# ---=================================================---
# --- COMPONENT 1: AIKEN'S V (The "Main" Plugin)      ---
# ---=================================================---

# --- Help File Definition (Aiken's V) ---
aiken_v_help_list <- list(
  title = "Aiken's V for Content Validity",
  summary = "This plugin calculates Aiken's V coefficient, which quantifies the content validity of a set of items evaluated by several judges.",
  usage = "Select the data.frame containing the ratings, specify the minimum and maximum values of the rating scale, and choose a confidence level. Optionally, create a bar chart of the results.",
  sections = list(
    list(
      title = "Main Settings",
      text = "<p><b>Data Object:</b> The data.frame containing the data. Each row should represent an item and each column a judge's rating.</p>
               <p><b>Minimum value on scale (lo):</b> The lowest possible numeric value on the rating scale (e.g., 0 or 1).</p>
               <p><b>Maximum value on scale (hi):</b> The highest possible numeric value on the rating scale (e.g., 5).</p>
               <p><b>Confidence level (p):</b> The proportion for the confidence interval calculation (e.g., 0.95 for 95% confidence).</p>"
    ),
    list(
        title = "Plot Tab",
        text = "<p>This tab provides options for visualizing the results.</p>
                <p><b>Create Aiken's V plot:</b> If checked, a bar chart will be generated showing the V value for each item, with its confidence intervals as error bars.</p>
                <p><b>Reference line:</b> Allows setting the value for a dashed horizontal line on the plot, useful as a cutoff point for validity.</p>"
    ),
    list(
      title = "Output",
      text = "<p>The plugin returns a list containing:</p>
              <ul>
                <li><b>v_ci:</b> A data.frame with the Aiken's V value and the lower (CI_L) and upper (CI_U) confidence interval limits for each item.</li>
                <li><b>means_v:</b> The overall means of V, CI_L, and CI_U.</li>
                <li><b>parameters:</b> A list with the parameters used in the calculation (n, k, p, z, etc.).</li>
              </ul>"
    )
  )
)

# --- Help File Generation (Aiken's V) ---
v_rkh_title <- rk.rkh.title(text = aiken_v_help_list$title)
v_rkh_summary <- rk.rkh.summary(text = aiken_v_help_list$summary)
v_rkh_usage <- rk.rkh.usage(text = aiken_v_help_list$usage)
v_rkh_sections <- lapply(aiken_v_help_list$sections, function(sec) {
  rk.rkh.section(title = sec$title, text = sec$text)
})
aiken_v_help_rkh <- rk.rkh.doc(
  title = v_rkh_title,
  summary = v_rkh_summary,
  usage = v_rkh_usage,
  sections = v_rkh_sections
)

# --- UI Definition (Aiken's V) ---
v_data_selector <- rk.XML.varselector(label = "Select data object")
attr(v_data_selector, "classes") <- "data.frame"
v_data_slot <- rk.XML.varslot(label = "Data object (required)", source = v_data_selector, id.name = "var_data_v")
attr(v_data_slot, "required") <- "1"
v_lo_spinbox <- rk.XML.spinbox(label = "Minimum value on scale (lo)", id.name = "num_lo_v", min = 0, initial = 1)
v_hi_spinbox <- rk.XML.spinbox(label = "Maximum value on scale (hi)", id.name = "num_hi_v", min = 1, initial = 5)
v_conf_level <- rk.XML.spinbox(
  label = "Confidence level (p)",
  id.name = "drp_p_v",
  real = TRUE,
  min = 0.001,
  max = 0.999,
  initial = 0.95,
  precision = 3
)
v_save_results <- rk.XML.saveobj(
  label = "Save results to object", chk = TRUE, checkable = TRUE, initial = "aiken_v_results",
  required = FALSE, id.name = "sav_result_v"
)

v_options_col <- rk.XML.col(v_data_slot, v_lo_spinbox, v_hi_spinbox, v_conf_level, v_save_results)
v_main_tab_content <- rk.XML.row(v_data_selector, v_options_col)

v_plot_checkbox <- rk.XML.cbox(label = "Create Aiken's V plot", value = "1", id.name = "chk_plot_v")
v_yintercept_spinbox <- rk.XML.spinbox(
    label = "Reference line (yintercept)",
    initial = 0.5,
    real = TRUE,
    precision = 2,
    id.name = "spin_yintercept_v"
)
v_plot_tab_content <- rk.XML.col(v_plot_checkbox, v_yintercept_spinbox)

v_tabs <- rk.XML.tabbook(tabs = list(
    "Main Options" = v_main_tab_content,
    "Plot" = v_plot_tab_content
))
v_preview_button <- rk.XML.preview(label = "Preview")
aiken_v_dialog <- rk.XML.dialog(label = "Calculate Aiken's V", child = rk.XML.col(v_tabs, v_preview_button))

# --- JavaScript Logic (Aiken's V) ---
aiken_v_js_logic <- list(
    results.header = "Aiken's V for Content Validity",
    preprocess = '
    echo("require(ggplot2)\\n");
    echo("require(tibble)\\n");
',
    calculate = '
    var data_frame = getValue("var_data_v");
    var lo = getValue("num_lo_v");
    var hi = getValue("num_hi_v");
    var p = getValue("drp_p_v");

    echo("v_aiken <- function(x, lo, hi, p) {\\n");
    echo("    n <- ncol(x)\\n");
    echo("    i <- nrow(x)\\n");
    echo("    k <- (hi - lo)\\n");
    echo("    z <- qnorm((1 - (p)) / 2, mean = 0, sd = 1, lower.tail = FALSE)\\n");
    echo("    S <- rowSums(x - lo)\\n");
    echo("    V <- S / (n * k)\\n");
    echo("    A <- (2 * n * k * V) + (z^2)\\n");
    echo("    B <- (z * (sqrt(4 * n * k * V * (1 - V) + (z^2))))\\n");
    echo("    C <- (2 * ((n * k) + (z^2)))\\n");
    echo("    L <- (A - B) / C\\n");
    echo("    U <- (A + B) / C\\n");
    echo("    df <- data.frame(cbind(\\"V\\" = V, \\"CI_L\\" = L, \\"CI_U\\" = U))\\n");
    echo("    rownames(df) <- paste0(\\"Item_\\", 1:i)\\n");
    echo("    means_list <- list()\\n");
    echo("    for (col_name in names(df)) {\\n");
    echo("      mean_value <- mean(df[[col_name]])\\n");
    echo("      means_list[[col_name]] <- mean_value\\n");
    echo("    }\\n");
    echo("    means_df <- data.frame(Medias = unlist(means_list))\\n");
    echo("    v_list <- list()\\n");
    echo("    v_list[[\\"v_ci\\"]] <- df\\n");
    echo("    v_list[[\\"means_v\\"]] <- means_df\\n");
    echo("    parameters <- list()\\n");
    echo("    noms_par <- c(\\"n\\", \\"k\\", \\"p\\", \\"z\\", \\"lo\\", \\"hi\\", \\"i\\")\\n");
    echo("    for (e in 1:length(noms_par)) {\\n");
    echo("      nombre_actual <- noms_par[e]\\n");
    echo("      parameters[[nombre_actual]] <- get(nombre_actual)\\n");
    echo("    }\\n");
    echo("    v_list[[\\"parameters\\"]] <- parameters\\n");
    echo("    return(v_list)\\n");
    echo("  }\\n");
    echo("\\n");
    echo("aiken_v_results <- v_aiken(x = " + data_frame + ", lo = " + lo + ", hi = " + hi + ", p = " + p + ")\\n");
',
    printout = '
    if (!is_preview) {
        echo("rk.header(\\"Aiken\\\'s V and Confidence Intervals per Item\\", level=3);\\n");
        echo("rk.print(aiken_v_results$v_ci);\\n");
        echo("rk.header(\\"Global Means\\", level=3);\\n");
        echo("rk.print(aiken_v_results$means_v);\\n");
        echo("rk.header(\\"Calculation Parameters\\", level=3);\\n");
        echo("rk.print(as.data.frame(aiken_v_results$parameters));\\n");
    }

    var create_plot = getValue("chk_plot_v");
    if(create_plot == "1"){
        echo("rk.graph.on()\\n");
        echo("try({\\n");
        echo("    p <- aiken_v_results[[\\"v_ci\\"]] %>\\%\\n");
        echo("        tibble::rownames_to_column(var = \\"Items\\") %>\\%\\n");
        echo("        ggplot2::ggplot(ggplot2::aes(x = reorder(Items, V, decreasing=FALSE), y = V, ymin = CI_L, ymax = CI_U)) +\\n");
        echo("        ggplot2::geom_col(fill = \\"lightblue\\") +\\n");
        echo("        ggplot2::geom_errorbar(width = 0.5) +\\n");
        echo("        ggplot2::ylim(0, 1) +\\n");
        echo("        ggplot2::geom_hline(yintercept = " + getValue("spin_yintercept_v") + ", linetype = \\"dashed\\", color = \\"red\\") +\\n");
        echo("        ggplot2::theme_bw() +\\n");
        echo("        ggplot2::coord_flip() +\\n");
        echo("        ggplot2::ylab(\\"V\\") +\\n");
        echo("        ggplot2::xlab(\\"Item\\") +\\n");
        echo("        ggplot2::labs(title=\\"Bar Plot of Aiken\\\'s V per Item\\", subtitle=paste(\\"CI on error bars with p =\\", aiken_v_results$parameters$p))\\n");
        echo("    print(p)\\n");
        echo("})\\n");
        echo("rk.graph.off()\\n");
    }
'
)

# ---=======================================================---
# --- COMPONENT 2: AIKEN'S H (The "Additional" Plugin)      ---
# ---=======================================================---

# --- Help File Definition (Aiken's H) ---
aiken_h_help_list <- list(
  title = "Aiken's H for Homogeneity",
  summary = "This plugin calculates Aiken's H coefficient, an internal consistency measure for rating data. It can assess agreement among raters for each item, or the consistency of a single rater across all items.",
  usage = "Select the data.frame containing the ratings, then specify the minimum and maximum values of the rating scale to determine the number of categories. Finally, select a significance level for the large-sample test.",
  sections = list(
    list(
      title = "Data Structure",
      text = "<p>The plugin expects a data.frame where <b>rows are items</b> and <b>columns are raters</b>.</p>"
    ),
    list(
      title = "Main Settings",
      text = "<p><b>Data Object:</b> The data.frame containing the ratings.</p>
              <p><b>Minimum value on scale (lo):</b> The lowest possible numeric value on the rating scale (e.g., 1).</p>
              <p><b>Maximum value on scale (hi):</b> The highest possible numeric value on the rating scale (e.g., 4). These values are used to calculate 'c', the number of rating categories.</p>
              <p><b>Significance level (p):</b> The alpha level for the large-sample significance test of the mean H (e.g., 0.05).</p>"
    ),
    list(
      title = "Output",
      text = "<p>The plugin returns a list containing three main components:</p>
              <ul>
                <li><b>H_across_Raters:</b> A data.frame showing the homogeneity (agreement) among all raters for each individual item.</li>
                <li><b>H_across_Items:</b> A data.frame showing the homogeneity (consistency) of each individual rater across all items.</li>
                <li><b>Significance_of_Mean_H:</b> The results of a large-sample z-test to determine if the overall mean homogeneity of raters is statistically significant.</li>
              </ul>"
    )
  )
)

# --- Help File Generation (Aiken's H) ---
h_rkh_title <- rk.rkh.title(text = aiken_h_help_list$title)
h_rkh_summary <- rk.rkh.summary(text = aiken_h_help_list$summary)
h_rkh_usage <- rk.rkh.usage(text = aiken_h_help_list$usage)
h_rkh_sections <- lapply(aiken_h_help_list$sections, function(sec) {
  rk.rkh.section(title = sec$title, text = sec$text)
})
aiken_h_help_rkh <- rk.rkh.doc(
  title = h_rkh_title,
  summary = h_rkh_summary,
  usage = h_rkh_usage,
  sections = h_rkh_sections
)

# --- UI Definition (Aiken's H) ---
h_data_selector <- rk.XML.varselector(label = "Select data object")
attr(h_data_selector, "classes") <- "data.frame"
h_data_slot <- rk.XML.varslot(label = "Data object (required)", source = h_data_selector, id.name = "var_data_h")
attr(h_data_slot, "required") <- "1"
h_lo_spinbox <- rk.XML.spinbox(label = "Minimum value on scale (lo)", id.name = "num_lo_h", min = 0, initial = 1)
h_hi_spinbox <- rk.XML.spinbox(label = "Maximum value on scale (hi)", id.name = "num_hi_h", min = 1, initial = 4)
h_sig_level <- rk.XML.spinbox(
  label = "Significance level (p)",
  id.name = "drp_p_h",
  real = TRUE,
  min = 0.001,
  max = 0.999,
  initial = 0.05,
  precision = 3
)
h_save_results <- rk.XML.saveobj(
  label = "Save results to object", chk = TRUE, checkable = TRUE, initial = "aiken_h_results",
  required = FALSE, id.name = "sav_result_h"
)

h_options_col <- rk.XML.col(h_data_slot, h_lo_spinbox, h_hi_spinbox, h_sig_level, h_save_results)
aiken_h_dialog <- rk.XML.dialog(label = "Calculate Aiken's H", child = rk.XML.row(h_data_selector, h_options_col))

# --- JavaScript Logic (Aiken's H) ---
aiken_h_js_logic <- list(
    results.header = "Aiken's H for Homogeneity",
    calculate = '
    var data_frame = getValue("var_data_h");
    var lo = getValue("num_lo_h");
    var hi = getValue("num_hi_h");
    var p = getValue("drp_p_h");

    echo("calculate_s <- function(ratings) {\\n");
    echo("  ratings <- as.numeric(ratings)\\n");
    echo("  ratings <- ratings[!is.na(ratings)]\\n");
    echo("  if (length(ratings) < 2) { return(0) }\\n");
    echo("  pairs <- combn(ratings, 2)\\n");
    echo("  s_value <- sum(abs(pairs[1, ] - pairs[2, ]))\\n");
    echo("  return(s_value)\\n");
    echo("}\\n\\n");

    echo("aiken_h <- function(df, lo, hi, p) {\\n");
    echo("  c <- (hi - lo) + 1\\n");
    echo("  n <- ncol(df)\\n");
    echo("  m <- nrow(df)\\n");
    echo("  jm <- ifelse(m %% 2 == 0, 0, 1)\\n");
    echo("  jn <- ifelse(n %% 2 == 0, 0, 1)\\n");
    echo("  s_n_values <- apply(df, 1, calculate_s)\\n");
    echo("  denominator_n <- (c - 1) * (n^2 - jn)\\n");
    echo("  h_n_values <- 1 - (4 * s_n_values) / denominator_n\\n");
    echo("  results_n <- data.frame(Item = rownames(df), S_n = s_n_values, H_n = h_n_values)\\n");
    echo("  s_m_values <- apply(df, 2, calculate_s)\\n");
    echo("  denominator_m <- (c - 1) * (m^2 - jm)\\n");
    echo("  h_m_values <- 1 - (4 * s_m_values) / denominator_m\\n");
    echo("  results_m <- data.frame(Rater = colnames(df), S_m = s_m_values, H_m = h_m_values)\\n");
    echo("  H_bar <- mean(results_m$H_m, na.rm = TRUE)\\n");
    echo("  mu_h <- (2 * (c + 1) + (m + jm) * (c - 2)) / (3 * c * (m + jm))\\n");
    echo("  sigma_numerator_part1 <- 2 * (c + 1) * (m + jm - 1)\\n");
    echo("  sigma_numerator_part2 <- c^2 * (m + 3) - 2 * (2*m - 9)\\n");
    echo("  sigma_numerator <- sqrt(sigma_numerator_part1 * sigma_numerator_part2)\\n");
    echo("  sigma_denominator <- (c - 1) * (m + jm) * (m^2 - jm)\\n");
    echo("  sigma_h <- if (sigma_denominator == 0) { NA } else { (2 / (3*c)) * (sigma_numerator / sigma_denominator) }\\n");
    echo("  z_score <- if (is.na(sigma_h) || sigma_h == 0) { NA } else { sqrt(n) * (H_bar - mu_h) / sigma_h }\\n");
    echo("  p_value <- pnorm(z_score, lower.tail = FALSE)\\n");
    echo("  is_significant <- p_value < p\\n");
    echo("  significance_test <- list(description = \\"Large-sample test for the mean of H across items (H_m)\\", mean_H = H_bar, population_mean_mu = mu_h, population_sd_sigma = sigma_h, z_score = z_score, p_value = p_value, alpha = p, is_significant = is_significant)\\n");
    echo("  final_list <- list(H_across_Raters = results_n, H_across_Items = results_m, Significance_of_Mean_H = significance_test)\\n");
    echo("  return(final_list)\\n");
    echo("}\\n\\n");

    echo("aiken_h_results <- aiken_h(df = " + data_frame + ", lo = " + lo + ", hi = " + hi + ", p = " + p + ")\\n");
',
    printout = '
    echo("rk.header(\\"Homogeneity across Raters (Hn)\\", level=3);\\n");
    echo("rk.print(paste(\\"Measures agreement among raters for each item.\\"))\\n");
    echo("rk.results(aiken_h_results$H_across_Raters, print.rownames=FALSE);\\n\\n");
    echo("rk.header(\\"Homogeneity across Items (Hm)\\", level=3);\\n");
    echo("rk.print(paste(\\"Measures consistency of each rater across all items.\\"))\\n");
    echo("rk.results(aiken_h_results$H_across_Items, print.rownames=FALSE);\\n\\n");
    echo("rk.header(\\"Significance Test for Mean Homogeneity\\\", level=3);\\n");
    // CORRECTED: Coerce the list to a data.frame for clean, tabular output.
    echo("rk.results(as.data.frame(aiken_h_results$Significance_of_Mean_H), print.rownames=FALSE);\\n");
'
)

# --- Component Definition (Aiken's H) ---
aiken_h_component <- rk.plugin.component(
  "Aiken's H (Homogeneity)",
  xml = list(dialog = aiken_h_dialog),
  js = aiken_h_js_logic,
  rkh = list(help = aiken_h_help_rkh),
  hierarchy = list("analysis", "Aiken's Coefficients")
)

# ---===================================---
# --- PLUGIN SKELETON GENERATION        ---
# ---===================================---

rk.plugin.skeleton(
  # Shared metadata
  about = about_node,
  path = about_plugin_list$name,

  # Main plugin (Aiken's V) definition
  pluginmap = list(
    name = "Aiken's V (Content Validity)",
    hierarchy = list("analysis", "Aiken's Coefficients")
  ),
  xml = list(dialog = aiken_v_dialog),
  js = aiken_v_js_logic,
  rkh = list(help = aiken_v_help_rkh),

  # List of additional plugin components
  components = list(aiken_h_component),

  # Standard generation options
  create = c("pmap", "xml", "js", "desc", "rkh"),
  overwrite = TRUE,
  load = TRUE,
  show = TRUE
)

# --- Final Instructions ---
message(
  'Plugin package \'', about_plugin_list$name, '\' created successfully.\n\n',
  'NEXT STEPS:\n',
  '1. Open RKWard.\n',
  '2. In the R console, run:\n',
  '   rk.updatePluginMessages("', about_plugin_list$name, '")\n',
  '3. Then, to install the plugins in your RKWard session, run:\n',
  '   rk.load.plugin("', about_plugin_list$name, '")\n',
  '4. Or, for a permanent installation (requires devtools), run:\n',
  '   # Make sure your working directory is the PARENT of the \'', about_plugin_list$name, '\' folder\n',
  '   # devtools::install("', about_plugin_list$name, '")'
)

})
