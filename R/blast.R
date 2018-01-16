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

	if(class(ref) == "list" && all(vapply(ref, class, "") == "SeqFastaAA", na.rm=T)){
		ref_fname <- paste0(tmp_base, "/ref.fasta")
		if(verbose){
			cat("Writing out reference sequences to '", ref_fname, "' ...\n", sep="")
		}
		seqinr::write.fasta(ref, names(ref), ref_fname)
	} else if(class(ref) == "character"){
		ref_fname <- ref
	} else {
		stop(paste0("Unable to read ref of class '", class(ref), "'. Please make it a list of of SeqFastaAA (e.g. read in with seqinr::read.fasta), or a path to a fasta file in the file system."))
	}

	if(class(query) == "list" && all(vapply(query, class, "") == "SeqFastaAA", na.rm=T)){
		query_fname <- paste0(tmp_base, "/query.fasta")
		if(verbose){
			cat("Writing out query sequences to '", query_fname, "' ...\n", sep="")
		}
		seqinr::write.fasta(query, names(query), query_fname)
	} else if(class(query) == "character"){
		query_fname <- query
	} else {
		stop(paste0("Unable to read qeury of class '", class(ref), "'. Please make it a list of of SeqFastaAA (e.g. read in with seqinr:::read.fasta), or a path to a fasta file in the file system."))
	}

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
	results <- readr::read_tsv(blastp_results_fname, col_names=F) %>%
		dplyr::select(
			ref_target = 1,
			query_target = 2,
			bit_score = 3,
			EValue = 4)
	return(results)
}
