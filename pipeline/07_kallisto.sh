#!/bin/bash
#SBATCH --ntasks 8 --nodes 1 --mem 8G --out logs/kallisto.%a.log -J kallisto -p short

module load kallisto
CPU=8
N=${SLURM_ARRAY_TASK_ID}
INDIR=raw
OUTDIR=results
SAMPLEFILE=samples.csv

mkdir -p $OUTDIR/kallisto_single

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi
IFS=,
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read PREFIX GENOTYPE TREATMENT REP
do
 SAMPINFO=${GENOTYPE}.${TREATMENT}.r${REP}
 OUTFILE=$OUTDIR/kallisto_single/$SAMPINFO
 READS=$(ls $INDIR/${PREFIX}_S*_R1_001.fastq.gz)
 if [ ! -f $OUTFILE/abundance.h5 ]; then
  kallisto quant -i genome/Clus.CDS.idx -o $OUTFILE -t $CPU --bias --single -l 300 --sd 1000 $READS
 fi
done
