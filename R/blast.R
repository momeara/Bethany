# -*- tab-width:2;indent-tabs-mode:t;show-trailing-whitespace:t;rm-trailing-spaces:t -*-
# vi: set ts=2 noet:

#' Blast query sequences against reference sequences
#'
#' requires makeblastdb and blastp from blast+ to be on the path
#'
#' @param ref list of vector of chars where each element is a sequence object of class SeqFastadna or SeqFastaAA, e.g. what is returned by seqinr::read.fasta
#' @param query list of vector of chars where each element is a sequence object of class SeqFastadna or SeqFastaAA, e.g. what is returned by seqinr::read.fasta
#' @param run_id character string used to name temporary files etc.
#' @param cmd_makeblastdb the command used to make the reference database e.g. makeblastdb from the blast+ package
#' @param cmd_blastp the command used to blast the queries against the reference sequences e.g. blastp
#' blastp_num_threads the number of threads to use while running blast
#' @param verbose write out additional information while executing.
#' @export
blastp <- function(
	ref,
	query,
	run_id,
	cmd_makeblastdb = "makeblastdb",
	cmd_blastp = "blastp",
	blastp_num_threads = "16",
	verbose=F
){
	tmp_base <- paste0(tempfile(), "_blastp_", run_id)
	dir.create(tmp_base)

	prepare_sequences <- function(sequences, type){
		if(class(sequences) == "list" &&
			all(vapply(sequences, class, "") == "SeqFastaAA" | vapply(sequences, class, "") == "character", na.rm=T)){
			fasta_fname <- paste0(tmp_base, "/", type, ".fasta")
			if(verbose){
				cat("Writing out ", type, " sequences to '", ref_fname, "' ...\n", sep="")
			}
			seqinr::write.fasta(sequences, names(sequences), fasta_fname)
		} else if(class(sequences) == "character"){
			fasta_fname <- sequences
		} else {
			stop(paste0("Unable to read ", type, " of class '", class(sequences), "'. Please make it a list of of SeqFastaAA (e.g. read in with seqinr::read.fasta), or a path to a fasta file in the file system."))
		}
		fasta_fname
	}
	ref_fname <- prepare_sequences(ref, "ref")
	query_fname <- prepare_sequences(query, "query")

	### make reference db
	if(verbose){
		cat("Making blastp database from reference sequences ...\n")
	}
	cmd <- paste0(
		cmd_makeblastdb,
		" -dbtype prot",
		" -in ", shQuote(ref_fname))
	cat(cmd, "\n")
	system(cmd)

	blastp_results_fname <- paste0(tmp_base, "/blast_results.csv")
	if(verbose){
		cat("Blasting query sequences against reference sequences generating '", blastp_results_fname, "' ...\n", sep="")
	}
	cmd <- paste0(
		cmd_blastp,
		" -db ", shQuote(ref_fname),
		" -query ", shQuote(query_fname),
		" -outfmt \"6 qseqid sseqid bitscore evalue\"",
		" -num_threads ", blastp_num_threads,
		" -out ", shQuote(blastp_results_fname))
	cat(cmd, "\n")
	system(cmd)

	if(verbose){
		cat("Reading in blastp results ... \n")
	}
	readr::read_tsv(
		file=blastp_results_fname,
		col_names = c("ref_target", "query_target", "bit_score", "EValue"),
		col_types=readr::cols(
			ref_target = readr::col_character(),
			query_target = readr::col_character(),
			bit_score = readr::col_double(),
			EValue = readr::col_double()))
}
