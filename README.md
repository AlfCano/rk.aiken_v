# RKWard Plugin: Aiken's V for Content Validity (`rk.aiken.v`)

> An RKWard plugin to calculate Aiken's V and H coefficients.

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This repository contains the source code for `rk.aiken.v`, an RKWard plugin package designed to calculate and interpret two key coefficients proposed by L.R. Aiken for analyzing rating data.

This package provides a user-friendly graphical interface within RKWard for two distinct but related analyses:

1.  **Aiken's V for Content Validity**
2.  **Aiken's H for Homogeneity**

## Features

### 1. Aiken's V (Content Validity)

This plugin calculates Aiken's V, a widely used coefficient to quantify the content validity of a set of items as evaluated by a panel of judges or raters.

-   **Inputs:** Requires a data frame where rows represent items and columns represent raters.
-   **Calculations:** Computes the V coefficient and its confidence intervals for each item.
-   **Visualization:** Includes an optional feature to generate a bar plot of the V values with error bars representing the confidence intervals, allowing for easy visual assessment against a reference line.
-   **Output:** Returns a comprehensive list containing the V values with confidence intervals, global means, and all parameters used in the calculation.

### 2. Aiken's H (Homogeneity)

This plugin, added in version `0.02-0`, calculates Aiken's H, an internal consistency or homogeneity coefficient for rating data based on the formulas from Aiken (1985).

-   **Inputs:** Requires a data frame with items in rows and raters in columns.
-   **Dual Analysis:** The plugin computes two forms of the H coefficient:
    -   **H across Raters (`H_n`):** Measures the agreement (homogeneity) among all raters for each individual item.
    -   **H across Items (`H_m`):** Measures the consistency (homogeneity) of each individual rater's scores across all items.
-   **Significance Testing:** Includes a large-sample z-test to determine if the overall mean homogeneity of the raters (`mean H_m`) is statistically significant.
-   **Output:** Returns a list containing neatly formatted tables for the `H_across_Raters` results, the `H_across_Items` results, and a summary of the significance test.

## Installation

### With `devtools` (Recommended)

1. You can install this plugin directly from the repository using the `devtools` package in R.

```
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.aiken_v"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})
```
2.  Restart RKWard. The plugin will be available in the `Analysis` menu.

### Manual Installation
1.  Download this repository as a `.zip` file.
2.  In RKWard, go to **Settings -> R Packages -> Install package(s) from local zip file(s)** and select the downloaded file.
3.  Restart RKWard. The plugin will be available in the `Analysis` menu.
    

## Usage

After installation, the plugins will be available in the RKWard menu under:

**Analysis -> Aiken's Coefficients**

-   **Aiken's V (Content Validity):** Select this option to calculate the V coefficient. The dialog will prompt you for a data frame, the minimum and maximum values of your rating scale, and a confidence level.
-   **Aiken's H (Homogeneity):** Select this option to calculate the H coefficient. The dialog will prompt for a data frame, the scale's minimum and maximum values (to determine the number of categories), and a significance level (alpha) for the z-test.

## Technical Basis

The formulas and methodologies implemented in this package are based on the following publication:

> Aiken, L. R. (1985). Three coefficients for analyzing the reliability and validity of ratings. *Educational and Psychological Measurement, 45*(1), 131-142.

## Usage

1.  Once installed, navigate to the **Analysis -> Aiken's V** menu in RKWard.
2.  In the **Main Options** tab, select the input data frame. The data should be structured with items as rows and judges/raters as columns.
3.  Specify the lowest (`lo`) and highest (`hi`) possible values on your rating scale.
4.  Choose the desired confidence level (`p`).
5.  Optionally, specify an object name to save the results list into.
6.  Navigate to the **Plot** tab.
7.  Check the "Create plot of Aiken's V" box to enable plotting.
8.  Adjust the "Line of reference" to set a cutoff value for your analysis. You can see the effect of this change in real-time by clicking the **Preview** button.
9.  Click **Submit** to run the full analysis.

## Output

The plugin will generate:
1.  A summary table of the overall mean V and confidence interval limits.
2.  A detailed table showing the V, lower limit (CI_L), and upper limit (CI_U) for each item.
3.  A table of the parameters used in the calculation.
4.  If selected, a bar chart visualizing the V and confidence interval for each item.

## A test data.frame

You can test the plug-in with this data set:

```
test_v <- data.frame(cbind(
  "r1" = c(2, 2, 2, 2, 3, 3, 3, 1, 1, 1, 4, 4, 2, 1, 4, 4, 3, 3, 3, 3),
  "r2" = c(5, 2, 3, 2, 3, 4, 3, 2, 2, 3, 4, 4, 3, 2, 5, 4, 4, 3, 4, 4),
  "r3" = c(5, 3, 4, 3, 4, 4, 4, 3, 3, 5, 4, 5, 4, 3, 5, 5, 4, 3, 4, 4),
  "r4" = c(5, 3, 4, 4, 5, 5, 4, 3, 3, 5, 4, 5, 4, 4, 5, 5, 4, 4, 5, 4),
  "r5" = c(5, 3, 4, 5, 5, 5, 4, 4, 3, 5, 4, 5, 4, 4, 5, 5, 4, 4, 5, 5),
  "r6" = c(5, 4, 5, 5, 5, 5, 4, 5, 4, 5, 5, 5, 5, 4, 5, 5, 5, 4, 5, 5),
  "r7" = c(5, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 5, 5, 5, 4, 5, 5)
))
```

### Deeper discussion

A longer treatment can be found here: [https://alfcano.github.io/aiken_v/](https://alfcano.github.io/aiken_v/)


## License

This plugin is licensed under the GPL (>= 3).

## Author

* Alfonso Cano Robles.  
* Assited by Gemini a Large Language Model by Google.  

