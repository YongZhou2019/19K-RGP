import sys, os
from matplotlib import pyplot as plt
from matplotlib_venn import venn3
from matplotlib_venn import venn2
import itertools

## usage: python CreateVennDiagram.py /data_b/IRGSP_SNP_InDels_Venn/genome27_SNP_3K /data_b/IRGSP_SNP_InDels_Venn/genome27_SNP_7K /data_b/IRGSP_SNP_InDels_Venn/genome27_SNP_10K
## usage :python CreateVennDiagram.py
# /data_b/IRGSP_SNP_InDels_Venn/genome1.3K.biallelic.base.genomewide
# /data_b/IRGSP_SNP_InDels_Venn/genome1.7K.biallelic.base.genomewide
# /data_b/IRGSP_SNP_InDels_Venn/genome1.10K.biallelic.base.genomewide
location = "/data-A/IRGSP_SNP_InDels_Venn/VennResults/"
datatype = "genome1_biallelic_phase5_plink2"

# Read the files and extract unique strings
file1_data = set()
file2_data = set()
file3_data = set()

# Read and process file 1
with open(sys.argv[1], "r") as file1:
    for line in file1:
        file1_data.add(line.strip())

# Read and process file 2
with open(sys.argv[2], "r") as file2:
    for line in file2:
        file2_data.add(line.strip())

# Read and process file 3
with open(sys.argv[3], "r") as file3:
    for line in file3:
        file3_data.add(line.strip())

# Generate the Venn diagram
venn = venn3([file1_data, file2_data, file3_data], ('genome1_3K', 'genome1_7K', 'genome1_10K'))

# Get the entries of each section
venn_entries = {
    "3K": file1_data - file2_data - file3_data,
    "7K": file2_data - file1_data - file3_data,
    "10K": file3_data - file1_data - file2_data,
    "3K_7K": file1_data & file2_data - file3_data,
    "3K_10K": file1_data & file3_data - file2_data,
    "7K_10K": file2_data & file3_data - file1_data,
    "3K_7K_10K": file1_data & file2_data & file3_data
}

# Print the entries of each section

##write output
for key, value in venn_entries.items():
    print(f"Section {key}: {len(value)} entries")
    fname = location+datatype+"_"+key+"_entries.txt"
    with open(fname, 'w') as f:
        f.write("\n".join(list(venn_entries[key]))+'\n')

# Save the plot to a PDF file
filename=datatype+"3K_7K_10K_Venndiagram.pdf"
plt.savefig(location+filename)

