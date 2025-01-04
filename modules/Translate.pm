package Translate;

use strict;
use warnings;


my %GENETIC_CODE = (
    'ATA' => 'I', 'ATC' => 'I', 'ATT' => 'I', 'ATG' => 'M',
    'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACT' => 'T',
    'AAC' => 'N', 'AAT' => 'N', 'AAA' => 'K', 'AAG' => 'K',
    'AGC' => 'S', 'AGT' => 'S', 'AGA' => 'R', 'AGG' => 'R',
    'CTA' => 'L', 'CTC' => 'L', 'CTG' => 'L', 'CTT' => 'L',
    'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCT' => 'P',
    'CAC' => 'H', 'CAT' => 'H', 'CAA' => 'Q', 'CAG' => 'Q',
    'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGT' => 'R',
    'GTA' => 'V', 'GTC' => 'V', 'GTG' => 'V', 'GTT' => 'V',
    'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCT' => 'A',
    'GAC' => 'D', 'GAT' => 'D', 'GAA' => 'E', 'GAG' => 'E',
    'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGT' => 'G',
    'TCA' => 'S', 'TCC' => 'S', 'TCG' => 'S', 'TCT' => 'S',
    'TTC' => 'F', 'TTT' => 'F', 'TTA' => 'L', 'TTG' => 'L',
    'TAC' => 'Y', 'TAT' => 'Y', 'TAA' => '*', 'TAG' => '*',
    'TGC' => 'C', 'TGT' => 'C', 'TGA' => '*', 'TGG' => 'W',
    '...' => '-',
);


sub translate_triplet
{
	my ($codon) = @_;

    #if (length($codon) != 3)
    #{
     #   warn "Invalid codon length: $codon";
      #  return '?';
    #}

	$codon = uc($codon);
	return $GENETIC_CODE{$codon} // '?';
}

sub translate_seq
{
	my ($sequence, $frame) = @_;
	$sequence = substr($sequence, $frame - 1);
	my @triplets = ($sequence =~ /.{1,3}/g);
	my $protein_seq = '';
	for my $triplet (@triplets)
	{
		$protein_seq .= translate_triplet($triplet);
	}
	return $protein_seq
}


1;
