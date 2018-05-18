module load python/2.7.9 # becuase it seem TrimGalore/cutadapy depends on this version of python, higher veresion reports error

name="trim_galore_array.sh"
trim_galore="trim_galore "
TEMP_DIR="/abi/data/puranach/packages/DEEP_test/temp"

clip5=0

inputRoot=$1
outputRoot=$2

echo "the input directory is ${inputRoot}"
echo "the output directory is ${outputRoot}"

if [[ -z "$inputRoot" ]] || [[ -z "$outputRoot" ]]
then
 echo -e ""
 echo -e "ERROR ($name): All mandatory options must be set"
 printHelp
 exit 1
fi

export TMPDIR=${TEMP_DIR}

# ls -lh $inputRoot

#submit with a command similar to this:

# qsub -t 1-`find $inputRoot -name "*_R1_*q.gz" |wc -l` -o log.txt trim_galore_array.sh $inputRoot $outputRoot

#tries to trim all files following the scheme: "*_R1_*q.gz". Applies paired end trimming if it is possible to substitute _R1_ with _R2_ and that file exists.

#get the file to work on, omitting the given prefix


pushd $inputRoot /dev/null
inputRoot=`pwd -P`

file1=$( find . -name "*_R1_*q.gz" |sort|head -n ${PBS_ARRAYID}|tail -n 1 |sed -e 's#\./##' )

popd > /dev/null

#create the output folder if it doesn't exist
mkdir -p $outputRoot
#get full path for outputRoot, this isn't necessary
pushd $outputRoot > /dev/null
outputRoot=`pwd -P`
#outputRoot=${outputRoot%/.}
popd > /dev/null
#create folder
outputFolder=$outputRoot/`dirname $file1`
outputFolder=${outputFolder%/.}
mkdir -p $outputFolder

#echo $outputFolder

#is there a second file?
file2=${file1/_R1_/_R2_}
echo "is there a second file?"
echo $inputRoot/$file1 $inputRoot/$file2

#TODO: develop error handling
if [ -f "$inputRoot/$file2" ]
then
 echo "paired"
 if [[ $clip5 -gt 0 ]]; then
  trim_galore="${trim_galore} --clip_R1 $clip5 --clip_R2 $clip5"
 fi
 if [[ ! -z "$adapter2" ]]; then
  trim_galore="${trim_galore} -a2 $adapter2"
 fi
 echo $trim_galore $extraOptions -q 20 --phred33 -o $outputFolder --no_report_file --paired $inputRoot/$file1 $inputRoot/$file2
 $trim_galore $extraOptions -q 20 --phred33 -o $outputFolder --no_report_file --paired $inputRoot/$file1 $inputRoot/$file2 || exit 1
else
 echo "singlet"
 if [[ $clip5 -gt 0 ]]; then
  trim_galore="${trim_galore} --clip_R1 $clip5"
 fi
 echo $trim_galore $extraOptions -q 20 --phred33 -o $outputFolder --no_report_file $inputRoot/$file1
 $trim_galore $extraOptions -q 20 --phred33 -o $outputFolder --no_report_file $inputRoot/$file1 || exit 1
fi
