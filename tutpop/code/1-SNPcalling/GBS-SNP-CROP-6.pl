#!/usr/bin/perl

#########################################################################################################################
# GBS-SNP-CROP, Step 6. For description, see User Manual (https://github.com/halelab/GBS-SNP-CROP/wiki)
#########################################################################################################################

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use List::Util qw( min max );
use Parallel::ForkManager;

my $Usage = "Usage: perl GBS-SNP-CROP-6.pl -b <barcodesID file> -out <SNPs master matrix file>\n";
my $Manual = "Please see the User Manual on the GBS-SNP-CROP GitHub page (https://github.com/halelab/GBS-SNP-CROP.git) or the original manuscript: Melo et al. (2016) BMC Bioinformatics. DOI 10.1186/s12859-016-0879-y.\n"; 

my ($barcodesID_file,$output_file);

GetOptions(
'b=s' => \$barcodesID_file,    # file
'out=s' => \$output_file,      # file
) or die "$Usage\n$Manual\n";

print "\n#################################\n# GBS-SNP-CROP, Step 6, v.2.0\n#################################\n\n";

my @files = ();

open my $IN, "<", "$barcodesID_file" or die "Can't find $barcodesID_file file\n";

while(<$IN>) {
	my $barcodesID = $_;
	chomp $barcodesID;
	my @barcode = split("\t", $barcodesID);
	my $barcode_list = $barcode[0];
	my $TaxaNames = $barcode[1];

	push @files, $TaxaNames;
}
close $IN;
chomp (@files);

open my $CountList, ">", "CountFileList.txt" or die "Unable to load CountFileList.tx file\n";

my $pm = new Parallel::ForkManager(12);

foreach my $file (@files) {
	my $pid = $pm->start and next;	
	my $mpileup_input = join (".", "$file","mpileup");
	my $count_out = join (".", "$file","count","txt");
	my $ref_file = join (".", "$file","ref","txt");
	
	print $CountList "$count_out\n";

	print "Counting nucleotides on $mpileup_input and filtering monomorphic sites ...\n";
	
	open my $PILEUP, "<", "$mpileup_input" or die "Can't load $mpileup_input file";
	open my $OUT1, ">", "$count_out" or die "Can't initialized $count_out ouput file";
	open my $REF, ">", "$ref_file" or die "Unable to identify $ref_file\n";
	
	my $progress1 = 0;
	
	while (<$PILEUP>){
		
		$progress1++;
		print "\033[JStatus: ${progress1} PILEUP entries processed..."."\033[G";
		
		my @input1 = split("\t", $_);
		my $ref = $input1[2];
		my $algn = $input1[4];
		$algn =~ s/\^.\././g;

		my @positions;
		my @sizes;
		my @Indels;
		while ( $algn =~ /\.{1}[\+|-]{1}(\d+)/g  ) { 
			push @positions, pos($algn);
			push @sizes, $1;
		}

		my $indices = scalar @positions - 1;

		for (my $k = $indices; $k >= 0; $k--) {
			my $indel = substr ( $algn, $positions[$k] - length($sizes[$k]) - 1, 1 + length($sizes[$k]) + $sizes[$k]);
			push @Indels, $indel;
			my $start = substr ( $algn, 0, $positions[$k] - length($sizes[$k]) - 2 );
			my $end = substr ( $algn, $positions[$k] + $sizes[$k] );
			$algn = join ("", "$start", "$end" );
		}

		$algn =~ s/\$//g;   
		$algn =~ s/\*//g;
		
		my $uc_ref = uc $ref;
		my $lc_ref = lc $ref;
		$algn =~ s/\./$uc_ref/g;
		$algn =~ s/\,/$lc_ref/g;

		my @bases = split(//, $algn);
		@bases = grep /\S/, @bases;

		my $A = 0; my $a = 0; my $xA = 0;
		my $C = 0; my $c = 0; my $xC = 0;
		my $G = 0; my $g = 0; my $xG = 0;
		my $T = 0; my $t = 0; my $xT = 0;
		
		for(my $x=0; $x<scalar(@bases);$x++) {
			if ($bases[$x] =~ /A/){
				$A++;
			}
			if ($bases[$x] =~ /a/){
				$a++;
			}
			if ($bases[$x] =~ /C/){
				$C++;
			}
			if ($bases[$x] =~ /c/){
				$c++;
			}
			if ($bases[$x] =~ /G/){
				$G++;
			}
			if ($bases[$x] =~ /g/){
				$g++;
			}
			if ($bases[$x] =~ /T/){
				$T++;
			}
			if ($bases[$x] =~ /t/){
				$t++;
			}
		}

		if ($A >= $a) {
			$xA = $A;
		} else {
			$xA = $a
		}

		if ($C >= $c) {
			$xC = $C;
		} else {
			$xC = $c
		}

		if ($G >= $g) {
			$xG = $G;
		} else {
			$xG = $g
		}

		if ($T >= $t) {
			$xT = $T;
		} else {
			$xT = $t
		}

		print $OUT1 join ("\t",$input1[0],$input1[1],$input1[2]),"\t",join(",","$xA","$xC","$xG","$xT"),"\n";

		if ( (($xA + $xC) * ($xG + $xT)) > 0 or (($xA + $xG) * ($xC + $xT)) > 0 ) {
			print $REF join ("\t", $input1[0], $input1[1], $input1[2]),"\n";
			
		}
	}
	close $PILEUP;
	close $OUT1;
	$pm->finish;
}
$pm->wait_all_children;

print "\nCreating a master list of all putative SNPs in the population...\n";


print "DONE.\n";

print "\nCreating a comprehensive master matrix, with genotype-specific alignment summaries, for all putative SNPs in the population ...\n";

print "\nDONE.\n\n";


print "The master matrix was successfully created.\nPlease, proceed with SNP filtering and genotyping.\n";

print "\n\nPlease cite: Melo et al. (2016) GBS-SNP-CROP: A reference-optional pipeline for\n"
."SNP discovery and plant germplasm characterization using variable length, paired-end\n"
."genotyping-by-sequencing data. BMC Bioinformatics. DOI 10.1186/s12859-016-0879-y.\n\n";

exit;
