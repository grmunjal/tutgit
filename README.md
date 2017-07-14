#---------- Demo of some modifications to GBS-SNP-CROP ----------# 

Here I use:

- vsearch (instead of usearch) so a larger amount of data can be used in clustering

- parallelization is accomplished by either:
	- a perl library for this (see below)
	- or using bash scripts based on the fact that processing one file is independent of processing another. 
		- So we can split up the barcode file into segments and then process in parallel
		- somewhat hard to see the gain from this on tutorial data because the sample number is small
		


#---------- Requirements (and how to get them) ----------#

#---- samtools
wget https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2
tar -xjf samtools-1.2.tar.bz2
cd samtools-1.2/
sudo make install


#---- BWA
wget http://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.12.tar.bz2
tar -jxvf bwa-0.7.12.tar.bz2
cd bwa-0.7.12/
make
sudo mv bwa /usr/local/bin


#---- perl library for parallelizing
cpan Parallel::ForkManager


#---- vsearch (version 2.4.2)
https://github.com/torognes/vsearch/releases
Binary for mac provided in the bin folder (replace with your own sys version if not on mac)


#---- trimmomatic (v0.33)
http://www.usadellab.org/cms/index.php?page=trimmomatic
jar file provided in 



#---------- Goal ----------#

m x 2n table of read counts; m markers, n individuals (or samples), 2 alleles per individual

like so:

marker1 ind1a1count ind1a2count.....indna1count indna2count 



#---------- How to run ----------#

#Navigate to top level directory
cd


#Get everything
wget https://github.com/grmunjal/tutgit/


#Navigate to log folder
cd log


#Execute following commands
nohup bash ../runsteps/123-start

nohup bash ../runsteps/4-align

nohup bash ../runsteps/5-processcounts

nohup bash ../runsteps/6-transform

nohup bash ../runsteps/7-filter

nohup bash ../runsteps/8-final


#View the final output:
cat ../tutpop/data/parsed/demultiplexed/SNPsCalled/SNPs_counts-R.txt

SNP1	68	0	119	14	91	29	143	20	124	29
SNP2	45	10	64	42	102	20	82	44	76	48
SNP3	16	39	67	40	95	27	85	37	96	25
SNP4	29	14	31	20	32	29	34	17	37	39
SNP5	0	0	3	3	3	3	7	3	3	3
SNP6	0	0	3	3	3	3	7	3	3	3
SNP7	0	0	3	5	7	5	6	4	4	5
SNP8	7	5	0	0	4	3	4	5	7	3
SNP9	3	3	8	3	9	4	4	5	5	0



The original pipeline tutorial (usearch and no parallelization looks like):
https://github.com/halelab/GBS-SNP-CROP/tree/master/tutorial

MockRefGenome	13	C	130.00	C	A	100.00	1	4	0	C/C|68/0	C/A|123/14	C/A|94/30	C/A|145/20	C/A|127/29
MockRefGenome	506858	C	56.40	C	T	100.00	0	5	0	C/T|29/14	C/T|31/20	C/T|32/29	C/T|34/17	C/T|37/39
MockRefGenome	672873	G	9.75	G	T	80.00	0	4	0	-|-	G/T|3/5	G/T|7/5	G/T|6/4	G/T|4/5
MockRefGenome	683723	C	8.50	T	C	80.00	0	4	0	-|-	T/C|3/5	T/C|6/5	T/C|3/3	T/C|4/5
MockRefGenome	683743	A	8.50	G	A	80.00	0	4	0	-|-	G/A|5/3	G/A|5/6	G/A|3/3	G/A|5/4
MockRefGenome	683745	A	8.50	G	A	80.00	0	4	0	-|-	G/A|5/3	G/A|5/6	G/A|3/3	G/A|5/4
MockRefGenome	1003851	T	9.50	T	G	80.00	0	4	0	T/G|7/5	-|-	T/G|4/3	T/G|4/5	T/G|7/3
MockRefGenome	1165038	G	106.60	G	A	100.00	0	5	0	G/A|45/10	G/A|64/42	G/A|102/20	G/A|82/44	G/A|76/48
MockRefGenome	1165050	G	105.40	G	A	100.00	0	5	0	G/A|16/39	G/A|67/40	G/A|95/27	G/A|85/37	G/A|96/25
MockRefGenome	1165714	T	9.75	T	A	80.00	0	4	0	T/A|3/3	T/A|8/3	T/A|9/4	T/A|4/5	-|5/0



#Note:
A lot of the custom bash commands use in-place sed and are written like so:
sed -i '' 's,replaceme,withthis,g' file

On other systems this might not work and will need to change to something like so:
sed -i 's,replaceme,withthis,g' file







