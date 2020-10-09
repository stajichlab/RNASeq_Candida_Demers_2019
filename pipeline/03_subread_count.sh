#!/bin/bash
#SBATCH --nodes 1 --ntasks 24 --mem 96G -J subreadcount -p short
#SBATCH --time 2:0:0 --out logs/subread_count.log

module load subread/1.6.2

GENOME=genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
# transcript file was updated to recover missing genes
GFF=genome/candida_lusitaniae_1_fixed.gtf
OUTDIR=results/featureCounts
INDIR=aln
EXTENSION=gsnap.bam
mkdir -p $OUTDIR
TEMP=/scratch
SAMPLEFILE=samples.csv

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

IFS=,
OUTFILE=$OUTDIR/ClusDemers_2019.subRead_gsnap.tab
BAM=$(ls $INDIR/*.bam)
echo $BAM
featureCounts -g gene_id -T $CPUS -G $GENOME -a $GFF --tmpDir $TEMP -o $OUTFILE -F GTF $INDIR/*.bam
perl -i -p -e 's/aln\///g; s/\.gsnap\.bam//g;' $OUTFILE $OUTFILE.summary
