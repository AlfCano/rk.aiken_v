---
title: "Revised RKWard Plugin Creation Prompt"
output: html_document
---

This prompt is designed to be the definitive guide, incorporating all the hard-won lessons and specific legacy syntax requirements uncovered. It states a set of precise, inflexible instructions that, if followed, would allow an expert assistant to generate the final, correct, multi-tabbed plugin with a plot preview on the very first attempt.

# INITIAL PROMPT

You are an expert assistant for creating RKWard plugins using the R package `rkwarddev`, specifically targeting compatibility with older versions like `0.08-1`. Your primary task is to generate a complete, self-contained R script (e.g., `make_plugin.R`) that, when executed with `source()`, programmatically builds the entire file structure of a functional RKWard plugin.

To succeed, you must adhere to the following set of inflexible **Golden Rules**. These rules are derived from a rigorous debugging process and are designed to prevent all recurring errors. **Do not deviate from these rules under any circumstances.**

## Golden Rules (Immutable Instructions)

### 1. The R Script is the Single Source of Truth
Your sole output will be a single R script that defines all plugin components as R objects and uses `rk.plugin.skeleton()` to write the final files. This script **must** be wrapped in `local({})` to avoid polluting the global environment.

### 2. The Sacred Structure of the Help File (`.rkh`)
This is a critical and error-prone section.

*   The user will provide help text in a simple R list. Your script **must** translate this into `rkwarddev` objects.
*   **The Translation Pattern is Fixed:** `plugin_help$summary` becomes `rk.rkh.summary()`, `plugin_help$usage` becomes `rk.rkh.usage()`, each item in `plugin_help$sections` becomes `rk.rkh.section()`, etc.
*   These generated objects **must** be assembled into a **single document object** using `rk.rkh.doc()`.
*   This final `rk.rkh.doc` object **must** be passed to `rk.plugin.skeleton` inside a named list: `rkh = list(help = ...)`.

### 3. The Inflexible Two-Part UI for Variable Selection
To select an R object (like a data frame) in a legacy-compatible way, you **must** create a two-part UI component. Using a single `varslot` or `varselector` will fail.

*   **Part 1: The Source List (`rk.XML.varselector`):** Create an `rk.XML.varselector` object. This component provides the list of available R objects for the user to see and choose from.
*   **Part 2: The Destination Box (`rk.XML.varslot`):** Create an `rk.XML.varslot` object. This component displays the user's final selection.
*   **The Link:** The `source` argument of the `rk.XML.varslot` **must** be the `rk.XML.varselector` object itself. The `id.name` of the `varslot` is what you will use in `getValue()` to get the selected object's name.
*   These two components are typically placed together in an `rk.XML.row()`.

### 4. The `calculate`/`printout` Pattern and the `saveobj` Specification
To generate clean R code, you will follow this pattern:

*   **The `calculate` Block:** This block's only responsibility is to generate the R code that performs the computation and saves the final output to an R object. The name of this object **must** exactly match the `initial` argument of your `rk.XML.saveobj` component.
*   **The `printout` Block:** This block generates the R code that creates the visible output in the RKWard console (e.g., using `rk.header()` and `rk.print()`). It must refer to the same R object name defined in the `calculate` block.
*   **The `rk.XML.saveobj` Component:** This component handles saving the object. Its `initial` argument **must** be a string containing the exact name of the R object created in the `calculate` block (e.g., `initial = "aiken_results"`). You will use the direct argument syntax `rk.XML.saveobj(..., initial = "...")` and **not** the `attr()` method for this specific component.

### 5. Strict Adherence to Legacy `rkwarddev` Syntax
The target version `0.08-1` has specific function signatures that must be followed.

*   **`attr()` is Mandatory for Optional Arguments (Generally):** For functions like `rk.XML.varslot` and `rk.XML.varselector`, only basic arguments are passed directly. Attributes like `required` and `classes` **must** be added after object creation using `attr()`.
*   **Specific Function Signatures (Exceptions):**
    *   **About Node:** The plugin's metadata **must** be created with `rk.XML.about(name = ..., author = ..., about = list(...))`. Passing individual metadata arguments like `description` or `version` directly will fail.
    *   **Tabbed Dialogs:** To create tabs, you **must** use a single `rk.XML.tabbook(tabs = list("Tab 1 Title" = tab1_content, "Tab 2 Title" = tab2_content))`. The function `rk.XML.tab` does not exist.
    *   **Author Definition:** Author information **must** be defined using `person()`.
    *   **`rk.plugin.skeleton` Arguments:** Do not use arguments that do not exist in the legacy version, such as `guess.dependencies`.

### 6. Robust JavaScript and R Code Generation
The JavaScript code you define in R strings has one purpose: to generate and `echo` valid R code.

*   **The `echo()` Command is King:** Every line of R code that you want to execute, including `rk.header()`, `rk.print()`, `require()`, and `rk.graph.on()`, **must** be wrapped in an `echo("...");` statement within the JavaScript string. A direct call like `rk.header(...)` in the JavaScript will fail.
*   **Abandon the `consts` Block:** The `js = list(consts=...)` feature is unreliable in this version. Any necessary R helper functions **must** be defined as a multi-line string variable directly inside the `js_calculate` string and then printed using `echo()`.
*   **The Preview Pattern: `preprocess` / `calculate` / `printout(is_preview)`:** To enable the plot preview feature, your JavaScript logic must be structured across three functions:
    *   `preprocess`: Generates `require()` calls for packages needed for plotting.
    *   `calculate`: Generates the R code to create the data object.
    *   `printout`: This function must accept a boolean argument, `is_preview`. It contains `if (!is_preview)` blocks for text output and `rk.graph.on()/off()` calls. The core plotting code is located outside these blocks so it runs in both preview and full-submission mode.
    *   The `preview` block itself simply calls `preprocess(); calculate(); printout(true);`.
*   **Robust Checkbox Handling:** Always check for multiple possible `TRUE` values from a checkbox: `if(my_var == "1" || my_var == 1 || my_var == true)`.

---

### Your Task

Your task is to create a plugin in the "Análisis" menu of RKWard which is able to use the `v_aiken` function. The plugin must include a main tab for settings and a second, optional tab for creating a `ggplot2` visualization of the results, complete with a plot preview button.

#### Function in R

```{r}
v_aiken <- function(
x,  # Es un data frame donde cada fila es un ítem y cada columna contiene las calificaciones que cada evaluador asignó.
lo,   # Es el valor mínimo (lowest) posible en la escala.
hi,   # Es el valor máximo (highest) posible en la escala.
p) {  # Es la proporción del nivel de confianza.
    n <- ncol (x)           # Devuelve el número de columnas, es decir, el número de evaluadores.
    i <- nrow (x)           # Devuelve el número de filas y representa el número de ítems.
    k <-  (hi - lo)             # Es la distancia desde "lo" hasta "hi". Es el rango de posibles elecciones discretas.
    z <- qnorm((1-(p))/2, mean = 0, sd = 1, lower.tail = FALSE)  # Encuentra el valor z (en unidades de desviación estándar) que corresponde a una probabilidad acumulada dada.
    S <- rowSums (x - lo) # "S" resta elemento por elemento el valor de lo y suma los valores resultantes en cada fila.
    V <- S/(n * k)      # "Es el valor de la V de Aiken calculado por la fórmula.
# Cálculo del IC por medio de la simplificación de la derivación de las ecuaciones para el límite inferior y superior
    A <- (2*n*k*V)+(z^2)                    # Cálculo de A
    B <- (z*(sqrt(4*n*k*V*(1-V)+(z^2))))    # Cálculo de B
    C <- (2*((n*k)+(z^2)))                  # Cálculo de C
    # Cálculo del límite del intervalo de confianza inferior (Lower)
    L <- (A-B)/C
    # Cálculo del límite del intervalo de confianza superior (Upper).
    U <- (A+B)/C
# Crear el data frame "df".
df    <- data.frame(
                cbind(
                    "V" =  V,
                    "CI_L" = L,
                    "CI_U" = U
          )
      )
# Crear la tabla con nombres con  "Ítem_#".
rownames(df) <- paste0("Ítem_", 1:i) # Crea el nombre de la fila correspondiente al número de cada "Ítem" como se encuentra en el marco de datos x.
means_list <- list() # Crea la lista llamada "means_list".
for (col_name in names(df)) {
  # Aplicar la función mean a la columna actual.
  mean_value <- mean(df[[col_name]])
  # Almacenar el resultado en la lista con el nombre de la columna.
  means_list[[col_name]] <- mean_value
}
# Crear un data frame llamado "Medias" a partir de la lista "means_list".
means_df <- data.frame(Medias = unlist(means_list))
v_list  <- list()
v_list[["v_ci"]]    <- df
v_list[["means_v"]] <- means_df
# Crea una lista vacía llamada "parameters"
parameters   <-  list()
# Definir los nombres de los objetos a copiar.
noms_par <- c("n","k","p","z","lo","hi","i")
# Loop para copiar los objetos a la lista "parameters".
for (e in 1:length(noms_par)) {
  nombre_actual <- noms_par[e]
  parameters[[nombre_actual]] <- get(nombre_actual)
}
v_list[["parameters"]] <- parameters
return(v_list)
  }
```

Plotting code:
```{r}
# Preparar
require ("ggplot2")
require ("tibble")
# Calcular
p <- aiken_results[["v_ci"]] %>%
rownames_to_column(var = "Items")%>%
ggplot(aes( x = reorder(Items, V, decreasing=FALSE),
            y = V,
            ymin = CI_L,
            ymax = CI_U)) +
  geom_col(fill = "lightblue") +
  geom_errorbar(width = 0.5) +
  ylim(0, 1) +
  geom_hline(
    yintercept = 0.5,
    linetype = "dashed",
    color = "red") +
                theme(
                plot.background = element_rect(fill='transparent', color=NA))+
                coord_flip()  +
                ylab("V")+
                xlab("Ítem") +
                labs(title="Gráfico de V de Aiken por Ítem",
                subtitle="CI en barras de error con p = .95")
# Imprimir
print(p)
```
