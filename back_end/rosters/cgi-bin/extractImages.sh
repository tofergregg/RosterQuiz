#!/bin/bash

if [ "$#" -ne 2 ]; then
            echo "Usage:"
            printf "\t./extractImages.sh pdf_file image_dir\n"
            exit -1
fi

# set up image directory

filename=$1
imageDir=$2

# create directory and empty it
mkdir ${imageDir} 2> /dev/null
rm ${imageDir}/* 2> /dev/null

# convert the images
./convertImages.sh ${filename} ${imageDir}

# there may be some .ppm files, so we convert them to .jpg
ppms=`ls ${imageDir}/*.ppm 2>/dev/null`
for p in $ppms; do
        jpg_name=${p%.*}.jpg
        /usr/sup/bin/convert $p $jpg_name
        rm $p
done

# extract the text from the pdf
pdftotext -layout ${filename} ${imageDir}/roster.txt

# parse the names
./parseNames.py ${imageDir}/roster.txt ${imageDir}

