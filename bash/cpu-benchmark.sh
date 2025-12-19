#!/bin/bash

columns="x, y, time (ms)"
echo "$columns" >> ../results/cpu-timings.csv

for N in 512 1024 2048 4096 8192; do
    ../build/cpu-bench --x="$N" --y="$N" --runs=20 >> ../results/cpu-timings.csv
done
