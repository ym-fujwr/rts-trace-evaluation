#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
ACC_DIR="$HOME_DIR/accuracy"
ACC_SUB_DIR="$HOME_DIR/accuracy_sub"

subN=NuProcess
for i in {34..50}; do
	revN="rev_$i"
    j=$((i - 1))
    revP="rev_$j"
    cp -f $ACC_SUB_DIR/$subN/$revP/token/* $ACC_DIR/$subN/$revN/token/
done    