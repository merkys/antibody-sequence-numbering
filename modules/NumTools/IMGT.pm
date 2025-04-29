package NumTools::IMGT;

use strict;
use warnings;
use Exporter 'import';
use POSIX qw(ceil);

our @EXPORT_OK = qw(numberSeq);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

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

sub numberSeq
{
    my ($seq_obj, $error_fix_mode) = @_;
    $seq_obj->setFixedSeq(fixAlignment($seq_obj->getAlignedSeq(),
                                       $seq_obj->getSeq(), $error_fix_mode));
    my @fixed_array = split('', $seq_obj->getFixedSeq());
    $seq_obj->setInsertionCount(checkInsertion(\@fixed_array));
    $seq_obj->setImgtNumbering(formNumbering($seq_obj->getFixedSeq(), $seq_obj->getInsertionCount()));
    
    return $seq_obj->getFixedSeq(), $seq_obj -> getImgtNumbering()
}

sub checkInsertion
{
    my ($seq) = @_;
    my $tillTheEnd_length =  length(join("", @{ $seq }[ FR3_END .. (scalar(@{$seq}) - 1) ]));
    my $insertion_count = 0;
    if($tillTheEnd_length > 24)
    {
	    #print $tillTheEnd_length . "\n";
        $insertion_count = $tillTheEnd_length - 24;
        #print $insertion_count . "\n";
    }
	
    return $insertion_count
}

sub fixAlignment
{
    my ($seq, $original_seq, $error_fix_mode) = @_;
    fixLowContextZones($seq, $original_seq) if $error_fix_mode eq 'fit';
    my @seq = fixRareInsertions($seq);
    @seq = fixCdr3Zone(\@seq);
    my $cdr1 = fixCdr([@seq[FR1_END..CDR1_END - 1]], CDR1_MAX_LEN);
    my $cdr2 = fixCdr([@seq[FR2_END..CDR2_END - 1]], CDR2_MAX_LEN);
    my $tillTheEnd_length = length(join("", @seq[FR3_END..$#seq]));
    my $cdr3 = checkInsertion([ @seq[FR3_END..$#seq] ])
        ? join('', @seq[FR3_END..CDR3_END - 1])
        : fixCdr([@seq[FR3_END..CDR3_END - 1]], CDR3_MAX_LEN);
	
    my $seq_str = join('', @seq);

    my $fixed_seq = substr($seq_str, 0,        FR1_END)                 
                  . $cdr1                                                      
                  . substr($seq_str, CDR1_END, FR2_END - CDR1_END)       
                  . $cdr2                                                      
                  . substr($seq_str, CDR2_END, FR3_END - CDR2_END)        
                  . $cdr3
                  . substr($seq_str, CDR3_END);
    #print length($fixed_seq) . "\n";
    return $fixed_seq
}


sub fixCdr3Zone
{
    my ($seq_ref) = @_;

    my @cdr3 = @{ $seq_ref }[ FR3_END .. CDR3_END - 1 ];
    my $aa_count = grep { $_ ne '-' } @cdr3;

    return @{ $seq_ref } if $aa_count == CDR3_MAX_LEN;

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

    return @{ $seq_ref };
}


sub fixLowContextZones
{
    my ($aligned_seq, $original_seq) = @_;
    my $start_gaps = 0;
    for my $residue (@$aligned_seq)
    {
        last if $residue ne '-';
        $start_gaps++;
    }
    return 1 if $start_gaps == 0;
    my @morif = @{ $aligned_seq}[$start_gaps .. $start_gaps + 3];
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
    @{ $aligned_seq }[$stable_gaps .. $start_gaps - 1 ] = @{ $original_seq }[$left_index .. $right_index];
}

sub fixRareInsertions
{
    # Function for insertion fix in FR regions
    my ($seq) = @_;
    my $last_gap_pos = undef;
    my @seq = @{ $seq };
    for(my $i = 0; $i < 104; $i++)
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
    return @seq	
}

sub fixCdr
{
    my ($cdr_ref, $cdr_max_length) = @_;
    
    my @no_gap_seq = grep { $_ ne '-' } @{ $cdr_ref };
    my $cdr_current_length = scalar(@no_gap_seq);
    die "CDR length ($cdr_current_length) exceeds max ($cdr_max_length)"
        if $cdr_current_length > $cdr_max_length;
        
    return "-" x $cdr_max_length if $cdr_current_length == 0;
    return join("", @no_gap_seq) if $cdr_max_length == $cdr_current_length;
	
    my $left_part = ceil($cdr_current_length/2);
    my $right_part = $cdr_current_length - $left_part;
    my $gaps_part = $cdr_max_length - $right_part - $left_part;
    my @fixed_cdr;

    push @fixed_cdr, @no_gap_seq[ 0..$left_part - 1];
    push @fixed_cdr, ('-') x $gaps_part;
    push @fixed_cdr, @no_gap_seq[ $left_part .. ($left_part + $right_part - 1) ];

    return join("", @fixed_cdr);
}


sub formNumbering
{
    my ($seq, $insertion_count) = @_;
    return [1..128] if $insertion_count == 0;
	
    my @numbering = (1..111);
    if($insertion_count != 0)
    {
        my $insertion_right = ceil($insertion_count/2);
        my $insertion_left = $insertion_count - $insertion_right;
        push @numbering, map { "111 " . lc(chr(65 + $_)) } (0 .. $insertion_left - 1);
        push @numbering, map { "112 " . lc(chr(64 + $insertion_right - $_)) } (0 .. $insertion_right - 1);
    }
    push @numbering, (112..128);
	
    return \@numbering
}
1;
