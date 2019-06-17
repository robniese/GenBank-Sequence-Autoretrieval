#This script is designed to automatically download FASTA sequence data for a given gene for an entire list of taxa. 
#Your list (a vector) could also be replaced with CSV file (read it in, specify columns to use). The script queries
#the online database (<https://www.ncbi.nlm.nih.gov/genbank/>), however, and can take a long time for larger lists of taxa.


#be sure to install these packages the first time you run this script
#install.packages ("rentrez")
#install.packages("seqinr")

#set where you want to save and edit files from
setwd("C:/Users/dbsadmin/Google Drive/R_Files/Pigeon Phylogeny/texts")

#make a blank text file in this folder with the name that is specified below. Currently it is "TreronFetchResults.txt"

#load packages; only once
library (rentrez)
library (ape)
library ("seqinr")
sessionInfo() #double check packages are loaded

##I pasted this list of species from Wikipedia into a text file, then cleaned it up, added punctuation, and copy-pasted it here. 
##Should work up to 200 spp at a time (slowly).
####Note: to search a single species, see tutorial at ??rentrez

TreronSpecies <- c("Treron fulvicollis","Treron olax","Treron vernans","Treron bicinctus","Treron pompadora","Treron affinis","Treron chloropterus","Treron phayrei","Treron axillaris","Treron aromaticus","Treron curvirostra","Treron griseicauda","Treron teysmannii","Treron floris","Treron psittaceus","Treron capellei","Treron phoenicopterus","Treron waalia","Treron australis","Treron griveaudi","Treron calvus","Treron pembaensis","Treron sanctithomae","Treron apicauda","Treron oxyurus","Treron seimundi","Treron sphenurus","Treron sieboldii","Treron formosae")

#now, we'll conduct x number of searches for x number of species that you specified in TreronSpecies above.

cutoff = length(TreronSpecies) #tells the script when to stop. Double-check that the last species in your list matches the last species in your text output later.

x = 0 #always start with x at 0

repeat {
  if (x > cutoff) {break}
  x = x+1
  repeat {
        
        TreronTerm = paste(TreronSpecies[x], "[Organism] AND COI[Gene Name] AND (0[SLEN] : 850[SLEN])", sep = "")   #defines a search term appended (pasted) onto your species name from the list above; here, i'm using search terms for the gene name (COI) and target sequence length range (0-850); for complete terms see tutorial at ??rentrez 
        TreronSpeciesSearch <- entrez_search(db = "nuccore", #specify the database to use (nuccore is for nucleotide data; for a list of databases see the tutorial at ??rentrez)
                                     term = TreronTerm,
                                     retmax = 1) #specifies how many samples you want to keep (here I only want 1, not all 1126 that are available)
        
        if(x > cutoff) {break} 
        else if(length(TreronSpeciesSearch$ids) == 0) 
                {NoData = paste(TreronSpecies[x], "- no COI data available", sep = " ")
                NoDataEntry = paste(">", NoData, sep = "")
                write(NoDataEntry, "TreronFetchResults.txt", sep="\n", append = TRUE)
                x = x+1
                }
        else {break}
          }                    ##if there isn't data available for a species, the search will terminate, paste the species name and a "no data available" note. This is valuable for retaining data in a certain order, regardless of species name variations
  if (x > cutoff) {break}      
  TreronSeqs <- entrez_fetch(db="nuccore", id=TreronSpeciesSearch$ids, rettype="fasta")
  write(TreronSeqs, "TreronFetchResults.txt", sep="\n", append = TRUE)
  }                           ##if there is data available for a species, retrieves the FASTA data and pastes (appends) it to the specified .txt file

#repeat for all genes of interest (change COI[Gene Name] in TreronTerm); don't forget to alter the sequence length range (SLEN variable)
#can also use generic search terms such as "AND fibrinogen" instead of "AND FBG[Gene Name]"
####also, note that entrez_db_searchable("nuccore") specifies 3 or 4-letter codes (e.g. [ORGN] instead of 
####[Organism], [GENE] instead of [Gene Name]). This might be affecting searches.
