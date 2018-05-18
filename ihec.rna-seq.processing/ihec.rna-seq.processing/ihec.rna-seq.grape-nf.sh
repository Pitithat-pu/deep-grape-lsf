#$ -cwd
#$ -S /bin/bash
#$ -V
#$ -j y
<<<<<<< HEAD
#$ -l mem_free=200G
#$ -l h_vmem=200G
#$ -l walltime=72:00:00
#module load python/2.7.9; 
source activate grape-nf3
unset PYTHONHOME
=======
#$ -l mem_free=67G
#$ -l h_vmem=67G

source activate grape-nf3

>>>>>>> f0c369ca52b9f6ac616f9a5cce1486536faaabcb
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

pushd $trimmedFolder
find . -mindepth 2 -name "*.fq.gz" \
    | xargs -l dirname \
    | sed -e "s/^.\///" \
    | sort -u \
    | while read folder; do
        prefix=$(echo $folder | sed -e "s/\//_/g")
        for s in $folder/*.fq.gz; do
          if [[ -e ${prefix}_$(basename $s) ]]; then
            #this should very rarely happen
            mv $s $(mktemp -u ${prefix}_XXX_$(basename $s))
          else
            mv $s ${prefix}_$(basename $s)
          fi
        done
      done
  #remove folders? not necessary
#  find . -maxdepth 1 -mindepth 1  -type d \
#    | xargs rm -r

popd &> /dev/null


#generate input (index) file

#sampleID fileID path "fastq" "FqRd{"",1,2}"
find $trimmedFolder -name "*.fq.gz" \
<<<<<<< HEAD
  | sed -e 's/\(.*\)\/\(.*_[ATGCN]\{4,12\}_L00[0-9]\)_R\([12]\)_\([0-9]\{3\}\|\(complete_filtered\)\)_\(.*\).fq.gz/\5 \2_\4 \0 fastq FqRd\3/g' \
=======
  | sed -e 's/\(.*\)\/\(.*_[ATGCN]\{4,12\}_L00[0-9]\)_R\([12]\)_\([0-9]\{3\}\)_\(.*\).fq.gz/\5 \2_\4 \0 fastq FqRd\3/g' \
>>>>>>> f0c369ca52b9f6ac616f9a5cce1486536faaabcb
  | awk -v name=$sampleName -v folder=$trimmedFolder '
      $1~/trimmed/ {$5="FqRd"}
      {
        $1=name
        NF=5
        print
      }
    '  | awk 'BEGIN{OFS="\t"} {print $1,$2,$3,$4,$5}'\
> $outputFolder/readIndex.tsv



#grapeInstallation=/home/wangq/.nextflow/assets/guigolab/grape-nf/bin
#source $grapeInstallation

module load java/1.8.0_40

  echo -e "LOGG ($(date)) $name: Enter work folder" >&2
  pushd $outputFolder
    nextflow run -without-docker -w $outputFolder/work grape-nf --index $outputFolder/readIndex.tsv --genome $genomeFasta --annotation $transcriptAnnotation --steps mapping,bigwig,quantification --genomeIndex $genomeIndex $extraOptions || exit 8
    awk '{print $3}' pipeline.db
    #mv $(awk '{print $3}' pipeline.db) $outputFolder
    #rm -r $outputFolder/work

  popd &> /dev/null


deactivate


#cleanup read folder
rm -rf $TMPWD
