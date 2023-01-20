#!/usr/bin/bash

#replace YOUR_PATH_HERE, with the directory you want your csv file in
path_for_csv='YOUR_PATH_HERE'
path_to_files='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'
number_of_files=$(find $path_to_files -type f | wc -l)

#gets you a csv file with index, Size and Name, the seperator is ","
cd $path_to_files
ls -lha | tail -n $number_of_files | awk -v i=0 '{print i,",",$5,",",$9; i++;}' >> overview.csv
mv overview.csv $path_for_csv