<<<<<<< HEAD
# deep-grape

Tested inside DKFZ Cluster environment on 26 June 2018
### Prerequisite
1. Python 2.7.9 (module load python/2.7.9 in dkfz_cluster)
2. conda (included when module load python/2.7.9 in dkfz_cluster)
3. TrimGalore
4. cutadapt (TrimGalore prerequisite)


### Installation
1. Brief installation instruction are contained in establish_and_test.sh. Please ```module load python/2.7.9``` before running the script
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
   
       source activate grape-nf3
       nextflow pull guigolab/grape-nf
       unset PYTHONHOME  ## unset PYTHONHOME given by the module load python

   2.4 test if the setup is right
       (please check for path to grape-nf installation)
	```
	nextflow run -without-docker -w work grape-nf --index \
            ~/.nextflow/assets/guigolab/grape-nf/test-index.txt \
            --genome ~/.nextflow/assets/guigolab/grape-nf/data/genome.fa \
            --annotation ~/.nextflow/assets/guigolab/grape-nf/data/annotation.gtf
	```
### Build reference genome index for STAR alignment
   1. Inside reference_genome directory, create/edit configuration file with parameters as shown in config_hg10.ini
   2. Execute STAR_index_generation.sh with the configuration file.
         ```
         ./STAR_index_generation.sh config_mm10.ini
         ```
   


### Instruction
1. In DEEP_metadata.csv, write down information about the input data (e.g.datatype, sampleID) in tab-separated format. 
   ```
       DeepFolder      datatype        sampleID        replicate       refererence_Genome
      /icgc/dkfzlsdf/project/DEEP/sequencing/	strand_specific_mrna_sequencing	41_Mm10_LiNP_OC	replicate1	mm10
      /icgc/dkfzlsdf/project/DEEP/sequencing/	strand_specific_mrna_sequencing	41_Hf11_LiNP_St	replicate1	hs38

   ```

2. Run script to start.
   ```./ihec.rna-seq.processing/call_rna_seq_processing.sh DEEP_metadata.csv``` 

=======
# deep-grape-lsf
Deep-grape RNA-seq workflow for LSF cluster
>>>>>>> 75b1242a98249cceed80fbdb9cd2b4bfc23d88f4
