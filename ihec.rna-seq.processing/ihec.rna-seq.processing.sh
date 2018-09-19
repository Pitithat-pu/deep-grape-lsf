name="ihec.rna-seq.processing.sh"


wrapper_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
grapeScript=${wrapper_DIR}/ihec.rna-seq.processing/ihec.rna-seq.grape-nf.sh
trimScript=${wrapper_DIR}/ihec.rna-seq.processing/trim_galore_array.sh
TMPDIR=/icgc/dkfzlsdf/analysis/G200/puranach/temp_IHEC_DEEP
adapter=""
extraOptions=""
extraTrimOptions=""

printHelp(){

  echo -e "" >&2
  echo -e "Trim reads and process them with the IHEC pipeline (grape-nf)." >&2
  echo -e "" >&2
  echo -e "Usage: $name <options>" >&2
  echo -e "" >&2
  echo -e " Mandatory options:" >&2
  echo -e "  -i DIR\tinput folder containing (illumina-named) reads" >&2
  echo -e "  -n STR\tsample name"
  echo -e "  -o DIR\toutput folder" >&2
  echo -e "" >&2
  echo -e "  Reference option" >&2
  echo -e "   -s STR\tSpecies, valid short-cuts: hs38, hs37, mm10" >&2
  echo -e "   OR" >&2
  echo -e "   -g FILE\tfasta file containing the reference genome" >&2
  echo -e "   -r REF\tSTAR reference genome index" >&2
  echo -e "   -t FILE\tGTF file with transcript annotation" >&2
  echo -e "" >&2
  echo -e " Optional options" >&2
  echo -e "  -a STR\talternative adapter sequence, overriding Trim_galore's" >&2
  echo -e "        \t autodetection" >&2
  echo -e "" >&2

}

while getopts "i:n:o:s:g:r:t:a:h" opt; do
  case "$opt" in
    i) inputFolder="$OPTARG" ;;
    n) sampleName="$OPTARG" ;;
    o) outputFolder="$OPTARG" ;;
    s)
      case "$OPTARG" in
        hs38)
          genomeFasta=/icgc/dkfzlsdf/analysis/G200/puranach/IHEC_DEEP/reference_genome/hs38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
          genomeIndex=/icgc/dkfzlsdf/analysis/G200/puranach/IHEC_DEEP/reference_genome/hs38
          transcriptAnnotation=/icgc/dkfzlsdf/analysis/G200/puranach/IHEC_DEEP/reference_genome/hs38/annotation/gencode.v28.annotation.gtf
          extraOptions="$extraOptions --wig-ref-prefix -" # reference genome doesn't have chr prefix
        ;;
        mm10)
          genomeFasta=/icgc/dkfzlsdf/analysis/G200/puranach/IHEC_DEEP/reference_genome/mm10/GRCm38mm10.fa
          genomeIndex=/icgc/dkfzlsdf/analysis/G200/puranach/IHEC_DEEP/reference_genome/mm10
          transcriptAnnotation=/icgc/dkfzlsdf/analysis/G200/puranach/IHEC_DEEP/reference_genome/mm10/annotation/gencode.vM12.annotation_plain.w_GeneTranscriptID_MT_v2.gtf
          extraOptions="$extraOptions --wig-ref-prefix -"  # reference genome doesn't have chr prefix
        ;;
        *)
          echo -e "ERROR: $(date) ($name): $OPTARG not yet a supported species" >&2
          printHelp
          exit 1
        ;;
      esac
    ;;
    g) genomeFasta="$OPTARG" ;;
    r) genomeIndex="$OPTARG" ;;
    t) transcriptAnnotation="$OPTARG" ;;
    a) extraTrimOptions="$extraTrimOptions -a $OPTARG" ;;
    h) printHelp; exit 0 ;;
    *) printHelp; exit 1 ;;
  esac
done

#check that all mandatory variables are set
if [[ -z ${inputFolder+x} ]] || [[ -z ${outputFolder+x} ]] || \
    [[ -z ${genomeFasta+x} ]] || [[ -z ${genomeIndex+x} ]] || \
    [[ -z ${transcriptAnnotation+x} ]] || [[ -z ${sampleName+x} ]]; then
  echo -e "ERROR: $(date) ($name): all mandatory options must be set" >&2
  printHelp
  exit 1
fi
#make sure we have full paths everywhere
inputFolder=$(readlink -m $inputFolder)
outputFolder=$(readlink -m $outputFolder)
genomeFasta=$(readlink -m $genomeFasta)
genomeIndex=$(readlink -m $genomeIndex)
transcriptAnnotation=$(readlink -m $transcriptAnnotation)
mkdir -p $TMPDIR
TMPWD=$(mktemp -d --tmpdir=$TMPDIR $sampleName.XXXXXXXX)

if [ -d "$outputFolder/log" ]; then rm -Rf $outputFolder/log; fi ## Clear log files
mkdir -p $outputFolder/log

#trimmed data
mkdir -p $TMPWD/trimmed

job_arraydepend=""

for RunID in $inputFolder/run*; do   
	if [ -d "$RunID" ];then
		RUNDIR=$RunID/sequence/  
		#echo "$RUNDIR"
		mkdir -p $TMPWD/trimmed/$(basename $RunID)
		N_lanes=`find $RUNDIR -name "*_R1*q.gz" |wc -l`
		#echo "job_array_id=\`echo \" $trimScript $RUNDIR $TMPWD/trimmed/$(basename $RunID) \"| qsub -N trim.$(basename $TMPWD) -t 1-${N_lanes} -o $outputFolder/log/ | cut -d '.' -f 1\`" > $outputFolder/jobs.sh 
		#job_array_id=`echo " $trimScript $RUNDIR $TMPWD/trimmed/$(basename $RunID) "| qsub -N trim.$(basename $TMPWD) -t 1-${N_lanes} -l walltime=36:00:00 -o $outputFolder/log/ | cut -d '.' -f 1`
		#job_arraydepend=$job_arraydepend" -W depend=afterokarray:$job_array_id"

		echo "job_array_id=\`echo \" $trimScript $RUNDIR $TMPWD/trimmed/$(basename $RunID) \"| bsub -J trim.$(basename $TMPWD)[1-${N_lanes}] -oo $outputFolder/log/ | head -n1 | cut -d'<' -f2 | cut -d'>' -f1\`" > $outputFolder/jobs.sh
		job_array_id=`echo " $trimScript $RUNDIR $TMPWD/trimmed/$(basename $RunID) "| bsub -J trim.$(basename $TMPWD)[1-${N_lanes}] -W 36:00 -oo $outputFolder/log/ | head -n1 | cut -d'<' -f2 | cut -d'>' -f1`
		#echo ${job_array_id}
		job_arraydepend="${job_arraydepend}done(${job_array_id})"

	fi 
done

job_arraydepend=$(echo ${job_arraydepend} | sed 's/)done/) \&\& done/')

echo "echo \"module load anaconda3/5.1.0; $grapeScript $sampleName $TMPWD $TMPWD/trimmed $genomeFasta $genomeIndex $transcriptAnnotation $outputFolder \"$extraOptions\" \" | bsub -W 300:00  -M 40GB -w \"$job_arraydepend\" -J grape.$(basename $TMPWD) -oo $outputFolder/log/ " >> $outputFolder/jobs.sh

echo "module load anaconda3/5.1.0; $grapeScript $sampleName $TMPWD $TMPWD/trimmed $genomeFasta $genomeIndex $transcriptAnnotation $outputFolder \"$extraOptions\" " | bsub -W 300:00  -M 40GB -w $job_arraydepend -J grape.$(basename $TMPWD) -oo $outputFolder/log/


echo -e "LOGG ($(date)) $name: Jobs submitted" >&2
