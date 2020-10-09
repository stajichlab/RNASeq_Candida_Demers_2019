#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 24 --mem 16gb  -p short
#SBATCH --time 2:00:00 -J gmap --out logs/gmap.%a.log

module load gmap/2019-09-12
module load samtools
GENOME=genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT
CPU=2
THREADCOUNT=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
 THREADCOUNT=$(expr $CPU - 2)
 if [ $THREADCOUNT -lt 1 ]; then
  THREADCOUNT=1
 fi
fi

N=${SLURM_ARRAY_TASK_ID}
INDIR=raw
OUTDIR=aln
SAMPLEFILE=samples.csv
mkdir -p $OUTDIR

if [ ! $N ]; then
 N=$1
fi
IFS=,
if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read PREFIX GENOTYPE TREATMENT REP
do
 SAMPINFO=${GENOTYPE}.${TREATMENT}.r${REP} 
 echo "$SAMPINFO"
 OUTFILE=$OUTDIR/$SAMPINFO.gsnap.sam
 OUTBAM=$OUTDIR/$SAMPINFO.gsnap.bam
 READS=$(ls $INDIR/${PREFIX}_S*_R1_001.fastq.gz)
 echo "$READS"
 echo "$OUTFILE"
 if [ -f $OUTBAM ]; then
	 echo "already generate $OUTBAM"
	 exit
 fi
 if [ ! -f $OUTFILE ]; then  
  gsnap -t $THREADCOUNT -s splicesites -D genome --gunzip \
  -d candida_lusitaniae --read-group-id=$PREFIX --read-group-name=$SAMPINFO \
  -A sam $READS > $OUTFILE
 # | samtools sort -o $OUTFILE -O bam -
 fi

done
