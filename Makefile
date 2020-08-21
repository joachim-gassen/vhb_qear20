TARGETS := raw_data data output 

.phony: data output all clean dist-clean

all: $(TARGETS)

dist-clean:
	rm -f -r host_access_keys.csv data/* raw_data/orbis* raw_data/names*

clean: clean
	rm -f data/* output/*

raw_data: raw_data/insolvency_filings_de_julaug20_incomplete.csv \
	raw_data/orbis_wrds_de.csv.gz
	
raw_data/orbis_wrds_de.csv.gz: code/download_data.R
	Rscript code/download_data.R

raw_data/insolvency_filings_de_julaug20_incomplete.csv: raw_data/orbis_wrds_de.csv.gz
	
data: 

output: 
