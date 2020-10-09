#!/usr/bin/bash
#SBATCH --time 2:00:00 --mem 2G -p short

module load gmap/2019-09-12
cd genome
gmap_build -D=. -d candida_lusitaniae candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
gtf_splicesites < candida_lusitaniae_1_fixed.gtf | iit_store -o candida_lusitaniae/candida_lusitaniae.maps/splicesites.iit
gtf_introns < candida_lusitaniae_1_fixed.gtf | iit_store -o candida_lusitaniae/candida_lusitaniae.maps/introns.iit
