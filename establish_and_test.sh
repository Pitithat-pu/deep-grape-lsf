conda create -n grape-nf3 star=2.4.0j \
samtools=1.2.rglab rsem=1.2.21 rseqc=2.6.4 \
bedtools=2.19.1 bamtools=2.3.0 \
ucsc-bedgraphtobigwig=357 ucsc-genepredtobed=357 ucsc-gtftogenepred=357 nextflow

source activate grape-nf3
nextflow pull guigolab/grape-nf

nextflow run -without-docker -w work grape-nf --index /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/test-index.txt \
--genome /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/genome.fa \
--annotation /home/puranach/envs/grape-nf3/share/nextflow/assets/guigolab/grape-nf/data/annotation.gtf


