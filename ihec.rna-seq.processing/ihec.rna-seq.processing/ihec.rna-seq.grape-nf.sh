#$ -cwd
#$ -S /bin/bash
#$ -V
#$ -j y
#$ -l mem_free=200G
#$ -l h_vmem=200G
#$ -l walltime=72:00:00
#module load python/2.7.9; 
source activate grape-nf3
unset PYTHONHOME
#grapeInstallation=$1
sampleName=$1
TMPWD=$2
trimmedFolder=$3
genomeFasta=$4
genomeIndex=$5
transcriptAnnotation=$6
outputFolder=$7
extraOptions=$8

#all fileIDs and file names must be unique ==> flatten folder structure
# this construct will move everything in folders to the main folder

#for RunID in $trimmedFolder/run*; do
#        if [ -d "$RunID" ];then
#		pushd $RunID
#		find . -name "*.fq.gz" \
#    			| xargs -l dirname \
#    			| sed -e "s/^.\///" \
#    			| sort -u \
#    			| while read folder; do
#        			prefix=$(echo $folder | sed -e "s/\//_/g")
#        			for s in $folder/*.fq.gz; do
#          				if [[ -e ${prefix}_$(basename $s) ]]; then
#            				  #this should very rarely happen
#            					mv $s $(mktemp -u ${prefix}_XXX_$(basename $s))
#          				else
#            					mv $s ${prefix}_$(basename $s)
#					fi
#        			done
#      			done
#	fi
#done

#pushd $trimmedFolder
#find . -mindepth 2 -name "*.fq.gz" \
#    | xargs -l dirname \
#    | sed -e "s/^.\///" \
#    | sort -u \
#    | while read folder; do
#        prefix=$(echo $folder | sed -e "s/\//_/g")
#        for s in $folder/*.fq.gz; do
#          if [[ -e ${prefix}_$(basename $s) ]]; then
#            #this should very rarely happen
#            mv $s $(mktemp -u ${prefix}_XXX_$(basename $s))
#          else
#            mv $s ${prefix}_$(basename $s)
#          fi
#        done
#      done
  #remove folders? not necessary
#  find . -maxdepth 1 -mindepth 1  -type d \
#    | xargs rm -r

popd &> /dev/null




### Concatenate fastq from multiple lane
for RunID in $trimmedFolder/run*; do
        if [ -d "$RunID" ];then
                N_lanes=`find $RunID -name "*L0[0-9][0-9]_R1*q.gz" |wc -l`
                if [[ $N_lanes -eq 1 ]];then
                        continue ## This run is contained within one lane.
                fi
                newname_R1=$(find $RunID -name "*L0[0-9][0-9]_R1*q.gz" | head -n1 \
                                | sed -e 's/\(.*\)\/\(.*_[A-Za-z0-9]\{2,12\}\)_\(L0[0-9][0-9]\)_\(.*\).fq.gz/\1\/\2\_MergedLanes\_\4\.fq.gz/g')
                newname_R2=$(find $RunID -name "*L0[0-9][0-9]_R2*q.gz" | head -n1 \
                                | sed -e 's/\(.*\)\/\(.*_[A-Za-z0-9]\{2,12\}\)_\(L0[0-9][0-9]\)_\(.*\).fq.gz/\1\/\2\_MergedLanes\_\4\.fq.gz/g')
                echo "Concatenating fastq files"
                cat $RunID/*L0[0-9][0-9]_R1*q.gz > $newname_R1
                cat $RunID/*L0[0-9][0-9]_R2*q.gz > $newname_R2
        	echo "Done : concatenating fastq files"
	fi
done


#generate input (index) file
if [ -f $outputFolder/readIndex.tsv ] ; then
    rm $outputFolder/readIndex.tsv
fi

for RunID in $trimmedFolder/run*; do
        if [ -d "$RunID" ];then
		N_Mergedfiles=`find $RunID -name "*_MergedLanes_*fq.gz" | wc -l`
		if [[ $N_Mergedfiles -eq 2 ]]; then
			lanetext="MergedLanes"
		else
			lanetext="L0[0-9][0-9]"
  		fi 
                find $RunID -name "*_$lanetext*.fq.gz" | sed -e 's/\(.*\)\/\(.*_[A-Za-z0-9]\{2,12\}_'${lanetext}'\)_R\([12]\)\(_[0-9]\{3\}\|_complete_filtered\|\)_\(.*\).fq.gz/\5 \2\4 \0 fastq FqRd\3/g' \
  		     | awk -v name=$sampleName -v folder=$RunID '
      			$1~/trimmed/ {$5="FqRd"}
      			{
        		  $1=name
        		  NF=5
        		  print
      			}
    		      '  | awk -v runid=$(basename $RunID) 'BEGIN{OFS="\t"} {print $1,runid,$3,$4,$5}'\
                  >> $outputFolder/readIndex.tsv
	
	fi
done



#sampleID fileID path "fastq" "FqRd{"",1,2}"
#find $trimmedFolder -name "*.fq.gz" \
#  | sed -e 's/\(.*\)\/\(.*_[ATGCN]\{4,12\}_L00[0-9]\)_R\([12]\)_\([0-9]\{3\}\|complete_filtered\)_\(.*\).fq.gz/\5 \2_\4 \0 fastq FqRd\3/g' \
#  | awk -v name=$sampleName -v folder=$trimmedFolder '
#      $1~/trimmed/ {$5="FqRd"}
#      {
#        $1=name
#        NF=5
#        print
#      }
#    '  | awk 'BEGIN{OFS="\t"} {print $1,$2,$3,$4,$5}'\
#> $outputFolder/readIndex.tsv



#grapeInstallation=/home/wangq/.nextflow/assets/guigolab/grape-nf/bin
#source $grapeInstallation
#module load java/1.8.0_40

module load java/1.8.0_131
  echo -e "LOGG ($(date)) $name: Enter work folder" >&2
  pushd $outputFolder
    nextflow run -without-docker -w $outputFolder/work grape-nf --index $outputFolder/readIndex.tsv --genome $genomeFasta --annotation $transcriptAnnotation --steps mapping,bigwig,quantification --genomeIndex $genomeIndex $extraOptions || exit 8
    awk '{print $3}' pipeline.db
    #mv $(awk '{print $3}' pipeline.db) $outputFolder
    #rm -r $outputFolder/work

  popd &> /dev/null


source deactivate


#cleanup read folder
rm -rf $TMPWD
