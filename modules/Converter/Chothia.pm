package Converter::Chothia;

use strict;
use warnings;
use Exporter 'import';

use lib '.';
use Converter::Utils qw(:ALL);

our @EXPORT_OK = qw(convertToChothia);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

sub convertToChothia
{
    my ($seq, $domain) = @_;
    return convertToChothiaHeavy($seq) if $domain =~ /IGH/;
    return convrtToChothiaLight_Kappa($seq) if $domain =~ /IGK/;
    return convrtToChothiaLight_Lambda($seq) if $domain =~ /IGL/;
}

sub convrtToChothiaLight_Lambda
{
    my ($seq) = @_;
    my @seq = split('', $seq);
    my $end = scalar(@seq) - 12;         # F1 C1  F2  C2  F3   C3   F4
    my @region_starts                   = (0, 26, 40, 55, 65,  104, -11); # Indexes from IMGT numbering scheme
    my @region_ends                     = (25,39, 54, 64, 103, $end, -1); # Indexes from IMGT numbering scheme
    my @region_numbering_start          = (1, 27, 35, 50, 53,  89,   98); # Indexes from Kabat numbering scheme 
    my @region_numbering_end            = (26,34, 49, 52, 88,  97,  107); # Indexes from Kabat numbering scheme
    my @regions_max_length              = (26,14, 15, 10, 39,  undef,11); # Length from IMGT numbering scheme
    my @region_insertions_count         = (0, 3,  0,  0,  0,   0,     0); # Insertions from Kabat numbering scheme
    my @region_structural_gaps_count    = (0, 3,  0,  7,  3,   4,     1); # Gaps from Stockholm file 
    my @region_residues_till_struct_gap = (9, 1,  0,  0,  7,   0,     0);    # pos is stuct gap if all pos in columns are gaps
    my @region_insertions_positions     = (undef, 30, undef, undef, undef, 95, undef); # Insertion pos from Kabat numbering scheme
    my @regions = ('fr1', 'cdr1', 'fr2', 'cdr2', 'fr3', 'cdr3', 'fr4'); 
    my @conveted_seq;
    my @kabat_numbering;
    for my $i (0..scalar(@regions) - 1)
    {
        my $region_current_insertions_count =  0;
    	my @region = @seq[$region_starts[$i]..$region_ends[$i]];
    	my $good_indicies = convertRegion(\@region, $region_structural_gaps_count[$i],
                                          $region_insertions_count[$i],
                                          $region_residues_till_struct_gap[$i]);
                                          
        @region = @region[@{$good_indicies}]; #Deleting structural gaps
        my $region_actual_length = scalar(@region);
    	
    	
    	if($regions[$i] =~ /cdr1|cdr2/ or $regions[$i] =~ /fr3/)
    	{
    	    $region_current_insertions_count = countInsertions($regions_max_length[$i],
                                                        $region_actual_length,
                                                        $region_structural_gaps_count[$i],
                                                        $region_insertions_count[$i]);
        }
        
        if($regions[$i] =~ /cdr3/)
        {
            $region_current_insertions_count = countInsertionsCdr3(\@region, 6);
        }                                          
        push @kabat_numbering, formNumbering($region_numbering_start[$i],
                                             $region_numbering_end[$i],
                                             $region_current_insertions_count, $region_insertions_positions[$i]);
                               
       push @conveted_seq, @region;
    }
    
    return \@conveted_seq, \@kabat_numbering
}

sub convrtToChothiaLight_Kappa
{
    my ($seq) = @_;
    my @seq = split('', $seq);
    my $end = scalar(@seq) - 12;         # F1 C1  F2  C2  F3   C3   F4
    my @region_starts                   = (0, 26, 40, 55, 65,  104, -11); # Indexes from IMGT numbering scheme
    my @region_ends                     = (25,39, 54, 64, 103, $end, -1); # Indexes from IMGT numbering scheme
    my @region_numbering_start          = (1, 27, 35, 50, 53,  89,   98); # Indexes from Kabat numbering scheme 
    my @region_numbering_end            = (26,34, 49, 52, 88,  97,  107); # Indexes from Kabat numbering scheme
    my @regions_max_length              = (26,14, 15, 10, 39,  undef,11); # Length from IMGT numbering scheme
    my @region_insertions_count         = (0, 5,  0,  0,  0,   0,     0); # Insertions from Kabat numbering scheme
    my @region_structural_gaps_count    = (0, 1,  0,  7,  3,   4,     1); # Gaps from Stockholm file 
    my @region_residues_till_struct_gap = (0, 0,  0,  0,  7,   0,     0);    # pos is stuct gap if all pos in columns are gaps
    my @region_insertions_positions     = (undef, 30, undef, undef, undef, 95, undef); # Insertion pos from Kabat numbering scheme
    my @regions = ('fr1', 'cdr1', 'fr2', 'cdr2', 'fr3', 'cdr3', 'fr4'); 
    my @conveted_seq;
    my @kabat_numbering;
    for my $i (0..scalar(@regions) - 1)
    {
        my $region_current_insertions_count =  0;
    	my @region = @seq[$region_starts[$i]..$region_ends[$i]];
    	my $good_indicies = convertRegion(\@region, $region_structural_gaps_count[$i],
                                          $region_insertions_count[$i],
                                          $region_residues_till_struct_gap[$i]);
                                          
        @region = @region[@{$good_indicies}]; #Deleting structural gaps
        my $region_actual_length = scalar(@region);
    	
    	
    	if($regions[$i] =~ /cdr1|cdr2/ or $regions[$i] =~ /fr3/)
    	{
    	    $region_current_insertions_count = countInsertions($regions_max_length[$i],
                                                        $region_actual_length,
                                                        $region_structural_gaps_count[$i],
                                                        $region_insertions_count[$i]);
        }
        
        if($regions[$i] =~ /cdr3/)
        {
            $region_current_insertions_count = countInsertionsCdr3(\@region, 6);
        }                                          
        push @kabat_numbering, formNumbering($region_numbering_start[$i],
                                             $region_numbering_end[$i],
                                             $region_current_insertions_count, $region_insertions_positions[$i]);
                               
       push @conveted_seq, @region;
    }
    
    return \@conveted_seq, \@kabat_numbering
}



sub convertToChothiaHeavy
{
    my ($seq) = @_;
    my @seq = split('', $seq);
    my $end = scalar(@seq) - 12;         # F1 C1  F2  C2  F3   C3   F4
    my @region_starts                   = (0, 26, 40, 55, 65,  104, -11);
    my @region_ends                     = (25,39, 54, 64, 103, $end, -1);
    my @region_numbering_start          = (1, 26, 36, 51, 58,  93,  103);
    my @region_numbering_end            = (25,35, 50, 57, 92,  102, 113);
    my @regions_max_length              = (26,14, 15, 10, 39,  undef,11);
    my @region_insertions_count         = (0, 2,  0,  2,  3,   0,     0);
    my @region_structural_gaps_count    = (1, 2,  0,  1,  1,   1,     0);
    my @region_residues_till_struct_gap = (9, 4,  0,  2,  7,   0,     0);
    my @region_insertions_positions     = (undef, 31, undef, 52, 82, 100, undef);
    my @regions = ('fr1', 'cdr1', 'fr2', 'cdr2', 'fr3', 'cdr3', 'fr4'); 
    my @conveted_seq;
    my @kabat_numbering;
    for my $i (0..scalar(@regions) - 1)
    {
        my $region_current_insertions_count =  0;
    	my @region = @seq[$region_starts[$i]..$region_ends[$i]];
    	my $good_indicies = convertRegion(\@region, $region_structural_gaps_count[$i],
                                          $region_insertions_count[$i],
                                          $region_residues_till_struct_gap[$i]);
                                          
        @region = @region[@{$good_indicies}]; #Deleting structural gaps
        my $region_actual_length = scalar(@region);
    	
    	
    	if($regions[$i] =~ /cdr1|cdr2/ or $regions[$i] =~ /fr3/)
    	{
    	    $region_current_insertions_count = countInsertions($regions_max_length[$i],
                                                        $region_actual_length,
                                                        $region_structural_gaps_count[$i],
                                                        $region_insertions_count[$i]);
        }
        
        if($regions[$i] =~ /cdr3/)
        {
            $region_current_insertions_count = countInsertionsCdr3(\@region, 7);
        }                                          
        push @kabat_numbering, formNumbering($region_numbering_start[$i],
                                             $region_numbering_end[$i],
                                             $region_current_insertions_count, $region_insertions_positions[$i]);
                               
       push @conveted_seq, @region;
    }
    
    return \@conveted_seq, \@kabat_numbering
}

1;
