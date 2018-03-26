conda create -n grape-nf3 star=2.4.0j \
samtools=1.2.rglab rsem=1.2.21 rseqc=2.6.4 \
bedtools=2.19.1 bamtools=2.3.0 \
ucsc-bedgraphtobigwig=357 ucsc-genepredtobed=357 ucsc-gtftogenepred=357 nextflow

source activate grape-nf3
nextflow pull guigolab/grape-nf

unset $PYTHONHOME

nextflow run -without-docker -w work grape-nf --index /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/test-index.txt \
--genome /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/genome.fa \
--annotation /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/annotation.gtf

N E X T F L O W  ~  version 0.28.0
##Launching `guigolab/grape-nf` [elated_shockley] - revision: 75ffd8da0a [master]
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
##Output files db -> /abi/data/puranach/packages/test_grapenf3/work/pipeline.db
##===============
##
##[warm up] executor > local
##[e9/cac669] Submitted process > t_index (genome-RSEM-1.2.21)
##[06/36c5e2] Submitted process > fastaIndex (genome-SAMtools-0.1.19)
##[e1/9581fc] Submitted process > index (genome-STAR-2.4.0j)
##[a8/121b6c] Submitted process > mapping (test1-STAR-2.4.0j)
##[5a/a1bbbf] Submitted process > inferExp (test1-RSeQC-2.3.9)
##[da/9211ae] Submitted process > quantification (test1-RSEM-1.2.21)
##[c1/f6ef78] Submitted process > contig (test1-RGCRG-0.1)
##[ad/88023d] Submitted process > bigwig (test1-STAR-2.4.0j)
##[da/9211ae] NOTE: Process `quantification (test1-RSEM-1.2.21)` terminated with an error exit status (127) -- Error is ignored
##
##-----------------------
##Pipeline run completed.
##-----------------------
##
