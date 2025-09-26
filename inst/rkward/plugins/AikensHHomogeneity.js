// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var data_frame = getValue("var_data_h");
    var lo = getValue("num_lo_h");
    var hi = getValue("num_hi_h");
    var p = getValue("drp_p_h");

    echo("calculate_s <- function(ratings) {\n");
    echo("  ratings <- as.numeric(ratings)\n");
    echo("  ratings <- ratings[!is.na(ratings)]\n");
    echo("  if (length(ratings) < 2) { return(0) }\n");
    echo("  pairs <- combn(ratings, 2)\n");
    echo("  s_value <- sum(abs(pairs[1, ] - pairs[2, ]))\n");
    echo("  return(s_value)\n");
    echo("}\n\n");

    echo("aiken_h <- function(df, lo, hi, p) {\n");
    echo("  c <- (hi - lo) + 1\n");
    echo("  n <- ncol(df)\n");
    echo("  m <- nrow(df)\n");
    echo("  jm <- ifelse(m %% 2 == 0, 0, 1)\n");
    echo("  jn <- ifelse(n %% 2 == 0, 0, 1)\n");
    echo("  s_n_values <- apply(df, 1, calculate_s)\n");
    echo("  denominator_n <- (c - 1) * (n^2 - jn)\n");
    echo("  h_n_values <- 1 - (4 * s_n_values) / denominator_n\n");
    echo("  results_n <- data.frame(Item = rownames(df), S_n = s_n_values, H_n = h_n_values)\n");
    echo("  s_m_values <- apply(df, 2, calculate_s)\n");
    echo("  denominator_m <- (c - 1) * (m^2 - jm)\n");
    echo("  h_m_values <- 1 - (4 * s_m_values) / denominator_m\n");
    echo("  results_m <- data.frame(Rater = colnames(df), S_m = s_m_values, H_m = h_m_values)\n");
    echo("  H_bar <- mean(results_m$H_m, na.rm = TRUE)\n");
    echo("  mu_h <- (2 * (c + 1) + (m + jm) * (c - 2)) / (3 * c * (m + jm))\n");
    echo("  sigma_numerator_part1 <- 2 * (c + 1) * (m + jm - 1)\n");
    echo("  sigma_numerator_part2 <- c^2 * (m + 3) - 2 * (2*m - 9)\n");
    echo("  sigma_numerator <- sqrt(sigma_numerator_part1 * sigma_numerator_part2)\n");
    echo("  sigma_denominator <- (c - 1) * (m + jm) * (m^2 - jm)\n");
    echo("  sigma_h <- if (sigma_denominator == 0) { NA } else { (2 / (3*c)) * (sigma_numerator / sigma_denominator) }\n");
    echo("  z_score <- if (is.na(sigma_h) || sigma_h == 0) { NA } else { sqrt(n) * (H_bar - mu_h) / sigma_h }\n");
    echo("  p_value <- pnorm(z_score, lower.tail = FALSE)\n");
    echo("  is_significant <- p_value < p\n");
    echo("  significance_test <- list(description = \"Large-sample test for the mean of H across items (H_m)\", mean_H = H_bar, population_mean_mu = mu_h, population_sd_sigma = sigma_h, z_score = z_score, p_value = p_value, alpha = p, is_significant = is_significant)\n");
    echo("  final_list <- list(H_across_Raters = results_n, H_across_Items = results_m, Significance_of_Mean_H = significance_test)\n");
    echo("  return(final_list)\n");
    echo("}\n\n");

    echo("aiken_h_results <- aiken_h(df = " + data_frame + ", lo = " + lo + ", hi = " + hi + ", p = " + p + ")\n");

}

function printout(is_preview){
	// printout the results
	new Header(i18n("Aiken's H for Homogeneity")).print();

    echo("rk.header(\"Homogeneity across Raters (Hn)\", level=3);\n");
    echo("rk.print(paste(\"Measures agreement among raters for each item.\"))\n");
    echo("rk.results(aiken_h_results$H_across_Raters, print.rownames=FALSE);\n\n");
    echo("rk.header(\"Homogeneity across Items (Hm)\", level=3);\n");
    echo("rk.print(paste(\"Measures consistency of each rater across all items.\"))\n");
    echo("rk.results(aiken_h_results$H_across_Items, print.rownames=FALSE);\n\n");
    echo("rk.header(\"Significance Test for Mean Homogeneity\", level=3);\n");
    echo("rk.results(as.data.frame(aiken_h_results$Significance_of_Mean_H), print.rownames=FALSE);\n");

	//// save result object
	// read in saveobject variables
	var savResultH = getValue("sav_result_h");
	var savResultHActive = getValue("sav_result_h.active");
	var savResultHParent = getValue("sav_result_h.parent");
	// assign object to chosen environment
	if(savResultHActive) {
		echo(".GlobalEnv$" + savResultH + " <- aiken_h_results\n");
	}

}

