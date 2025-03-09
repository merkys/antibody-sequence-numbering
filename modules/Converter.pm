package Converter;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(convertToKabatHeavy);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

sub convertToKabatHeavy
{
    my ($seq, $numbering_ref) = @_;
    my @seq = split('', $seq);
    my $end = scalar(@seq) - 12;          # F1  C1  F2  C2  F3   C3   F4
    my @region_starts                   = (0, 26, 40, 55, 65,  104, -11);
    my @region_ends                     = (25,39, 54, 64, 103, $end, -1);
    my @region_numbering_start          = (1, 26, 36, 51, 58,  93,  103);
    my @region_numbering_end            = (25,35, 50, 57, 92,  102, 113);
    my @regions_max_length              = (26,14, 15, 10, 39,  undef,11);
    my @region_insertions_count         = (0, 2,  0,  2,  3,   0,     0);
    my @region_structural_gaps_count    = (1, 2,  0,  1,  1,   1,     0);
    my @region_residues_till_struct_gap = (9, 4,  0,  2,  7,   0,     0);
    my @region_insertions_positions     = (undef, 35, undef, 52, 82, 100, undef);
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
            $region_current_insertions_count = countInsertionsCdr3(\@region);
        }                                          
        push @kabat_numbering, formNumbering($region_numbering_start[$i],
                                             $region_numbering_end[$i],
                                             $region_current_insertions_count, $region_insertions_positions[$i]);
                               
       push @conveted_seq, @region;
    }
    
    my $output = '';
    for( my $i = 0; $i < @conveted_seq; $i++)
    {
        $output .= $conveted_seq[$i] . "\t" . $kabat_numbering[$i] . "\n";
    }
    return $output
}

sub formNumbering
{
    my ($numbering_start, $numbering_end,
        $insertions_count, $insertions_position) = @_;
        
    if($insertions_count == 0)
    {
        return ($numbering_start..$numbering_end)
    }
    
    my @numbering;
    for my $num ($numbering_start .. $numbering_end)
    {
        push @numbering, $num;
        if ($num == $insertions_position)
        {
            for my $i (0 .. $insertions_count - 1)
            {
                my $letter = chr(ord('a') + $i);
                push @numbering, $num . " " . $letter;
            }
        }
    }
    
    return @numbering;
}

sub countInsertions
{
    my ($max_region_length, $current_region_length,
        $structual_gaps, $max_insertions_count) = @_;
         
    return ($current_region_length + $structual_gaps + $max_insertions_count) - $max_region_length;
}

sub countInsertionsCdr3
{
    my ($cdr_array_ref) = @_;
    my $insertions = scalar(@$cdr_array_ref) - 7 - 3;
    return $insertions
}

sub convertRegion
{
    my ($cdr_array_ref, $structural_gaps,
        $max_insertion_count, $skip_res) = @_;
    # structural_gaps - count of IMGT-specific structural gaps
        # Structural gaps introduced to maintain a consistent numbering scheme
        # They have to be deleted
    # max_insertion - max insertions count in current region
    # skip_res - count of resiues that always have to be in scheme
        # could be gaps
    
    my $max_possible_gaps = $structural_gaps + $max_insertion_count;
    my @good_indices;
    my $gaps_counter = 0;
    for (@$cdr_array_ref)
    {
        $gaps_counter++ if $_ eq '-';
    }
     
    my $true_gaps = $gaps_counter - $max_possible_gaps;
    for( my $i = 0; $i < @$cdr_array_ref; $i++)
    {
        if($i < $skip_res)
        {
            $true_gaps-- if($cdr_array_ref->[$i] eq '-');
            push @good_indices, $i;
            next;
        }
        if($cdr_array_ref->[$i] ne '-')
        {
            push @good_indices, $i;
        }
        elsif($true_gaps > 0)
        {
            push @good_indices, $i;
            $true_gaps--;
        }
    }
    
    return \@good_indices
}

1;
