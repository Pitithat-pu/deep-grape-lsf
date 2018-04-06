name="ihec.rna-seq.processing.sh"

wrapper_DIR=/abi/data/puranach/IHEC-Deep/ihec.rna-seq.processing/

grapeScript=${wrapper_DIR}/ihec.rna-seq.processing/ihec.rna-seq.grape-nf.sh
trimScript=${wrapper_DIR}/ihec.rna-seq.processing/trim_galore_array.sh
TMPDIR=/abi/data/puranach/packages/DEEP_test/temp
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
          genomeFasta=/icgc/dkfzlsdf/dmg/otp/production/processing/reference_genomes/bwa06_hg38_CGA_000001405.15-no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
          genomeIndex=/icgc/dkfzlsdf/analysis/G200/wangq/DEEP_reference/hg19/STAR2
          transcriptAnnotation=/icgc/dkfzlsdf/analysis/G200/wangq/DEEP_reference/gencode.v22.annotation.201503031.gtf
          extraOptions="$extraOptions --wig-ref-prefix -" # reference genome doesn't have chr prefix
        ;;
        mm10)
          genomeFasta=/icgc/dkfzlsdf/dmg/otp/production/processing/reference_genomes/bwa06_GRCm38mm10/GRCm38mm10.fa
          genomeIndex=/icgc/dkfzlsdf/analysis/G200/wangq/DEEP_reference/mm10/STAR2
          transcriptAnnotation=/icgc/ngs_share/assemblies/mm10/databases/gencode/gencodeM12/gencode.vM12.annotation_plain.w_GeneTranscriptID_MT_v2.gtf
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

mkdir -p $outputFolder/log

#trim data
mkdir -p $TMPWD/trimmed

N_lanes=`find $inputFolder -name "*_R1_*q.gz" |wc -l`
echo "job_array_id=\`echo \" $trimScript $inputFolder $TMPWD/trimmed \"| qsub -N trim.$(basename $TMPWD) -t 1-${N_lanes} -o $outputFolder/log/ | cut -d '.' -f 1\`" > $outputFolder/jobs.sh

job_array_id=`echo " $trimScript $inputFolder $TMPWD/trimmed "| qsub -N trim.$(basename $TMPWD) -t 1-${N_lanes} -o $outputFolder/log/ | cut -d '.' -f 1`

echo "echo \"$grapeScript $sampleName $TMPWD $TMPWD/trimmed $genomeFasta $genomeIndex $transcriptAnnotation $outputFolder \"$extraOptions\" \" | qsub -W depend=afterokarray:${job_array_id} -N grape.$(basename $TMPWD) -o $outputFolder/log/ " >> $outputFolder/jobs.sh

echo "$grapeScript  $sampleName $TMPWD $TMPWD/trimmed $genomeFasta $genomeIndex $transcriptAnnotation $outputFolder $extraOptions" | qsub -l walltime=72:00:00,mem=200gb -q highmem -W depend=afterokarray:${job_array_id} -N grape.$(basename $TMPWD) -o $outputFolder/log/


#bash $outputFolder/jobs.sh

echo -e "LOGG ($(date)) $name: Jobs submitted" >&2
