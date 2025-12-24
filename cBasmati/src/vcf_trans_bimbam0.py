import sys
import gzip

geno_file = sys.argv[1]
pop1_file = sys.argv[2]
out_file = sys.argv[3] ## geno_bimbam_file
snp_num = sys.argv[4]
### load sample list for pop1
infile = open(pop1_file, "r")
pop1_list = []
for line in infile:
    line = line.strip("\n\r")
    ele = line.split("\t")
    pop1_list.append(ele[0])
infile.close()
print "%d samples in %s\n" % (len(pop1_list), pop1_file.split('.')[0])

### load vcf_information, added to each bin
infile = gzip.open(geno_file, "r")
outfile = open(out_file, "w")
outfile.write(str(len(pop1_list)*2)+"\n"+snp_num+"\n")
pop1_pos = []
hap_list = []
for line in infile:
    line = line.strip("\n\r")
    ele = line.split("\t")
    if line[:6] == "#CHROM":## get position of samples for each population
        for ind in pop1_list:
            pop1_pos.append(ele.index(ind))
            hap1 = ind+"_1"
            hap2 = ind+"_2"
            hap_list.append(hap1)
            hap_list.append(hap2)
        string = "%s" % ("\t".join(hap_list))
        outfile.write("IND\t"+string+"\n")
    if line[0] != "#":
        hap_geno_list = []
        for i in pop1_pos:
            if ele[i][0] == ".":
                hap_geno_list.append("NN")
                hap_geno_list.append("NN")
            else:
                if ele[i][0] == "0":
                    hap1_geno = ele[3]+ele[3]
                if ele[i][0] == "1":
                    hap1_geno = ele[4]+ele[4]
                if ele[i][2] == "0":
                    hap2_geno = ele[3]+ele[3]
                if ele[i][2] == "1":
                    hap2_geno = ele[4]+ele[4]
                hap_geno_list.append(hap1_geno)
                hap_geno_list.append(hap2_geno)
        string = "%s\t%s" % (ele[1],"\t".join(hap_geno_list))
        outfile.write(string+"\n")
