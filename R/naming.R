# -*- tab-width:2;indent-tabs-mode:t;show-trailing-whitespace:t;rm-trailing-spaces:t -*-
# vi: set ts=2 noet:


# extract uniprot entry and range from hmmer fasta sequences
hmmer_fasta_to_uniprot_entry <- function(fasta_names){
	fasta_names %>%
		stringr::str_split_fixed("[/]", 2) %>%
		as.data.frame(stringsAsFactors=F) %>%
		dplyr::select(
			uniprot_entry = V1,
			range = V2) %>%
		dplyr::mutate(
			tree_name=uniprot_entry)
}


# number sequences sequentially in the phylip format XXXX_XXXXX
generate_phylip_names <- function(n){
	a <- 1:n %>% as.character %>% stringr::str_pad(9, pad="0")
	paste(a %>% stringr::str_sub(1, 4), a %>% stringr::str_sub(5, 9), sep="_")
}

# convert a uniprot entry to a phylip name by just taking the "X" part:  aaXXXX_XXXXXaaa
uniprot_entry_to_phylip_name <- function(uniprot_entries){
	paste0(
		uniprot_entries %>%
			stringr::str_split_fixed("_", 2) %>%
			magrittr::extract(,1) %>%
			stringr::str_sub(-4, -1), "_",
		uniprot_entries %>%
			stringr::str_split_fixed("_", 2) %>%
			magrittr::extract(,2) %>%
			stringr::str_sub(1, 5))
}

# assume data has columns where together they uniquely identify a sequence
#  uniprot_entry
#  range
make_tree_names <- function(
	data,
	user_agent_arg,
	verbose=F
){
	data <- data %>%
		assertr::verify("uniprot_entry" %>% exists) %>%
		assertr::verify("range" %>% exists) %>%
		assertr::verify(no_duplicates(uniprot_entry, range)) %>%
		dplyr::mutate(index = 1:nrow(data))

	missing_protein_names <- c(
		"Uncharacterized protein",
		"Uncharacterized protein (Fragment)",
		"Predicted protein",
		"Putative uncharacterized protein")

	new_names <- uniprot_entry_web_lookup(
		data$uniprot_entry %>% unique,
		c("entry name", "genes(PREFERRED)", "organism", "organism-id", "protein names"),
		user_agent_arg,
		verbose) %>%
		dplyr::select(
			uniprot_entry,
			gene_symbol = `Gene names  (primary )`,
			organism = Organism,
			organism_id = `Organism ID`,
			protein_name = `Protein names`) %>%
		dplyr::mutate(
			organism = ifelse(is.na(organism), NULL,
				# pull out the first term in parentheses
				organism %>% stringr::str_match("^.[^(]*[(]([^)]*)[)]") %>% magrittr::extract(,2)),
			protein_name = ifelse(protein_name %in% missing_protein_names, "",
				protein_name %>%
					stringr::str_replace_all("[(]", "[") %>%
					stringr::str_replace_all("[)]", "]")))

	data %>%
		dplyr::left_join(new_names, by=c("uniprot_entry")) %>%
		dplyr::mutate(tree_name = paste(
			uniprot_entry, range,
			gene_symbol,
			organism, organism_id,
			protein_name, sep="|")) %>%
		dplyr::arrange(index, tree_name) %>%
		dplyr::distinct(index, .keep_all=TRUE)
}


#' Rename a tree read in by ape
#' @export
rename_tree <- function(
	tree,
	name_map,
	old_names_col = "phylip_name",
	new_names_col = "tree_name"
){
	tree$tip.label <- dplyr::data_frame(old_name = tree$tip.label) %>%
		dplyr::left_join(
			name_map %>%
				dplyr::select_(.dots = list(
					old_name = old_names_col,
					new_name = new_names_col)),
			by=c("old_name")) %>%
		dplyr::mutate(new_name = ifelse(new_name %>% is.na, old_name, new_name)) %>%
		magrittr::extract2("new_name")
	tree
}
