#!/bin/bash

DIR=$1
NTHREADS=$2 

if [ -z $1 ] ; 
then
  	echo "USAGE: DIR_PATH N-THREADS [RESULTS?]"
	exit
fi

PWD=`pwd`
echo $PWD
echo
LIB_DIR=$PWD/target

#
# SET THESE ELEMENTS HERE AND UNCOMMENT THE FOLLOWING WHEN RUNNING THIS SCRIPT 
#
# 1. git clone https://github.com/spyysalo/nxml2txt
#NXML2TXT_PATH=/path/to/locally/installed/nxml2txt
#NXML2TXT_PATH=/Users/Gully/Coding/pyDev-workspace/nxml2txt/nxml2txt

# COMMENT OUT THIS SECTION TO RUN THIS SCRIPT 
echo "PLEASE EDIT THIS runPipeline.sh SCRIPT TO SET PATHS TO NXML2TXT"
exit 

if [ ! -d $DIR/nxml2txt ];
then 

	echo
	echo "RUNNING: java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar edu.isi.bmkeg.uimaBioC.bin.UIMABIOC_01_SimpleRunNxml2Txt -inDir $DIR/nxml -outDir $DIR/nxml2txt -execPath $NXML2TXT_PATH"
	echo 

	java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar \
		edu.isi.bmkeg.uimaBioC.bin.UIMABIOC_01_SimpleRunNxml2Txt \
		-inDir $DIR/nxml \
		-outDir $DIR/nxml2txt \
		-execPath $NXML2TXT_PATH
fi

if [ ! -d $DIR/bioc ];
then
	
	echo
	echo "RUNNING: java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar edu.isi.bmkeg.uimaBioC.bin.UIMABIOC_02_Nxml2txt_to_BioC -inDir $DIR/nxml2txt -outDir $DIR/bioc -outFormat json"
	echo
	
	java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar \
		edu.isi.bmkeg.uimaBioC.bin.UIMABIOC_02_Nxml2txt_to_BioC \
		-inDir $DIR/nxml2txt \
		-outDir $DIR/bioc \
		-outFormat json
fi

if [ ! -d $DIR/preprocessed_bioc_results ];
then
	
	echo "RUNNING: java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar -Xmx4G edu.isi.bmkeg.sciDP.bin.SciDP_01_preprocessToBioC -biocDir $DIR/bioc -friesDir $DIR/fries -outDir $DIR/preprocessed_bioc_results -clauseLevel -maxSentenceLength 500  -nThreads $NTHREADS -outFormat json -ann2Extract \"^[Rr]esult\""

	java -Xmx4G -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar \
               edu.isi.bmkeg.sciDP.bin.SciDP_01_preprocessToBioC \
               -biocDir $DIR/bioc \
               -outDir $DIR/preprocessed_bioc_results \
               -clauseLevel \
               -maxSentenceLength 500  \
               -nThreads $NTHREADS \
               -outFormat json \
               -ann2Extract "^[Rr]esult"
fi

if [ ! -d $DIR/tsv_results ];
then            

	echo 'java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar edu.isi.bmkeg.sciDP.bin.SciDP_02_BioCToTsv -biocDir $DIR/preprocessed_bioc_results -nThreads 1 -outDir $DIR/tsv_results -ann2Extract \"^[Rr]esult\"'

	java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar \
				edu.isi.bmkeg.sciDP.bin.SciDP_02_BioCToTsv \
                -biocDir $DIR/preprocessed_bioc_results \
                -nThreads 1 \
                -outDir $DIR/tsv_results\
                -ann2Extract "^[Rr]esult"
fi

if [ ! -d $DIR/disSeg_input_results ];
then

	echo 'java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar edu.isi.bmkeg.sciDP.bin.SciDP_03_prepareData -biocDir $DIR/preprocessed_bioc_results -nThreads 1 -outDir $DIR/disSeg_input_results'

	java -cp $LIB_DIR/sciDP-preprocessing-0.1.1-jar-with-dependencies.jar \
        		edu.isi.bmkeg.sciDP.bin.SciDP_03_prepareData \
                -biocDir $DIR/preprocessed_bioc_results \
                -nThreads 1 \
                -outDir $DIR/disSeg_input_results
fi