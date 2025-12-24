#!/usr/bin/env python3
"""
Author: Wen Zhao
Email: zhaozs221@163.com
Creation Date: 2024
License: Free to use with proper attribution
"""

import sys

def calculate_a_n(n):
    return sum(1.0 / i for i in range(1, n))

def main():
    if len(sys.argv) != 4:
        print("Usage: python3 calculate_theta.py snp_counts_per_window.txt sample_size output_file")
        sys.exit(1)
    
    snp_counts_file = sys.argv[1]
    sample_size = int(sys.argv[2])
    output_file = sys.argv[3]
    
    a_n = calculate_a_n(sample_size)
    
    with open(snp_counts_file, 'r') as infile, open(output_file, 'w') as outfile:
        outfile.write("Chromosome\tStart\tEnd\tS\tTheta\n")
        for line in infile:
            parts = line.strip().split()
            chrom, start, end, S = parts[0], parts[1], parts[2], int(parts[3])
            theta = S / a_n if a_n != 0 else 0
            outfile.write(f"{chrom}\t{start}\t{end}\t{S}\t{theta:.6f}\n")

if __name__ == "__main__":
    main()
