#!/bin/bash

# A temporary file to store previous CPU stats
PREV_STATS_FILE="/tmp/waybar_per_core_prev.dat"

# Read previous stats if the file exists
if [ -f "$PREV_STATS_FILE" ]; then
    PREV_STATS=($(cat "$PREV_STATS_FILE"))
else
    PREV_STATS=()
fi

# Read current stats from /proc/stat, filtering for CPU cores (lines starting with 'cpu' followed by a number)
CURRENT_STATS=($(grep -E '^cpu[0-9]+' /proc/stat | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}'))

# Save current stats for the next run
echo "${CURRENT_STATS[@]}" > "$PREV_STATS_FILE"

# If we don't have previous stats, we can't calculate usage yet.
if [ ${#PREV_STATS[@]} -eq 0 ]; then
    echo "{\"text\": \"Cores: Calculating...\"}"
    exit 0
fi

output=""
core_index=0
i=0
while [ $i -lt ${#CURRENT_STATS[@]} ]; do
    # Current stats for this core
    cpu_label=${CURRENT_STATS[i]}
    user=${CURRENT_STATS[i+1]}
    nice=${CURRENT_STATS[i+2]}
    system=${CURRENT_STATS[i+3]}
    idle=${CURRENT_STATS[i+4]}
    iowait=${CURRENT_STATS[i+5]}
    irq=${CURRENT_STATS[i+6]}
    softirq=${CURRENT_STATS[i+7]}

    # Previous stats for this core
    prev_user=${PREV_STATS[i+1]}
    prev_nice=${PREV_STATS[i+2]}
    prev_system=${PREV_STATS[i+3]}
    prev_idle=${PREV_STATS[i+4]}
    prev_iowait=${PREV_STATS[i+5]}
    prev_irq=${PREV_STATS[i+6]}
    prev_softirq=${PREV_STATS[i+7]}

    # Calculate total and idle times
    PrevIdle=$((prev_idle + prev_iowait))
    Idle=$((idle + iowait))
    
    PrevNonIdle=$((prev_user + prev_nice + prev_system + prev_irq + prev_softirq))
    NonIdle=$((user + nice + system + irq + softirq))

    PrevTotal=$((PrevIdle + PrevNonIdle))
    Total=$((Idle + NonIdle))

    # Calculate utilization
    totald=$((Total - PrevTotal))
    idled=$((Idle - PrevIdle))

    if [ $totald -eq 0 ]; then
      CPU_Percentage=0
    else
      CPU_Percentage=$((100 * (totald - idled) / totald))
    fi

    # Build the output string
    # You can customize this format!
    # output+="C${core_index}: ${CPU_Percentage}%  "
    output+="${CPU_Percentage}% "
    
    core_index=$((core_index + 1))
    i=$((i + 10)) # Each CPU line has 10 fields (cpuN + 9 values)
done

# Output in JSON format for Waybar's custom module
echo $output
