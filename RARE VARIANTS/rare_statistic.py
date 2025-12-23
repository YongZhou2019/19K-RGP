import pandas as pd
from collections import defaultdict
import os
import time

# ===== Configuration =====
geno_file = "ultra_rare.1.genotype.txt"
group_file = "subpopulation.txt"
output_file = "ultra_rare.1.group_counts_ratios.tsv"
checkpoint_file = "ultra_rare.1.rareSNP.progress.log"
batch_size = 50000

# ===== Load Group Info =====
group_df = pd.read_csv(group_file, sep="\t")
sample_to_group = dict(zip(group_df["ID"], group_df["top_K5"]))

# Keep group list order
group_list = list(dict.fromkeys(group_df["top_K5"]))

# ===== Get Sample Order =====
with open(geno_file) as f:
    header = f.readline().strip().split("\t")
    sample_ids = header[4:]

# ===== Count Total Valid Samples =====
# Only counts samples present in the group file
total_samples_with_group = sum(1 for s in sample_ids if s in sample_to_group)

# ===== Check Progress =====
start_line = 0
if os.path.exists(checkpoint_file):
    with open(checkpoint_file) as ckpt:
        line = ckpt.readline().strip()
        if line.isdigit():
            start_line = int(line)

# ===== Open Output (Append) =====
header_written = os.path.exists(output_file) and os.path.getsize(output_file) > 0
f_out = open(output_file, "a")

# ===== Main Logic =====
with open(geno_file) as f_in:
    _ = f_in.readline()  # skip header
    current_line = 0
    batch = []

    print("Processing SNP file...")
    t_start = time.time()

    for line in f_in:
        current_line += 1
        if current_line <= start_line:
            continue  # Already processed

        parts = line.strip().split("\t")
        if len(parts) < 5:
            continue

        snp_id = f"{parts[0]}:{parts[1]}"
        genotypes = parts[4:]

        group_alt_counts = defaultdict(int)
        total_alt = 0

        for sample, gt in zip(sample_ids, genotypes):
            if gt in {"0/1", "1/0", "1/1", "0|1", "1|0", "1|1"}:
                group = sample_to_group.get(sample)
                if group:
                    group_alt_counts[group] += 1
                    total_alt += 1

        if total_alt == 0:
            continue

        # Count groups with ALT
        shared_groups = sum(group_alt_counts[g] > 0 for g in group_list)

        row = [snp_id, str(shared_groups)]
        
        # Group ALT counts
        for g in group_list:
            row.append(str(group_alt_counts[g]))
        
        # Group ALT ratios (denominator: total valid samples)
        for g in group_list:
            ratio = group_alt_counts[g] / total_samples_with_group if total_samples_with_group > 0 else 0
            row.append(f"{ratio:.6f}")

        batch.append("\t".join(row))

        # Write batch & Save checkpoint
        if len(batch) >= batch_size:
            if not header_written:
                header = ["SNP_ID", "SharedGroups"] + \
                         [f"{g}_count" for g in group_list] + \
                         [f"{g}_ratio" for g in group_list]
                f_out.write("\t".join(header) + "\n")
                header_written = True

            f_out.write("\n".join(batch) + "\n")
            f_out.flush()
            
            with open(checkpoint_file, "w") as ckpt:
                ckpt.write(str(current_line))
            batch = []

            elapsed = time.time() - t_start
            print(f"[{time.strftime('%H:%M:%S')}] Processed {current_line:,} lines... Elapsed: {elapsed:.1f}s")

    # Write remaining
    if batch:
        if not header_written:
            header = ["SNP_ID", "SharedGroups"] + \
                     [f"{g}_count" for g in group_list] + \
                     [f"{g}_ratio" for g in group_list]
            f_out.write("\t".join(header) + "\n")
        f_out.write("\n".join(batch) + "\n")

    # Final checkpoint
    with open(checkpoint_file, "w") as ckpt:
        ckpt.write(str(current_line))

    print(f"Done. Total lines: {current_line:,}. Output: {output_file}")

f_out.close()
