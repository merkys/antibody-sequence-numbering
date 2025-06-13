package NumTools::Converter::Utils;

use strict;
use warnings;

use List::Util qw(sum max);
use Exporter 'import';
our @EXPORT_OK = qw(formNumbering countInsertions countInsertionsCdr3 convertRegion filterGaps formNumberingCdr3 countInsertionOffset);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

use constant {INSERTIONLESS_END => 2};  #INSERTIONLESS_END source: https://www.imgt.org/IMGTScientificChart/Numbering/CDR3-IMGTgaps.html

sub formNumberingCdr3
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

sub formNumbering
{
    my ($numbering_start, $numbering_end,
        $insertion_count, $insertions_position,
        $ins_vector) = @_;
        
    my @numbering;
    my $num = $numbering_start - 1;
    my $ins_code = 65;
    for my $insertion (@$ins_vector)
    {
        if(!$insertion) # 1 - insertion, 0 - non-insertion
        {
            if($num == $insertions_position and $insertion_count)
            {
                my $scheme_insetion_letter = lc(chr($ins_code));
                push @numbering, $num . " " . $scheme_insetion_letter;
                $ins_code += 1;
                $insertion_count -= 1;
            }
            else
            {
                $num += 1;
                push @numbering, $num;
                $ins_code = 65;
            }
        }
        else
        {
            my $unusual_insertion_letter = lc(chr($ins_code));
            push @numbering, $num . " " . $unusual_insertion_letter;
            $ins_code += 1;
        }
    }
    return @numbering;
}


sub countInsertions
{
    my ($max_esential_resiudes, $current_region_length,
                                $aditional_ins_count) = @_;
    return max(0, $current_region_length - $max_esential_resiudes - $aditional_ins_count)
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

sub filterGaps
{
    my ($numbered_seq_ref, $numbering_ref) = @_;
    my @seq = @{$numbered_seq_ref};
    my @num = @{$numbering_ref};
    
    my (@filtered_seq, @filtered_num);
    for my $i (0 .. $#seq)
    {
        if ($seq[$i] ne '-')
        {
            push @filtered_seq, $seq[$i];
            push @filtered_num, $num[$i];
        }
    }

    return (\@filtered_seq, \@filtered_num);
}

sub countInsertionOffset
{
    my ($ins_vector, $start, $end) = @_;

    my $offset = 0;
    while (1)
    {
        my $ins_count = sum @{ $ins_vector }[ $start .. $end + $offset ];
        last if $ins_count == $offset;
        $offset = $ins_count;
    }
    return $offset;
}

1;
