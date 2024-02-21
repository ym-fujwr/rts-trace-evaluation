#!/bin/bash
HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"

subN=NuProcess
for i in {31..50}; do
    revN="rev_$i"
    python3 getSelectedTestByEkstazi.py $EKSTAZI_DIR/$subN/$revN/testList.txt $EKSTAZI_DIR/$subN/$revN/testNum.txt $EKSTAZI_DIR/$subN/$revN/selectedTest.txt
done
