#!/bin/bash
#telling linux to use bash


#MyFirstPipeline
#RNA-seq analysis pipeline for trypanosoma congoLense

#Setting directories 
DATA_DIR="/localdisk/data/BPSM/MyFirstPipeline"

FASTQ_DIR="$DATA_DIR/fastq"
OUTPUT_DIR="$HOME/MyFirstPipeline"

#DATA_DIR this creates variable so we dont have to keep repeating the /localdisk/data/BPSM/MyFirstPipeline ie giving it a shortter name
#OUTPUT_DIR  is the projects home directory 

#Creating the directory for the fastq results, the -p then tells bash that if the folder already exists then to carry on after its created
 
mkdir -p "$OUTPUT_DIR/fastq_results"

#running fastqc on all fastq files 
for FILE in "$FASTQ_DIR"/*.fq.gz
do 
	fastqc "$FILE" -o "$OUTPUT_DIR/fastq_results"
done 
#this finds all the files ending in .fq.gz in the FASTQ directory  such as Tco-230_fq.gz etc and then cretaes a loop(do, done) that will  run FASTQC on each of the files, placing the results in the directory 

