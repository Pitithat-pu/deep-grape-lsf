referenceGenome=mm10
data_type=strand_specific_mrna_sequencing
DIR=/abi/data/puranach/packages/DEEP_test
mkdir -p ${DIR}/${data_type}

input_fasta_folder=/icgc/dkfzlsdf/project/DEEP/sequencing/${data_type}/view-by-pid/41_Hf01_LiHe_Ct/replicate1/paired/run131016_SN471_0153_A_D263EACXX/sequence
sampleName=41_Hf01_LiHe_Ct_replicate1

sampleID=41_Hf02_LiHe_Ct
runID=run140212_SN758_0152_BC3ETGACXX
replicate=replicate1
input_fasta_folder=/icgc/dkfzlsdf/project/DEEP/sequencing/${data_type}/view-by-pid/${sampleID}/${replicate}/paired/${runID}/sequence
sampleName=${sampleID}_${replicate}


out_DIR=${DIR}/${data_type}/${sampleName}

mkdir -p ${out_DIR}

SCRIPT_DIR=/abi/data/puranach/IHEC-Deep/ihec.rna-seq.processing
echo "${SCRIPT_DIR}/ihec.rna-seq.processing.sh -i ${input_fasta_folder} -n ${sampleName} -o ${out_DIR} -s ${referenceGenome}"


sh ${SCRIPT_DIR}/ihec.rna-seq.processing.sh -i ${input_fasta_folder} -n ${sampleName} -o ${out_DIR} -s ${referenceGenome}

