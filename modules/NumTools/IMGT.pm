package NumTools::IMGT;

use strict;
use warnings;
use Exporter 'import';
use POSIX qw(ceil);

our @EXPORT_OK = qw(numberSeq);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );


sub numberSeq
{
    my ($seq_obj, $error_fix_mode) = @_;
    $seq_obj->setInsertionCount(checkInsertion($seq_obj->getAlignedSeq()));
    $seq_obj->setFixedSeq(fixAlignment($seq_obj->getAlignedSeq(), $seq_obj->getInsertionCount(),
                                       $seq_obj->getSeq(), $error_fix_mode));
    $seq_obj->setImgtNumbering(formNumbering($seq_obj->getFixedSeq(), $seq_obj->getInsertionCount()));
    
    return $seq_obj->getFixedSeq(), $seq_obj -> getImgtNumbering()
}

sub checkInsertion
{
	my ($seq) = @_;
	my $tillTheEnd_length =  length(join("", @{ $seq }[ 104 .. (scalar(@{$seq}) - 1) ]));
	my $insertion_count = 0;
	if($tillTheEnd_length > 24)
	{
		$insertion_count = $tillTheEnd_length - 24;
	}
	
	return $insertion_count
}

sub fixAlignment
{
	my ($seq, $insertion_count, $original_seq, $error_fix_mode) = @_;
	fixLowContextZones($seq, $original_seq) if $error_fix_mode eq 'fit';
	my @seq = fixRareInsertions($seq);
	my $cdr1 = fixCdr([@seq[26..37]], 12);
	my $cdr2 = fixCdr([@seq[55..64]], 10);
	my $tillTheEnd_length = length(join("", @seq[104..$#seq]));
	my $cdr3;
	if($insertion_count != 0)
	{
		$cdr3 = join("",@seq[104..116]);
		
	}
	else
	{
		$cdr3 = fixCdr([@seq[104..116]], 13);
	}
	
    my $fixed_seq = join("", @seq[0..25]) 
                    . $cdr1 
                    . join("", @seq[38..54]) 
                    . $cdr2 
                    . join("", @seq[65..103]) 
                    . $cdr3 
                    . join("", @seq[117..$#seq]);
    return $fixed_seq
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
