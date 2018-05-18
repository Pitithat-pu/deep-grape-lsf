# deep-grape

Tested in DKFZ Cluster environment on 17 May 2018
Prerequisite
1. Python 2.7.9 (module load python/2.7.9 in dkfz_cluster)
2. conda (included in module load python/2.7.9 in dkfz_cluster)
3. TrimGalore
4. cutadapt (TrimGalore prerequisite)


Installation
1. Brief installation instruction are contained in establish_and_test.sh. Please module load python/2.7.9 before running the script
2. In detail 
   
   2.0 In DKFZ cluster environment
        module load python/2.7.9

   2.1 install and configure bioconda (https://bioconda.github.io)
   
        conda config --add channels defaults
        conda config --add channels conda-forge
        conda config --add channels bioconda

   2.2 create working environment grape-nf3
   
       conda create -n grape-nf3 star=2.4.0j \
         samtools=1.2.rglab rsem=1.2.21 rseqc=2.6.4 \
         bedtools=2.19.1 bamtools=2.3.0 \
         ucsc-bedgraphtobigwig=357 ucsc-genepredtobed=357 ucsc-gtftogenepred=357 nextflow

   2.3 activate the environment
   
       conda activate grape-nf3
       nextflow pull guigolab/grape-nf
       unset PYTHONHOME  ## unset PYTHONHOME given by the module load python

   2.4 test if the setup is right
   
       nextflow run -without-docker -w work grape-nf --index \
       ~/.nextflow/assets/guigolab/grape-nf/test-index.txt \
       --genome ~/.nextflow/assets/guigolab/grape-nf/data/genome.fa \
       --annotation ~/.nextflow/assets/guigolab/grape-nf/data/annotation.gtf

Instruction
1. In DEEP_metadata.csv, write down information about the input data (e.g.datatype, sampleID) in tab-separated format. 
2. Run script ./ihec.rna-seq.processing/call_rna_seq_processing.sh DEEP_metadata.csv to start.

