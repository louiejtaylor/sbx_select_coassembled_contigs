#!/usr/bin/Rscript

#This script selects contigs from a predefined list from a FASTA file generated by Sunbeam. 

#Import libraries
library(methods)
suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("Biostrings"))

#Set up argument parser and QC-------------------------------------------------
args <- commandArgs()

#print(args)
con <- args[6]
list <-args[7]
output <-args[8]

if(is.na(con)) 
{
  stop("Contig file not defined. Must be in FASTA format")
}

if(is.na(list)) 
{
  stop("List of contigs to select not defined.")
}

if(is.na(output)) 
{
  stop("Output file not defined")
}

#Read Data---------------------------------------------------------------------

#Testing
# con <- "/media/THING2/louis/09_SearchingExternalDatasets/Datasets/PositiveSamples/sunbeam_output/assembly/contigs/ERR906914-contigs.fa"
# list <- "/media/THING2/louis/09_SearchingExternalDatasets/Datasets/PositiveSamples/sunbeam_output/assembly/contigs/ERR906914_positive_contigs.txt"
# output <- "/media/THING2/louis/09_SearchingExternalDatasets/Datasets/PositiveSamples/sunbeam_output/assembly/contigs/ERR906914_positive_contigs.fa"

con_seqs <- readDNAStringSet(con, format = "fasta") 
con_df <- data.frame(names(con_seqs), paste(con_seqs))
colnames(con_df) <-  c("Name", "Sequence")
con_df <- separate(con_df, Name, into = c("Name", "Flag", "Multi", "Length"), 
         sep = " ")
con_df$Name <- as.character(con_df$Name)
con_df$Sequence <- as.character(con_df$Sequence)

list_con <- read.delim(list, header = TRUE, sep = " ")

#Subset data-------------------------------------------------------------------

select_con_df <- merge(list_con, con_df, by.x = "contig", by.y = "Name",
                       all.x = TRUE, all.y = FALSE)
select_con_df <- select_con_df[order(nchar(select_con_df$Sequence), decreasing = TRUE),]
select_con_df <- select(select_con_df, -c(sample, Flag, Multi, Length))
select_con_df <- unite(select_con_df, col = "Name", c("contig", "hit"), 
                       sep = ".")

#Write new FASTA---------------------------------------------------------------

select_seqs = select_con_df$Sequence
names(select_seqs) = select_con_df$Name
select_fasta = DNAStringSet(select_seqs)


writeXStringSet(select_fasta, output, append = FALSE, format = "fasta")


