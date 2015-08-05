These are Scripts to do phylogenetic analysis

# refseq_tools.R
Wrappers around rentrez to retrieve sequences for gene ids

# blast_tools.R
Run blastp locally

# uniprot_idmapping_web.R
Retrieve information about proteins by their uniprot entries

# phylogenetic_pipeline.R
A pipeline for taking a set of sequences and automatically producing a phylogenetic tree


# Suggested usage
1) install required software and make sure it's on your path
     blast+, clustalo, readseq, phyml


2) Use http://www.ebi.ac.uk/Tools/hmmer to retrieve a fasta file. For PhyML, aim to get ~ 100 sequences or less.

3) Run pipeline
sequences_to_trees(
	<path/to/sequences.fa.gz>,
	<prot_dir/data>,
	<query_gene_tool_seq_db>,
	user_agent("httr <name@example.com>")) # for retrieving info from uniprot

This will produce a directory

   prod_dir/data/run_id_YYMMDD/
      <sequences.fa.gz>
         # input fasta sequences 
      run.sh
         # bash commands to re-run analysis
      name_map.xlsx
         # mapping between input, phylip and tree names, along with
         # the sequences an and information about each sequence
         # retrieved form Uniprot
      clustalo_input.fasta
         # input sequecences in fasta format with phylip names for clustal omega
      clustalo_output.phylip3.2
         # multiple sequence alignment with phylip names in phylip3.2 format
      phyml_input.phylip
         # multiple sequence alignment  in phylip4 format (phylip names)
      phyml_input.phylip_phyml_stats_<run_id>.txt
         # output log of running phyml
      phyml_input.phylip_phyml_tree_<run_id>.txt
         # tree generate as output from phyml (phylip names)
      <run_id>.newick
         # tree with informative names




