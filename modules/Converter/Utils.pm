package Converter::Utils;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(formNumbering countInsertions countInsertionsCdr3 convertRegion);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

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
    my ($cdr_array_ref, $residues_untill_insertion_region) = @_;
    my $insertions = scalar(@$cdr_array_ref) - $residues_untill_insertion_region - 3;
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
