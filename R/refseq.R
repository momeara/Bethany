# -*- tab-width:2;indent-tabs-mode:t;show-trailing-whitespace:t;rm-trailing-spaces:t -*-
# vi: set ts=2 noet:



refseq_gene_id_to_protein_ids <- function(gene_id){
	rentrez::entrez_link(db="protein", dbfrom="gene", id=gene_id)$links$gene_protein
}

refseq_protein_id_to_fasta <- function(protein_id){
	rentrez::entrez_fetch(db="protein", rettype="fasta", id=protein_id) %>%
		textConnection %>%
		seqinr::read.fasta %>%
		seqinr::getSequence %>%
		magrittr::extract2(1) %>%
		paste(collapse="") %>%
		toupper
}

#' @export
refseq_gene_id_to_protein_sequence <- function(gene_ids){
	z <- plyr::ldply(gene_ids, function(gene_id){
		protein_ids <- refseq_gene_id_to_protein_ids(gene_id)
		plyr::ldply(protein_ids, function(protein_id){
			dplyr::data_frame(
				gene_id = gene_id,
				protein_id = protein_id,
				protein_sequence = refseq_protein_id_to_fasta(protein_id))
		})
	})

	z %>%
		dplyr::mutate(seq_length = nchar(protein_sequence)) %>%
		dplyr::arrange(dplyr::desc(seq_length)) %>%
		dplyr::distinct(gene_id, .keep_all=TRUE)
}
