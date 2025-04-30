package IMGT_Utils::Alignment;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(fixAlignment fixLowContextZones);


use constant { FR1_END   => 26,
               CDR1_END  => 38,
               FR2_END   => 55,
               CDR2_END  => 65,
               FR3_END   => 104,
               CDR3_END  => 117,
               TOTAL_LEN => 128 };

use constant { CDR1_MAX_LEN => 12,
               CDR2_MAX_LEN => 10,
               CDR3_MAX_LEN => 13 };

sub fixAlignment
{
    my ($seq) = @_;
    my $seq_ref = fixRareInsertions($seq);
    return fixCdr3Zone($seq_ref);
}


sub fixCdr3Zone
{
    my ($seq_ref) = @_;

    my @cdr3 = @{ $seq_ref }[ FR3_END .. CDR3_END - 1 ];
    my $aa_count = grep { $_ ne '-' } @cdr3;

    return $seq_ref if $aa_count == CDR3_MAX_LEN;

    my $aligned_len = @{ $seq_ref };
    my $fr4_len     = TOTAL_LEN - CDR3_END;               
    my $tail_len    = $aligned_len - (CDR3_END);     
    my $ins_to_fix  = $tail_len - $fr4_len;
       $ins_to_fix  = 0 if $ins_to_fix < 0;

    
    for ( my $i = CDR3_END - 1; $i >= FR3_END && $ins_to_fix > 0; $i-- )
    {
        if ( $seq_ref->[$i] eq '-' )
        {
            splice( @{ $seq_ref }, $i, 1 );
            $ins_to_fix--;
        }
    }
    return $seq_ref;
}

sub fixRareInsertions
{
    my ($seq) = @_;
    my $last_gap_pos = undef;
    my @seq = @{ $seq };
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
