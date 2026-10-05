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

# Create directory for reference genome
mkdir -p "$OUTPUT_DIR/genome"






# Only prepare the reference genome if the Bowtie2 index does not already exist
#if is from BASH  [ ! -f FILE] found during help test - I accidnetally ran the pipeline before it was finished 
if [ ! -f "$OUTPUT_DIR/genome/Tcongo_index.1.bt2" ]
then

        # Copy reference genome into the project
        cp "$DATA_DIR/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz" "$OUTPUT_DIR/genome/"

        # Decompress reference genome while keeping compressed copy
        gzip -dk "$OUTPUT_DIR/genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz"

        # Build Bowtie2 index
        bowtie2-build "$OUTPUT_DIR/genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta" \
                      "$OUTPUT_DIR/genome/Tcongo_index"

fi

#Creating the directory for the fastq results, the -p then tells bash that if the folder already exists then to carry on after its created
 
mkdir -p "$OUTPUT_DIR/fastq_results"

#running fastqc on all fastq files 
for FILE in "$FASTQ_DIR"/*.fq.gz
do 
	fastqc "$FILE" -o "$OUTPUT_DIR/fastq_results"
done 
#this finds all the files ending in .fq.gz in the FASTQ directory  such  as Tco-230_fq.gz etc and then cretaes a loop(do, done) that will  run FASTQC on each of the files, placing the results in the directory 
#-o  where to put output


#note read puts text into variables 

# Create directory for alignment results
mkdir -p "$OUTPUT_DIR/alignment_results"

#$SAMPLE = Tco230
#$END1   = Tco-230_1.fq.gz
#$END2   = Tco-230_2.fq.gz


# Read each sample pair from the metadata file
tail -n +2 "$FASTQ_DIR/Tco2.fqfiles" | while read SAMPLE TYPE REP TIME TREATMENT END1 END2
do
        echo "Processing $SAMPLE"

        # Align paired reads
        bowtie2 -x "$OUTPUT_DIR/genome/Tcongo_index" \
                -1 "$FASTQ_DIR/$END1" \
                -2 "$FASTQ_DIR/$END2" \
                -S "$OUTPUT_DIR/alignment_results/$SAMPLE.sam"

        # Convert SAM to BAM
        samtools view -b \
                -o "$OUTPUT_DIR/alignment_results/$SAMPLE.bam" \
                "$OUTPUT_DIR/alignment_results/$SAMPLE.sam"

        # Sort BAM
        samtools sort \
                -o "$OUTPUT_DIR/alignment_results/${SAMPLE}_sorted.bam" \
                "$OUTPUT_DIR/alignment_results/$SAMPLE.bam"

        # Index sorted BAM
        samtools index "$OUTPUT_DIR/alignment_results/${SAMPLE}_sorted.bam"

done
