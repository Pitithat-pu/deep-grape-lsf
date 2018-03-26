#!/bin/bash -eu
set -o pipefail

gtfToGenePred annotation.gtf -allErrors -ignoreGroupsWithoutExons annotation.genePred 2> annotation.genePred.err
genePredToBed annotation.genePred annotation.bed
grape_infer_experiment.py -i test1_m4_n10_toGenome.bam -r annotation.bed | tr -d '\n'
