#!/usr/bin/bash

#replace YOUR_PATH_HERE, with the directory you want your csv file in
# $2
path_for_csv='/data/scratch/manuez42/overview/'

# $ path_to_files='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'


# $1
files0='/data/scratch/manuez42/genomes/viral_500M/files/'
files1='/data/scratch/manuez42/genomes/archaea_1,4G/files/'
files2='/data/scratch/manuez42/genomes/human_9G/files/'
files3='/data/scratch/manuez42/genomes/bacteria_30G/files/'
files4='/data/scratch/manuez42/genomes/bacteria_58G/files/'
files5='/data/scratch/manuez42/genomes/bacteria_88G/files/'
files6='/data/scratch/manuez42/genomes/bacteria_125G/files/'


# $2
output0='viral_overview.tsv'
output1='archea_overview.tsv'
output2='human_overview.tsv'
output3='bacteria_30_overview.tsv'
output4='bacteria_58_overview.tsv'
output5='bacteria_88_overview.tsv'
output6='bacteria_125_overview.tsv'


get_new(){
    number_of_files=$(find $1 -type f | wc -l)

    #gets you a csv file with index, Size and Name, the seperator is ","
    cd $1
    ls -lha | tail -n $number_of_files | awk -v i=0 '{print i,"\t",$5,"\t",$9; i++;}' >> $2
    mv $2 $path_for_csv
}


get_new $files0 $output0
get_new $files1 $output1
get_new $files2 $output2
get_new $files3 $output3
get_new $files4 $output4
get_new $files5 $output5
get_new $files6 $output6