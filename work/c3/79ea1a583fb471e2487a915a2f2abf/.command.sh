#!/bin/bash -eu
mkdir Signal
STAR --runThreadN 1      --runMode inputAlignmentsFromBAM      --inputBAMfile test1_m4_n10_toGenome.bam      --outWigType bedGraph      --outWigStrand Stranded      --outFileNamePrefix ./Signal/      --outWigReferencesPrefix chr

cp genome.fa.fai chrSizes.txt
if [[ chr != - ]]; then
    sed  -ni '/^chr/p' chrSizes.txt
fi

bedGraphToBigWig Signal/Signal.UniqueMultiple.str1.out.bg                  chrSizes.txt                  sample1.UniqueMultiple.minusRaw.bw 
bedGraphToBigWig Signal/Signal.UniqueMultiple.str2.out.bg                  chrSizes.txt                  sample1.UniqueMultiple.plusRaw.bw 

bedGraphToBigWig Signal/Signal.Unique.str1.out.bg                  chrSizes.txt                  sample1.Unique.minusRaw.bw
bedGraphToBigWig Signal/Signal.Unique.str2.out.bg                  chrSizes.txt                  sample1.Unique.plusRaw.bw
