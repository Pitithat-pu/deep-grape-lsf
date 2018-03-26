#!/bin/bash -eu
mkdir genomeDir
STAR --runThreadN 1 		 --runMode genomeGenerate 		 --genomeDir genomeDir 		 --genomeFastaFiles genome.fa 		 --sjdbGTFfile annotation.gtf 		 --sjdbOverhang 100
