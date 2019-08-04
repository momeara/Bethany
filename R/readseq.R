# -*- tab-width:2;indent-tabs-mode:t;show-trailing-whitespace:t;rm-trailing-spaces:t -*-
# vi: set ts=2 noet:

#' Run readseq
#' @export
readseq <- function(
	input_fname,
	output_fname,
	run_script_fname = NULL,
	informat="fasta", format="Phylip4"
){
	cmd <- paste0(
		"readseq ",
		"-informat=", informat, " ",
		"-format=", format, " ",
		"-output=", shQuote(output_fname), " ",
		shQuote(input_fname))

	if(!is.null(run_script_fname)){
		cat(
			"#Run readseq to convert '", informat, "' to '", format, "'\n",
			cmd, "\n\n", sep="", file=run_script_fname, append=T)
	}

	cat(cmd, "\n")
	system(cmd)
}
