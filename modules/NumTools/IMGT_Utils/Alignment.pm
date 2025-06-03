package NumTools::IMGT_Utils::Alignment;
use strict;
use warnings;

use List::Util qw(sum);
use Exporter 'import';
our @EXPORT_OK = qw(fixAlignment fixLowContextZones detectNonTipicalInsertions);


use constant { FR1_END   => 26,
               CDR1_END  => 38,
               FR2_END   => 55,
               CDR2_END  => 65,
               FR3_END   => 104,
               CDR3_END  => 117,
               TOTAL_LEN => 128 };

use constant { CDR1_MAX_LEN => 12,
               CDR2_MAX_LEN => 10,
               CDR3_MAX_LEN => 13,
               FR4_MAX_LEN  => 11};

sub fixAlignment
{
    my ($seq, $ins_vector) = @_;
    my $seq_ref = fixRareInsertions($seq);
    return fixCdr3Zone($seq_ref, $ins_vector);
}


sub fixCdr3Zone
{
    my ($seq_ref, $insertions_vector) = @_;
    
    my $insertion_offset = sum(@$insertions_vector);
    my $FR3_fixed_end = FR3_END + $insertion_offset;
    my $CDR3_fixed_end = CDR3_END + $insertion_offset;
    my $aligned_len = @{ $seq_ref };
    my @cdr3 = @{ $seq_ref }[ $FR3_fixed_end .. $aligned_len - 1 - FR4_MAX_LEN ];
    my $aa_count = grep { $_ ne '-' } @cdr3;
    
    return $seq_ref if $aa_count == CDR3_MAX_LEN;

        
    my $tail_len    = $aligned_len - ($CDR3_fixed_end);
    my $ins_to_fix  = $tail_len - FR4_MAX_LEN;
       $ins_to_fix  = 0 if $ins_to_fix < 0;

    
    for ( my $i = $CDR3_fixed_end - 1; $i >= $FR3_fixed_end && $ins_to_fix > 0; $i-- )
    {
        if ( $seq_ref->[$i] eq '-' )
        {
            splice( @{ $seq_ref }, $i, 1 );
            $ins_to_fix--;
        }
    }
    my $fixed_insertion_start = 111 + $insertion_offset;
    my $fixed_insertion_end = $fixed_insertion_start - 1 + $ins_to_fix;
    @{$insertions_vector}[ $fixed_insertion_start .. $fixed_insertion_end ] = (1) x $ins_to_fix if $ins_to_fix > 0;
    return $seq_ref;
}

sub detectNonTipicalInsertions
{
    my ($seq) = @_;
    
    my @seq = @{ $seq };
    my $insertions_offset = 0;
    my @insertions_vector = (0) x scalar(@seq);
    for(my $i = 0; $i < FR3_END + $insertions_offset ; $i++)
	{
	    if($seq[$i] =~ /[a-z]/)
	    {
	        $insertions_offset++;
	        $insertions_vector[$i] = 1;
	    }
	}
	return \@insertions_vector
}

sub fixRareInsertions
{
    my ($seq) = @_;
    
    my $last_gap_pos = undef;
    my @seq = @{ $seq };
    return \@seq;
    for(my $i = 0; $i < FR3_END; $i++)
	{
        if($seq[$i] eq '-')
        {
            $last_gap_pos = $i;
        }
        if($seq[$i] =~ /[a-z]/)
        {
            if($last_gap_pos)
            {
                splice(@seq, $last_gap_pos, 1); 
                $i--;
                $last_gap_pos = undef;
            }
        }
    }
    return \@seq	
}


sub fixLowContextZones
{
    my ($aligned_seq, $original_seq) = @_;
    my $start_gaps = 0;
    my @fixed = @{ $aligned_seq };
    for my $residue (@$aligned_seq)
    {
        last if $residue ne '-';
        $start_gaps++;
    }
    return \@fixed if $start_gaps == 0;
    my @morif = @fixed[$start_gaps .. $start_gaps + 3];
    my $start_res_in_original_seq = 0;
    for(my $i = 0; $i < scalar @{ $original_seq } - 2; $i++)
    {
        last if @$original_seq[$i] eq $morif[0]
            and @$original_seq[$i + 1] eq $morif[1]
            and @$original_seq[$i + 2] eq $morif[2];
        $start_res_in_original_seq++;
    }
    my $left_index;
    my $right_index;
    my $stable_gaps;
    if($start_res_in_original_seq <= $start_gaps)
    {
        $left_index = 0;
        $right_index = $start_res_in_original_seq - 1;
        $stable_gaps = $start_gaps - $start_res_in_original_seq;
    }
    else
    {
        $left_index = $start_res_in_original_seq - $start_gaps;
        $right_index = $start_res_in_original_seq - 1;
        $stable_gaps = 0;
    }
    @fixed[$stable_gaps .. $start_gaps - 1 ] = @{ $original_seq }[$left_index .. $right_index];
    return \@fixed
}
1;
