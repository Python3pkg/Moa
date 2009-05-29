# Create a BLAST database from a set of sequences
################################################################################

# Main target defintion
moa_main_target: check create_blast_db create_id_list set_blastdb_weka


################################################################################
# Definitions

# Help
moa_ids += createblastdb
moa_title_createblastdb = Create a BLAST database 
moa_description_createblastdb = Takes a multi-fasta input file and creates a BLAST database.

#Targets (for generating help)
moa_targets += create_blast_db clean set_blastdb_weka clean_blastdb_weka
create_blast_db_help = Create the BLAST database
clean_help = Remove the blast database
set_weka_help = set location in the global weka db
clean_weka_help = clean location in the global weka db (will not run automatically)

#Outputs (for generating help)
moa_outputs += blastdb
moa_output_blastdb = ./set_name.???
moa_output_blastdb_help = The blast database created

#Variable: set_name
moa_must_define += name 
name_help = The name of the set, determines the name of the blast db

moa_may_define = input_dir input_extension
input_dir_help = Dir with the input fasta files, defaults to ./fasta
input_extension_help = extension of the input sequence files, defaults to fasta

#Variable: protein
moa_may_define += protein 
protein_help = Protein database? (T)rue) or not (F)alse (default: F)

#Include base moa code - does variable checks & generates help
ifndef dont_include_moabase
	include $(shell echo $$MOABASE)/template/moaBase.mk
endif

################################################################################
# End of the generic part - from here on you're on your own :)

input_dir ?= ./fasta
input_extension ?= fasta

.PHONY: create_blast_db

#the rest of the variable definitions 
protein ?= F
input_files ?= $(wildcard $(input_dir)/*.$(input_extension))
fasta_file = $(name).fasta

ifeq ("$(protein)", "F")
	one_blast_db_file = $(name).nhr
else
	one_blast_db_file = $(name).phr
endif
     

create_blast_db: $(one_blast_db_file)
			
$(one_blast_db_file): $(fasta_file)
	@echo "Creating $@"
	formatdb -i $< -p $(protein) -o T -n $(name)

$(fasta_file): $(input_files)
	-rm -f $(fasta_file)
	for x in $^; do \
		cat $$x >> $(fasta_file) ;\
		echo >> $(fasta_file) ;\
	done
		
create_id_list: $(name).list

$(name).list: $(fasta_file)
	grep ">" $(fasta_file) | cut -c2- | sed 's/ /\t/' | sort > $(name).list
	
set_blastdb_weka:
	weka -r set $(name)::blastdb `pwd`/$(name)
	weka -r set $(name)::fasta `pwd`/$(input_file)
	weka -r set $(name)::idlist `pwd`/$(name).list	
	
clean: create_blast_db_clean
create_blast_db_clean:	
	-if [ $(protein) == "F" ]; then \
		rm $(name).n?? ;\
	else \
		rm $(name).p?? ;\
	fi
	
clean_blastdb_weka:
	weka rm $(name)::blastdb