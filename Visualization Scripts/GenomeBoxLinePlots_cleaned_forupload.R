## Visualise genome1 vs 3k genomes INDELS randomisation
rm(list= ls())
pacman::p_load(tidyverse,ggplot2, cowplot)

#permutated_snps_newsnps <- read.table("/home/thimmamp/10K/data/genome1_basemissing_Randomisation_newsnps_numsnps.txt",
#                                      sep="\t", header = TRUE)


#colnames(permutated_snps) <- c("num_samples", "randomisation_num", "numsnps", "file")
  #c("numsamples", "randomisation_num", "numsnps") 
# colnames(permuted_newsnps)  <- c("group", "randomisation_num", "numsnps")

pdf(file=paste0("/home/thimmamp/10K/Visualization/genome1basemissingVs10K_NumandnewNPsfacetwrap.pdf"))
permutated_snps_newsnps %>% 
  gather("snps", "numbers", -c(percentage, Randomstep)) %>% 
  ggplot(., aes(x=as.factor(percentage), y=numbers)) + geom_boxplot(aes(fill=snps))+  
  geom_jitter(shape=16, position=position_jitter(0.2))+
  geom_point(aes(y=numbers, group=snps), position = position_dodge(width=0.75))+
  facet_wrap( ~ percentage, scales="free")+
 xlab("Percentage of samples permutated") + ylab("Number of SNPS") + ggtitle("Trend in the number of snps and new snps observed during \ndifferent percentage of samples permutated")+
 guides(fill=guide_legend(title="Legend_Title"))
dev.off()

################
permutated_snps_newsnps %>% 
  gather("snps", "numbers", -c(percentage, Randomstep)) %>%
  ggplot(., aes(x=as.factor(percentage), y=numbers)) + 
  geom_boxplot(aes(fill=snps)) +
  geom_jitter(shape=16, position=position_jitter(0.2))+
  stat_summary(fun=mean, colour="blue", aes(group=1),
               geom="line", lwd=1, lty=1) 

### two lines in one plot with two different y-axis
percent <- permutated_snps_newsnps %>%
  select(percentage, numsnps, newsnps) %>% 
  group_by(percentage) %>% 
  summarise_all("mean") %>% 
  select(percentage)
  
avgnew  <- permutated_snps_newsnps %>%
  select(percentage, numsnps, newsnps) %>% 
  group_by(percentage) %>% 
  summarise_all("mean") %>% 
  select(newsnps)

avgnum  <- permutated_snps_newsnps %>%
  select(percentage, numsnps, newsnps) %>% 
  group_by(percentage) %>% 
  summarise_all("mean") %>% 
  select(numsnps)

data <-data.frame(percent, avgnew, avgnum)


# Draw first plot using axis y1 
par(mar = c(7, 3, 5, 4) + 0.3)               
plot(data$percent,  data$numsnps, type="l",pch=21, col = 2)   

# set parameter new=True for a new axis 
par(new = TRUE)          

# Draw second plot using axis y2 
plot(data$percent, data$newsnps, type="l",pch=21, col = 3, axes = FALSE, xlab = "", ylab = "") 

axis(side = 4, at = pretty(range(data$newsnps)))       
mtext("Number of new snps", side = 4, line = 3)

################

## Line plot
pdf(file=paste0("/home/thimmamp/10K/Visualization/genome1filteredVs10K_NumSNPs_1MbWindow_facet.pdf"))
p <- ggplot(data = chrsnps_1mbwindow, aes(x = end, y = numsnps)) + geom_line(linetype = "dashed", color="red") +
  geom_point() +
  labs(title="Chromosomewise Number of SNPs for genome1 Vs 20K genomes", 
       x="Genomic loci 1Mb window", y = "Number of SNPs")
p + facet_wrap(~chr, nrow=12)
dev.off()

## boxplot
pdf(file="/home/thimmamp/10K/Randomization/genome1filteredVs20K_10random_newsnps_boxplot.pdf")
ggplot(permutated_snps, aes(x=as.factor(num_samples), y=numsnps)) +
  geom_boxplot() +  geom_jitter(shape=16, position=position_jitter(0.2))+
  stat_summary(fun=mean, colour="orange", aes(group=1),
               geom="line", lwd=1, lty=1) +
  #theme_classic() +
  labs(title="Number of SNPs in genome1 filtered Vs 20K genomes by randomization", 
       x="number of rice accessions sampled", y = "Number of SNPs")
dev.off()

###################

pdf(file="/home/thimmamp/10K/20KRGP_Lineplotofnewsnps.pdf")
ggplot(twentyk_newsnps,aes(x=numsamples, y=numnewsnps, group=1)) +
  geom_line(linetype = "dashed", color="red") +
  geom_point() +
  labs(title="Number of new SNPs in 20K genomes", 
       x="Number of samples increased", y = "Number of SNPs")
dev.off()

ggplot(dat,aes(x=end, y=numsnps, group=1)) +
  geom_line(linetype = "dashed", color="red") +
  geom_point() +
  labs(title="Number of new SNPs in 20K genomes", 
       x="Number of samples increased", y = "Number of SNPs")

ggplot(chrsnps,aes(x=chr, y=numsnps))+
  geom_bar()

ggplot(twentyk_newsnps,aes(x=numsamples, y=numnewsnps, group=1)) +
  geom_line(linetype = "dashed", color="red") +
  geom_point() +
  labs(title="Number of new SNPs in 20K genomes", 
       x="Number of samples increased", y = "Number of SNPs")

mydata <- rand_indels %>% 
  #group_by(randomisation_num, sample_percent, Numofsamples) %>% 
  #summarise(INS = sum(numins), DELS = sum(numdels)) %>% 
  #mutate(percent = sample_percent*10) %>% 
  select(randomisation_num, sample_percent, Numofsamples, INS, DELS) 

#write.table(mydata, file="/home/thimmamp/MAGIC16/indels_results/genome6Vs3K_100random_indels.csv",sep = ",", row.names = FALSE)

pdf(file="/home/thimmamp/10K/Visualization/genome1_filtered_Vs20KRGP_10random_SNPs_randomisation_moreintervals_boxplot.pdf")
ggplot(permutated_snps, aes(x=as.factor(numsamples), y=numsnps, color=numsamples)) +
  geom_boxplot() +  geom_jitter(shape=16, position=position_jitter(0.2))+
   stat_summary(fun=mean, colour="orange", aes(group=1),
               geom="line", lwd=1, lty=1) +
  #theme_classic() +
  labs(title="Number of SNPs in genome1 filtered Vs 10K genomes by randomization", 
       x="Number of 10K data sampled", y = "Number of SNPs")
dev.off()



## boxplot
pdf(file="/home/thimmamp/MAGIC16/indels_results/genome6Vs3K_100random_indels_randomisation_Insertion_boxplot.pdf")
ggplot(permutated_snps, aes(x=as.factor(sample_percent), y=INS, color=sample_percent)) +
  geom_boxplot() +  geom_jitter(shape=16, position=position_jitter(0.2))+
  stat_summary(fun=mean, colour="orange",
               geom="point",position=position_dodge(width=0.75)) +
  stat_summary(fun=mean, colour="orange", aes(group=1),
               geom="line", lwd=1, lty=1) +
  theme_classic() +
  labs(title="Number of insertions in genome6 (IR64) by randomisation", 
       x="Percentage of 3K data sampled", y = "Number of Insertions")
#geom_boxplot(aes(fill=sample_percent))
dev.off()

pdf(file="/home/thimmamp/MAGIC16/indels_results/genome6Vs3K_100random_indels_randomisation_Deletions_boxplot.pdf")
ggplot(mydata, aes(x=as.factor(sample_percent), y=DELS, color=sample_percent)) +
  geom_boxplot() +  geom_jitter(shape=16, position=position_jitter(0.2))+
  stat_summary(fun=mean, colour="green",
               geom="point",position=position_dodge(width=0.75)) +
  stat_summary(fun=mean, colour="green", aes(group=1),
               geom="line", lwd=1, lty=1) +
  theme_classic() +
  labs(title="Number of deletions in genome6(IR64) by randomisation", 
       x="Percentage of 3K data sampled", y = "Number of Deletions")
#geom_boxplot(aes(fill=sample_percent))
dev.off()  


ggplot(indels, aes(x=PercentageofSamples, y=NumberofDELS))+
  geom_line()+
  geom_point()+
  theme_classic()+
  labs(title="Number of deletions by randomisation", 
       x="Percentage of 3K data sampled", y = "Number of Deletions")+
  facet_grid(~Repetition)


pdf(file="/home/thimmamp/MAGIC16/indels_results/genome1Vs3K_indels_randomisation.pdf")
ggplot(indels, aes(x=PercentageofSamples, y=Number, fill=INDELS))+
  geom_bar(stat="identity", position = position_dodge())+
  theme_classic()+
  labs(title="Number of indels by randomisation", 
       x="Percentage of 3K data sampled", y = "Number of indels")+
  facet_grid(~Repetition)
dev.off()

