#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: convertImages imageFile.pdf folder_for_images"
	exit -1
fi

if [ ! -e $1 ]; then
	echo "PDF ($1) does not exist."
	exit -1
fi

if [ ! -d $2 ]; then
  # directory doesn't exist, so we should create it
  mkdir $2
fi

pdfimages -j $1 $2/image

