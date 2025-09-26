// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here



    echo("require(ggplot2)\n");
    echo("require(tibble)\n");

}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var data_frame = getValue("var_data_v");
    var lo = getValue("num_lo_v");
    var hi = getValue("num_hi_v");
    var p = getValue("drp_p_v");

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
    echo("aiken_v_results <- v_aiken(x = " + data_frame + ", lo = " + lo + ", hi = " + hi + ", p = " + p + ")\n");

}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Aiken's V for Content Validity")).print();	
	}
    if (!is_preview) {
        echo("rk.header(\"Aiken\'s V and Confidence Intervals per Item\", level=3);\n");
        echo("rk.print(aiken_v_results$v_ci);\n");
        echo("rk.header(\"Global Means\", level=3);\n");
        echo("rk.print(aiken_v_results$means_v);\n");
        echo("rk.header(\"Calculation Parameters\", level=3);\n");
        echo("rk.print(as.data.frame(aiken_v_results$parameters));\n");
    }

    var create_plot = getValue("chk_plot_v");
    if(create_plot == "1"){
        // CORRECTED: rk.graph commands must be excluded from preview runs
        if(!is_preview) {
            echo("rk.graph.on()\n");
        }
        echo("try({\n");
        echo("    p <- aiken_v_results[[\"v_ci\"]] %>\%\n");
        echo("        tibble::rownames_to_column(var = \"Items\") %>\%\n");
        echo("        ggplot2::ggplot(ggplot2::aes(x = reorder(Items, V, decreasing=FALSE), y = V, ymin = CI_L, ymax = CI_U)) +\n");
        echo("        ggplot2::geom_col(fill = \"lightblue\") +\n");
        echo("        ggplot2::geom_errorbar(width = 0.5) +\n");
        echo("        ggplot2::ylim(0, 1) +\n");
        echo("        ggplot2::geom_hline(yintercept = " + getValue("spin_yintercept_v") + ", linetype = \"dashed\", color = \"red\") +\n");
        echo("        ggplot2::theme_bw() +\n");
        echo("        ggplot2::coord_flip() +\n");
        echo("        ggplot2::ylab(\"V\") +\n");
        echo("        ggplot2::xlab(\"Item\") +\n");
        echo("        ggplot2::labs(title=\"Bar Plot of Aiken\'s V per Item\", subtitle=paste(\"CI on error bars with p =\", aiken_v_results$parameters$p))\n");
        echo("    print(p)\n");
        echo("})\n");
        if(!is_preview) {
            echo("rk.graph.off()\n");
        }
    }

	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var savResultV = getValue("sav_result_v");
		var savResultVActive = getValue("sav_result_v.active");
		var savResultVParent = getValue("sav_result_v.parent");
		// assign object to chosen environment
		if(savResultVActive) {
			echo(".GlobalEnv$" + savResultV + " <- aiken_v_results\n");
		}	
	}

}

