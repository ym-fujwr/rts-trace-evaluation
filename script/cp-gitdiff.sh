#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
RTS_TRACE_DIR="$HOME_DIR/rts-trace2"
ACC_DIR="$HOME_DIR/accuracy"

subN=jitwatch
for i in {2..50}; do
	revN="rev_$i"
    cp -f $RTS_TRACE_DIR/$subN/$revN/gitdiff.txt $ACC_DIR/$subN/$revN/
    # cp -f ../jitwatch/$revN/gitdiff.txt $ACC_DIR/$subN/$revN/
    # cp -f ../jitwatch/$revN/diff_time.txt ../rts-trace2/$subN/$revN/
done