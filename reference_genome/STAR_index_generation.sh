#code to generate genome index
# need to be redone if we change to a different STAR version?
module load python/2.7.9
source activate grape-nf3
unset PYTHONHOME
## Config file reader
shopt -s extglob
echo "Reading Config file       : $1"
configfile=$1 # set the actual path name of your (DOS or Unix) config file
tr -d '\r' < $configfile > $configfile.unix
while IFS='= ' read lhs rhs
do
    if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"    # Del in line right comments
        rhs="${rhs%%*( )}"   # Del trailing spaces
        rhs="${rhs%\"*}"     # Del opening string quotes 
        rhs="${rhs#\"*}"     # Del closing string quotes 
        declare $lhs="$rhs"
    fi
done < $configfile.unix

echo "Reference genome version  : $reference_genome_version"
echo "Reference genome file     : $reference_genome_file"
echo "Reference genome dir      : $(dirname $reference_genome_file)"
echo "Gencode file              : $gene_model"
echo "sjOverHang 		: $sjOverHang"
echo "CPUS			: $cpus"


STAR --runThreadN ${cpus} --runMode genomeGenerate --genomeDir $(dirname $reference_genome_file) --genomeFastaFiles ${reference_genome_file} --sjdbGTFfile  ${gene_model}  --sjdbOverhang ${sjOverHang}
