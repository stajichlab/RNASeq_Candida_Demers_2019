#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 1 --mem 16G --time 2:00:00 
#SBATCH -p short --out logs/picard.%a.log -J picardInsertStat

module load java/8
module load picard

GENOME=genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT
BEDGENES=genome/candida_lusitaniae_1_transcripts.bed
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
INDIR=raw
OUTDIR=aln
REPORTDIR=reports
mkdir -p $REPORTDIR
SAMPLEFILE=samples.txt
mkdir -p $OUTDIR

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi
IFS=,
sed -n ${N}p $SAMPLEFILE | while read FOLDER SAMPLE REP
do
 echo $FOLDER $SAMPLE
 GSNAPBAM=$OUTDIR/${SAMPLE}.r${REP}.gsnap.bam
 if [ -f $GSNAPBAM ]; then
  if [ ! -f $REPORTDIR/$SAMPLE.r${REP}.gsnap.picardreport.txt ]; then
   java -jar $PICARD CollectInsertSizeMetrics I=$GSNAPBAM O=$REPORTDIR/${SAMPLE}.r${REP}.gsnap.picardreport.txt H=${REPORTDIR}/${SAMPLE}.r${REP}.gsnap.picardreport.pdf METRIC_ACCUMULATION_LEVEL=SAMPLE M=0.5
 fi
 fi
done

