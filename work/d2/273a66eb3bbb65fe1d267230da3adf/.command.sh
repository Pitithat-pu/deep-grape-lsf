#!/bin/bash -eu
samtools sort -@ 1 -ni -O sam -T . test1_m4_n10_toTranscriptome.bam   | rsem-calculate-expression --sam                           --estimate-rspd                            --calc-ci                           --no-bam-output                           --seed 12345                           -p 1                           --ci-memory 1024                           --paired-end                           --forward-prob 0                           -                           txDir/RSEMref                           sample1

rsem-plot-model sample1 sample1.pdf
