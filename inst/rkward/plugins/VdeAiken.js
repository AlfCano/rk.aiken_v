// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    // This function is called by the preview button.
    preprocess();
    calculate();
    printout(true); // "true" means: Create the plot, but not any headers or other output.

}

function preprocess(is_preview){
	// add requirements etc. here



    // This function is called by the preview button before running the preview.
    echo("require(ggplot2)\n");
    echo("require(tibble)\n");

}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    // This function is called when the "Submit" button is pressed.
    var data_frame = getValue("var_data");
    var lo = getValue("num_lo");
    var hi = getValue("num_hi");
    var p = getValue("drp_p");

    // Begin the R code generation
    echo("v_aiken <- function(x, lo, hi, p) {\n");
    echo("    n <- ncol(x)\n");
    echo("    i <- nrow(x)\n");
    echo("    k <- (hi - lo)\n");
    echo("    z <- qnorm((1 - (p)) / 2, mean = 0, sd = 1, lower.tail = FALSE)\n");
    echo("    S <- rowSums(x - lo)\n");
    echo("    V <- S / (n * k)\n");
    echo("    A <- (2 * n * k * V) + (z^2)\n");
    echo("    B <- (z * (sqrt(4 * n * k * V * (1 - V) + (z^2))))\n");
    echo("    C <- (2 * ((n * k) + (z^2)))\n");
    echo("    L <- (A - B) / C\n");
    echo("    U <- (A + B) / C\n");
    echo("    df <- data.frame(cbind(\"V\" = V, \"CI_L\" = L, \"CI_U\" = U))\n");
    echo("    rownames(df) <- paste0(\"Item_\", 1:i)\n");
    echo("    means_list <- list()\n");
    echo("    for (col_name in names(df)) {\n");
    echo("      mean_value <- mean(df[[col_name]])\n");
    echo("      means_list[[col_name]] <- mean_value\n");
    echo("    }\n");
    echo("    means_df <- data.frame(Medias = unlist(means_list))\n");
    echo("    v_list <- list()\n");
    echo("    v_list[[\"v_ci\"]] <- df\n");
    echo("    v_list[[\"means_v\"]] <- means_df\n");
    echo("    parameters <- list()\n");
    echo("    noms_par <- c(\"n\", \"k\", \"p\", \"z\", \"lo\", \"hi\", \"i\")\n");
    echo("    for (e in 1:length(noms_par)) {\n");
    echo("      nombre_actual <- noms_par[e]\n");
    echo("      parameters[[nombre_actual]] <- get(nombre_actual)\n");
    echo("    }\n");
    echo("    v_list[[\"parameters\"]] <- parameters\n");
    echo("    return(v_list)\n");
    echo("  }\n");
    echo("\n");
    echo("aiken_results <- v_aiken(x = " + data_frame + ", lo = " + lo + ", hi = " + hi + ", p = " + p + ")\n");

}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("V de Aiken results")).print();	
	}
    // If "is_preview" is false, it generates the full code, including text output.
    if (!is_preview) {
        echo("rk.header(\"Aiken's V Coefficient\")\n");
        echo("rk.header(\"Aiken's V and Confidence Intervals per Item\", level=3);\n");
        echo("rk.print(aiken_results$v_ci);\n");
        echo("rk.header(\"Global means\", level=3);\n");
        echo("rk.print(aiken_results$means_v);\n");
        echo("rk.header(\"Calculation parameters\", level=3);\n");
        echo("rk.print(as.data.frame(aiken_results$parameters));\n");
    }

    // Plotting section
    var create_plot = getValue("chk_plot");
    // Golden Rule #5: Robust checkbox handling
    if(create_plot == "1" || create_plot == 1 || create_plot == "true" || create_plot === true){
        if (!is_preview) {
            echo("\n");
            echo("rk.graph.on()\n");
        }

        // This plot code is run for both preview and full run
        echo("try({\n");
        echo("    p <- aiken_results[[\"v_ci\"]] %>\%\n");
        echo("        tibble::rownames_to_column(var = \"Items\") %>\%\n");
        echo("        ggplot2::ggplot(ggplot2::aes(x = reorder(Items, V, decreasing=FALSE), y = V, ymin = CI_L, ymax = CI_U)) +\n");
        echo("        ggplot2::geom_col(fill = \"lightblue\") +\n");
        echo("        ggplot2::geom_errorbar(width = 0.5) +\n");
        echo("        ggplot2::ylim(0, 1) +\n");
        echo("        ggplot2::geom_hline(yintercept = " + getValue("spin_yintercept") + ", linetype = \"dashed\", color = \"red\") +\n");
        echo("        ggplot2::theme(plot.background = ggplot2::element_rect(fill=\"transparent\", color=NA)) +\n");
        echo("        ggplot2::coord_flip() +\n");
        echo("        ggplot2::ylab(\"V\") +\n");
        echo("        ggplot2::xlab(\"Item\") +\n");
        echo("        ggplot2::labs(title=\"Bar Plot of Aiken's V per Item\", subtitle=paste(\"CI en barras de error con p =\", aiken_results$parameters$p))\n");
        echo("    print(p)\n");
        echo("})\n");

        if (!is_preview) {
            echo("rk.graph.off()\n");
        }
    }

	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var savResult = getValue("sav_result");
		var savResultActive = getValue("sav_result.active");
		var savResultParent = getValue("sav_result.parent");
		// assign object to chosen environment
		if(savResultActive) {
			echo(".GlobalEnv$" + savResult + " <- aiken_results\n");
		}	
	}

}

