# RKWard Plugin: Aiken's V for Content Validity (`rk.aiken_v`)

> An RKWard plugin to calculate Aiken's V coefficient and its score confidence intervals for assessing content validity. Features detailed tabular output and a `ggplot2` bar chart with error bars and a live preview.

## Overview

This plugin provides a comprehensive tool within the RKWard graphical user interface for assessing the content validity of items rated by multiple judges using Aiken's V coefficient.

A key feature of this plugin is that it goes beyond a simple point estimate of V. It calculates **score confidence intervals** for the coefficient, allowing for a more robust and statistically sound inferential analysis, as proposed by Penfield & Giacobbi (2004). This helps researchers make more informed decisions about item retention or revision.

## Features

-   Calculates Aiken's V for each item in a data frame.
-   Generates score confidence intervals for each V value at user-specified levels (90%, 95%, 99%).
-   Provides summary tables for item-specific results and overall means.
-   Optionally creates a publication-ready bar chart using `ggplot2`, displaying V values with confidence intervals as error bars.
-   Includes a customizable reference line on the plot to visually assess item validity against a criterion.
-   Features a **live plot preview** to adjust the reference line before running the final analysis.

## Installation

### With `devtools` (Recommended)
You can install this plugin directly from the repository using the `devtools` package in R.

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

### Manual Installation
1.  Download this repository as a `.zip` file.
2.  In RKWard, go to **Settings -> R Packages -> Install package(s) from local zip file(s)** and select the downloaded file.
3.  Restart RKWard. The plugin will be available in the `Analysis` menu.

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
