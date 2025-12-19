#!/bin/bash

columns="x, y, time (ms)"
echo "$columns" >> ../results/timings.csv

for N in 512 1024 2048 4096 8192 16384 32768; do
    ../build/bench --x="$N" --y="$N" --runs=20 >> ../results/timings.csv
done
