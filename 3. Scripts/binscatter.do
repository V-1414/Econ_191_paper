clear all
 
import delimited "/Users/vidhi/VSCODE/Econ_191_paper/FinalPaperMaterial copy/2. Data/3. Processed/gp_analysis_dataset.csv", clear


//sc targeting vs polcomp binscatter
binscatter sc_targeting fragmentation_std
binscatter sc_targeting fragmentation_std if fragmentation_std  > -3 & sc_targeting_ratio <10
	// negative slope

//st targeting vs polcomp binscatter
binscatter st_targeting fragmentation_std
	// positive slope
	
binscatter scst_targeting fragmentation_std
	// almost flat

	
scatter ln_scst_targeting fragmentation_std
