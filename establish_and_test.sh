conda create -n grape-nf3 star=2.4.0j \
samtools=1.2.rglab rsem=1.2.21 rseqc=2.6.4 \
bedtools=2.19.1 bamtools=2.3.0 \
ucsc-bedgraphtobigwig=357 ucsc-genepredtobed=357 ucsc-gtftogenepred=357 nextflow

source activate grape-nf3
nextflow pull guigolab/grape-nf

unset PYTHONHOME

nextflow run -without-docker -w work grape-nf --index /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/test-index.txt \
--genome /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/genome.fa \
--annotation /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/annotation.gtf

#N E X T F L O W  ~  version 0.28.0

##Launching `guigolab/grape-nf` [zen_edison] - revision: 75ffd8da0a [master]
##
##G R A P E ~ RNA-seq Pipeline
##
##General parameters
##------------------
##Index file                      : /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/test-index.txt
##Genome                          : /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/genome.fa
##Annotation                      : /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/annotation.gtf
##Pipeline steps                  : mapping bigwig contig quantification
##
##Mapping parameters
##------------------
##Tool                            : STAR 2.4.0j
##Max mismatches                  : 4
##Max multimaps                   : 10
##
##Bigwig parameters
##-----------------
##Tool                            : STAR 2.4.0j
##References prefix               : chr
##
##Quantification parameters
##-------------------------
##Tool                            : RSEM 1.2.21
##Mode                            : Transcriptome
##
##Execution information
##---------------------
##Engine                          : local
##Use Docker                      : false
##Error strategy                  : ignore
##
##Dataset information
##-------------------
##Number of sequenced samples     : 1
##Number of sequencing runs       : 1
##Merging                         : none
##
##===============
##Output files db -> /abi/data/puranach/packages/test_grape/pipeline.db
##===============
##
##[warm up] executor > local
##[08/df89c9] Submitted process > index (genome-STAR-2.4.0j)
##[d1/52dfd2] Submitted process > fastaIndex (genome-SAMtools-0.1.19)
##[57/cff50d] Submitted process > t_index (genome-RSEM-1.2.21)
##[58/69dc3a] Submitted process > mapping (test1-STAR-2.4.0j)
##[be/aedb4b] Submitted process > inferExp (test1-RSeQC-2.3.9)
##[85/aa6c51] Submitted process > contig (test1-RGCRG-0.1)
##[d2/273a66] Submitted process > quantification (test1-RSEM-1.2.21)
##[7a/738678] Submitted process > bigwig (test1-STAR-2.4.0j)
##[d2/273a66] NOTE: Process `quantification (test1-RSEM-1.2.21)` terminated with an error exit status (127) -- Error is ignored
##
##-----------------------
##Pipeline run completed.
##-----------------------
##
