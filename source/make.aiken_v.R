

local({
# --- PRE-FLIGHT CHECK ---
# Stop if the user is accidentally running this inside an existing plugin folder
if(basename(getwd()) == "rk.aiken.v") {
  stop("Your current working directory is already 'rk.aiken.v'. Please navigate to the parent directory ('..') before running this script to avoid creating a nested folder structure.")
}

# Require "rkwarddev"
require(rkwarddev)

# --- Plugin Metadata and Author Information ---
about_author <- person(
  given = "Alfonso",
  family = "Cano Robles",
  email = "alfonso.cano@correo.buap.mx",
  role = c("aut", "cre")
)

# CORRECTED: Package name uses a period instead of an underscore.
about_plugin_list <- list(
  name = "rk.aiken.v",
  author = about_author,
  about = list(
    desc = "An RKWard plugin to calculate Aiken's V coefficient for content validity.",
    version = "0.01-2",
    date = format(Sys.Date(), "%Y-%m-%d"),
    url = "http://example.com/rk.aiken.v",
    license = "GPL",
    dependencies = "R (>= 3.00)"
  )
)

about_node <- rk.XML.about(
  name = about_plugin_list$name,
  author = about_plugin_list$author,
  about = about_plugin_list$about
)


# --- Help File Definition ---
plugin_help <- list(
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

# --- Help File Generation ---
rkh_title <- rk.rkh.title(text = plugin_help$title)
rkh_summary <- rk.rkh.summary(text = plugin_help$summary)
rkh_usage <- rk.rkh.usage(text = plugin_help$usage)
rkh_sections <- lapply(plugin_help$sections, function(sec) {
  rk.rkh.section(title = sec$title, text = sec$text)
})
aiken_help_rkh <- rk.rkh.doc(
  title = rkh_title,
  summary = rkh_summary,
  usage = rkh_usage,
  sections = rkh_sections
)


# --- UI Element Definition ---
# Main Tab Content
data_selector <- rk.XML.varselector(label = "Select data object")
attr(data_selector, "classes") <- "data.frame"
data_slot <- rk.XML.varslot(label = "Data object (required)", source = data_selector, id.name = "var_data")
attr(data_slot, "required") <- "1"
selection_row <- rk.XML.row(data_selector, data_slot)
lo_spinbox <- rk.XML.spinbox(label = "Minimum value on scale (lo)", id.name = "num_lo", min = 0, initial = 1)
hi_spinbox <- rk.XML.spinbox(label = "Maximum value on scale (hi)", id.name = "num_hi", min = 1, initial = 5)
conf_level <- rk.XML.dropdown(
  label = "Confidence level (p)", id.name = "drp_p",
  options = list("90%" = list(val = "0.90"), "95%" = list(val = "0.95", chk = TRUE), "99%" = list(val = "0.99"))
)
save_results <- rk.XML.saveobj(
  label = "Save results to object", chk = TRUE, checkable = TRUE, initial = "aiken_results",
  required = FALSE, id.name = "sav_result"
)
main_tab_content <- rk.XML.col(selection_row, lo_spinbox, hi_spinbox, conf_level, save_results)

# Plotting Tab Content
plot_checkbox <- rk.XML.checkbox(label = "Create Aiken's V plot", value = "1", id.name = "chk_plot")
yintercept_spinbox <- rk.XML.spinbox(
    label = "Reference line (yintercept)",
    initial = 0.5,
    real = TRUE,
    precision = 2,
    id.name = "spin_yintercept"
)
plot_tab_content <- rk.XML.col(plot_checkbox, yintercept_spinbox)

# Assemble UI
tabs <- rk.XML.tabbook(tabs = list(
    "Main Options" = main_tab_content,
    "Plot" = plot_tab_content
))
preview_button <- rk.XML.preview(
  label = "Preview",
  mode = "plot",
  placement = "default",
  active = FALSE,
  id.name = "auto",
  i18n = NULL
)
aiken_dialog <- rk.XML.dialog(label = "Calculate Aiken's V", child = rk.XML.col(tabs, preview_button))


# --- JavaScript Logic ---
js_preprocess <- '
    echo("require(ggplot2)\\n");
    echo("require(tibble)\\n");
'

js_calculate <- '
    var data_frame = getValue("var_data");
    var lo = getValue("num_lo");
    var hi = getValue("num_hi");
    var p = getValue("drp_p");

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
    echo("aiken_results <- v_aiken(x = " + data_frame + ", lo = " + lo + ", hi = " + hi + ", p = " + p + ")\\n");
'

js_preview <- '
    preprocess();
    calculate();
    printout(true);
'

js_printout <- '
    if (!is_preview) {
        echo("rk.header(\\"Aiken\\\'s V Coefficient\\")\\n");
        echo("rk.header(\\"Aiken\\\'s V and Confidence Intervals per Item\\", level=3);\\n");
        echo("rk.print(aiken_results$v_ci);\\n");
        echo("rk.header(\\"Global Means\\", level=3);\\n");
        echo("rk.print(aiken_results$means_v);\\n");
        echo("rk.header(\\"Calculation Parameters\\", level=3);\\n");
        echo("rk.print(as.data.frame(aiken_results$parameters));\\n");
    }

    var create_plot = getValue("chk_plot");
    if(create_plot == "1" || create_plot == 1 || create_plot == "true" || create_plot === true){
        if (!is_preview) {
            echo("\\n");
            echo("rk.graph.on()\\n");
        }

        echo("try({\\n");
        echo("    p <- aiken_results[[\\"v_ci\\"]] %>\\%\\n");
        echo("        tibble::rownames_to_column(var = \\"Items\\") %>\\%\\n");
        echo("        ggplot2::ggplot(ggplot2::aes(x = reorder(Items, V, decreasing=FALSE), y = V, ymin = CI_L, ymax = CI_U)) +\\n");
        echo("        ggplot2::geom_col(fill = \\"lightblue\\") +\\n");
        echo("        ggplot2::geom_errorbar(width = 0.5) +\\n");
        echo("        ggplot2::ylim(0, 1) +\\n");
        echo("        ggplot2::geom_hline(yintercept = " + getValue("spin_yintercept") + ", linetype = \\"dashed\\", color = \\"red\\") +\\n");
        echo("        ggplot2::theme(plot.background = ggplot2::element_rect(fill=\\"transparent\\", color=NA)) +\\n");
        echo("        ggplot2::coord_flip() +\\n");
        echo("        ggplot2::ylab(\\"V\\") +\\n");
        echo("        ggplot2::xlab(\\"Item\\") +\\n");
        echo("        ggplot2::labs(title=\\"Bar Plot of Aiken\\\'s V per Item\\", subtitle=paste(\\"CI on error bars with p =\\", aiken_results$parameters$p))\\n");
        echo("    print(p)\\n");
        echo("})\\n");

        if (!is_preview) {
            echo("rk.graph.off()\\n");
        }
    }
'

# --- Plugin Skeleton Generation ---
rk.plugin.skeleton(
  about = about_node,
  pluginmap = list(name = "Aiken's V", hierarchy = list("analysis", "Aiken's V")),
  xml = list(dialog = aiken_dialog),
  js = list(
    preprocess = js_preprocess,
    calculate = js_calculate,
    preview = js_preview,
    printout = js_printout
    ),
  rkh = list(help = aiken_help_rkh),
  path = "rk.aiken.v", # CORRECTED: Path matches valid package name
  overwrite = TRUE,
  create = c("pmap", "xml", "js", "desc", "rkh"),
  load = TRUE,
  show = TRUE
)

# --- Final Instructions ---
message(
  'Plugin \'rk.aiken.v\' created successfully.\n\n',
  'NEXT STEPS:\n',
  '1. Open RKWard.\n',
  '2. In the R console, run:\n',
  '   rk.updatePluginMessages("rk.aiken.v")\n', # CORRECTED
  '3. Then, to install the plugin in your RKWard session, run:\n',
  '   rk.load.plugin("rk.aiken.v")\n', # CORRECTED
  '4. Or, for a permanent installation (requires devtools), run:\n',
  '   # Make sure your working directory is the parent of the \'rk.aiken.v\' folder\n',
  '   # devtools::install("rk.aiken.v")' # CORRECTED
)
})
