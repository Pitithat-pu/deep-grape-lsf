#!/bin/bash -eu
mkdir txDir
rsem-prepare-reference --gtf annotation.gtf 											 genome.fa 											 txDir/RSEMref
