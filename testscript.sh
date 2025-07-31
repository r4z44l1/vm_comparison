#!/bin/bash

OUTDIR="benchmarks_$(hostname)_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

OUTFILE="$OUTDIR/results.txt"
runs=1
duration="5s"  # Dauer für alle Tests

echo "Starte Benchmark mit festen Methoden ($runs Durchläufe pro Test, Dauer je Test: $duration)" | tee "$OUTFILE"
echo "Ergebnisse werden in $OUTFILE gespeichert" | tee -a "$OUTFILE"
echo "----------------------------------------" >> "$OUTFILE"

for ((i=1; i<=runs; i++)); do
    echo "=== Run $i/$runs: CPU-Test (cpu-method: default) ===" | tee -a "$OUTFILE"
    stress-ng --cpu 1 --timeout $duration --metrics-brief >> "$OUTFILE" 2>&1
    echo "" >> "$OUTFILE"

    echo "=== Run $i/$runs: RAM-Test (vm-method: write64) ===" | tee -a "$OUTFILE"
    stress-ng --vm 1 --vm-bytes 50% --vm-method write64 --timeout $duration --metrics-brief >> "$OUTFILE" 2>&1
    echo "" >> "$OUTFILE"

    echo "=== Run $i/$runs: Disk I/O Test (fio: randrw, 4k blocks) ===" | tee -a "$OUTFILE"
    fio --name=randrw --ioengine=libaio --rw=randrw --bs=4k --size=512M \
        --numjobs=1 --runtime=$duration --time_based --group_reporting >> "$OUTFILE" 2>&1
    echo "" >> "$OUTFILE"

    echo "=== Run $i/$runs: Fork-Test (Standard fork) ===" | tee -a "$OUTFILE"
    stress-ng --fork 4 --timeout $duration --metrics-brief >> "$OUTFILE" 2>&1
    echo "" >> "$OUTFILE"

    echo "--- Run $i abgeschlossen ---" | tee -a "$OUTFILE"
    echo "" >> "$OUTFILE"
done

echo "Alle Tests abgeschlossen. Ergebnisse gespeichert in: $OUTFILE" | tee -a "$OUTFILE"
