#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 1 --mem 16gb -p short  --time 2:00:00 -J gsnap.makebam --out logs/gsnap_makebam.%a.log

module load picard
MEM=16
GENOME=genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

N=$SLURM_ARRAY_TASK_ID
INDIR=aln
OUTDIR=aln
SAMPLEFILE=samples.csv
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

infile=${INDIR}/${SAMPINFO}.gsnap.sam
bam=${INDIR}/${SAMPINFO}.gsnap.bam
bai=${INDIR}/${SAMPINFO}.gsnap.bai
echo "$infile $bam"
echo "CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT TMP_DIR=/scratch/${USER} RGID=$PREFIX RGSM=$SAMPINFO RGPL=NextSeq RGPU=Dartmouth RGLB=$PREFIX"
if [ ! -f $bai ]; then
 java -Xmx${MEM}g -jar $PICARD AddOrReplaceReadGroups SO=coordinate I=$infile O=$bam CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT TMP_DIR=/scratch/${USER} RGID=$PREFIX RGSM=$SAMPINFO RGPL=NextSeq RGPU=Dartmouth RGLB=$PREFIX
 if [ -f $bam ]; then
  rm $infile; 
 # touch $infile
 # touch $bam
 fi
fi

done
