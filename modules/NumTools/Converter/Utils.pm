package Converter::Utils;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(formNumbering countInsertions countInsertionsCdr3 convertRegion);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

use constant {INSERTIONLESS_END => 2};  #INSERTIONLESS_END source: https://www.imgt.org/IMGTScientificChart/Numbering/CDR3-IMGTgaps.html

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
    my ($max_esential_resiudes, $current_region_length) = @_;
    return $current_region_length - $max_esential_resiudes
}

sub countInsertionsCdr3
{
    my ($cdr_array_ref, $residues_untill_insertion_region) = @_;
    my $insertions = scalar(@$cdr_array_ref) - $residues_untill_insertion_region - INSERTIONLESS_END;
    return $insertions
}


sub convertRegion
{
    my ($cdr_array_ref, $max_esential_resiudes, 
            $gaps_to_ignore) = @_;
    
    my $gaps_to_delete = @$cdr_array_ref - $max_esential_resiudes;
    my @good_indices;
    for( my $i = 0; $i < @$cdr_array_ref; $i++)
    {
        if($cdr_array_ref->[$i] ne '-' or $gaps_to_ignore > $i)
        {
            push @good_indices, $i;
            next;
        }
        
        if($gaps_to_delete > 0 and $cdr_array_ref->[$i] eq '-')
        {
            $gaps_to_delete--;
        }
        else
        {
            push @good_indices, $i;
        }
    }
    return \@good_indices
}


1;
