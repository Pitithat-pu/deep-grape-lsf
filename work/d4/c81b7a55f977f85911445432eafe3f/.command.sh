#!/bin/bash -eu
samtools view -h -@ 1 test1_m4_n10_toGenome.bam   | awk '
      BEGIN {OFS="\t"} 
      {if ($1!~/^@/ && and($2,64)>0) {$2=xor($2,0x10)}; print}
    '   | samtools view -Sbu -   | bamtools filter -tag NH:1   | tee >(
      genomeCoverageBed -strand + -split -bg -ibam -       > sample1.contigs.plusRaw.bedgraph
    )   | genomeCoverageBed -strand - -split -bg -ibam - > sample1.contigs.minusRaw.bedgraph

contigsNew.py --chrFile genome.fa.fai               --fileP sample1.contigs.plusRaw.bedgraph               --fileM sample1.contigs.minusRaw.bedgraph 							--sortOut 							> sample1.contigs.bed
