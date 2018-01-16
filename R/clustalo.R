# -*- tab-width:2;indent-tabs-mode:t;show-trailing-whitespace:t;rm-trailing-spaces:t -*-
# vi: set ts=2 noet:

#' Run clustal omega
#' @export
clustalo <- function(
	fasta,
	output_fname,
	run_script_fname = NULL,
	ncores=18,
	max_mem=10000,
	output_fmt="phylip",
	seqtype="protein",
	force=F
){
	input_base <- tempfile()

	if(is.character(fasta)){
		if(!stringr::str_detect(fasta, ".fa$") & !stringr::str_detect(fasta, ".fasta$")){
			cat("WARNING: fasta '", fasta, "', does not end in '.fa' or '.fasta'\n")
		}
		fasta_fname <- fasta
	} else {
		fasta_fname <- paste0(input_base, "sequences.fasta")
		cat("writing fasta file to -> '", fasta_fname, "' ... ", sep="")
		seqinr::write.fasta(sequences = fasta, out.file = fasta_fname)
		cat("DONE\n")
	}

	cmd <- paste0(
    "clustalo ",
    "--infile ", shQuote(fasta), " ",
    "--threads ", shQuote(ncores), " ",
		"--MAC-RAM ", shQuote(max_mem), " ",
		"--verbose ",
		"--outfmt ", shQuote(output_fmt), " ",
		"--outfile `", shQuote(output_fname), "` ",
		"--output-order tree-order ",
		"--seqtype ", shQuote(seqtype))
	if(force){
		cmd <- paste(cmd, "--force")
	}

	if(!is.null(run_script_fname)){
		cat(
			"#Run clustal Omega\n",
			cmd, "\n\n", sep="", file=run_script_fname, append=T)
	}

	cat(cmd, "\n")
	system(cmd)
	output_fname
}

