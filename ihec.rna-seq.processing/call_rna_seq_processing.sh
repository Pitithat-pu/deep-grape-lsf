set -e
#referenceGenome=hg38 #set default referenceGenome
#data_type=strand_specific_mrna_sequencing
DIR=/abi/data/puranach/packages/DEEP_test
#mkdir -p ${DIR}/${data_type}
SCRIPT_DIR=/abi/data/puranach/IHEC-Deep/ihec.rna-seq.processing
#sampleID=41_Mm10_LiNP_OC
#runID=run140805_SN758_0175_AC4HJWACXX
#replicate=replicate1
#input_fasta_folder=/icgc/dkfzlsdf/project/DEEP/sequencing/${data_type}/view-by-pid/${sampleID}/${replicate}/paired/${runID}/sequence
#sampleName=${sampleID}_${replicate}




sed 1d $1 | while IFS=$'\t' read -r -a metadata_table ; do
	deepfolder="${metadata_table[0]}"
	datatype="${metadata_table[1]}"
	sampleID="${metadata_table[2]}"
	replicate="${metadata_table[3]}"
	runID="${metadata_table[4]}"
	if [[ $(echo $sampleID | cut -f2 -d"_") = Hf* || $(echo $sampleID | cut -f2 -d"_") = Hm* ]] 
	then
        	referenceGenome="hs38"
	else
        	referenceGenome="mm10"
	fi

	input_fasta_folder=$deepfolder/${datatype}/view-by-pid/${sampleID}/${replicate}/paired/${runID}/sequence
	sampleName=${sampleID}_${replicate}
	mkdir -p ${DIR}/${data_type}
	out_DIR=${DIR}/${data_type}/${sampleName}
	mkdir -p ${out_DIR}
	echo "${SCRIPT_DIR}/ihec.rna-seq.processing.sh -i ${input_fasta_folder} -n ${sampleName} -o ${out_DIR} -s ${referenceGenome}" 
	sh ${SCRIPT_DIR}/ihec.rna-seq.processing.sh -i ${input_fasta_folder} -n ${sampleName} -o ${out_DIR} -s ${referenceGenome}

done



#if [[ $(echo $sampleID | cut -f2 -d"_") = Hf* || $(echo $sampleID | cut -f2 -d"_") = Hm* ]] 
#then
#	referenceGenome="hg38"
#else
#	referenceGenome="mm10"
#fi

#out_DIR=${DIR}/${data_type}/${sampleName}

#mkdir -p ${out_DIR}

#SCRIPT_DIR=/abi/data/puranach/IHEC-Deep/ihec.rna-seq.processing
#echo "${SCRIPT_DIR}/ihec.rna-seq.processing.sh -i ${input_fasta_folder} -n ${sampleName} -o ${out_DIR} -s ${referenceGenome}"


#sh ${SCRIPT_DIR}/ihec.rna-seq.processing.sh -i ${input_fasta_folder} -n ${sampleName} -o ${out_DIR} -s ${referenceGenome}

