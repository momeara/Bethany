# -*- tab-width:2;indent-tabs-mode:t;show-trailing-whitespace:t;rm-trailing-spaces:t -*-
# vi: set ts=2 noet:


#' Run phyml
#' @export
phyml <- function(
	phylip,
	run_id = NULL,
	run_script_fname = NULL,
	data_type = 'aa',
	model = "LG",
	search = "NNI",
	ncores=18,
	max_mem=10000,
	output_fmt="phylip",
	seqtype="protein"
){
	input_base <- tempfile()

	if(is.character(phylip)){
		if(
			!stringr::str_detect(phylip, ".phylip$") &&
			!stringr::str_detect(phylip, ".phy") &&
			!stringr::str_detect(phylip, ".ph")){
			cat("WARNING: phylip '", phylip, "', does not end in '.phy', '.ph', or '.phylip'\n")
		}
		phylip_fname <- phylip
	} else {
		stop("Currently I don't know how to convert an R file into a .phylip MSA\n")
	}

	if(is.null(run_id)){
		run_id = stringr::str_replace(phylip_fname, ".phylip$", "")
	}

	cmd <- paste0(
    "phyml ",
    "--input ", phylip_fname, " ",
    "--datatype ", data_type, " ",
		"--model ", model, " ",
		"--search ", search, " ",
		"--run_id ", run_id, " ",
		"--quiet ",
		"--no_memory_check ")

	if(!is.null(run_script_fname)){
		cat(
			"#Run PhyML\n",
			cmd, "\n\n", sep="", file=run_script_fname, append=T)
	}

	cat(cmd, "\n")
	system(cmd)
}
