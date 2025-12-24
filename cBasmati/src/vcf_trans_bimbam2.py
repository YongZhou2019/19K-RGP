import sys

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
pop1_list.sort()
print pop1_list
infile.close()
print "%d samples in %s\n" % (len(pop1_list), pop1_file.split('.')[0])

ind_list=[]
print(len(pop1_list)//2.0)
for i in range(int(len(pop1_list)//2.0)):
    ind="ind"+str(i)
    ind_list.append(ind)
    string = "%s" % ("\t".join(ind_list))
### load vcf_information, added to each bin
infile = open(geno_file, "r")
outfile = open(out_file, "w")
outfile.write(str(int(len(pop1_list)//2.0))+" =\n"+snp_num+"\n"+"IND\t"+string+"\n")
pop1_pos = []
num = 0
for line in infile:
    line = line.strip("\n\r")
    ele = line.split("\t")
    if line[:3] == "IND":## get position of samples for each population
        for hap in pop1_list:
            pop1_pos.append(ele.index(hap))
    if num >=3 :
        hap_geno_list = []
        for i in range(len(pop1_pos)):
            if i%2.0==0:
                if i!=len(pop1_pos)-1:
                    geno = ele[pop1_pos[i]][0]+ele[pop1_pos[i+1]][0]
                    hap_geno_list.append(geno)
        string = "%s\t%s" % (ele[0],"\t".join(hap_geno_list))
        outfile.write(string+"\n")
    num += 1
