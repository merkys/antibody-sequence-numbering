package NumTools::IMGT;

use strict;
use warnings;
use Exporter 'import';
use POSIX qw(ceil);


our @EXPORT_OK = qw(getSeqNumbering);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );


sub getSeqNumbering
{
    my ($seq_obj) = @_;
    $seq_obj->setInsertionCount(checkInsertion($seq_obj->getAlignedSeq()));
    $seq_obj->setFixedSeq(fixAlignment($seq_obj->getAlignedSeq(), $seq_obj->getInsertionCount()));
    $seq_obj->setImgtNumbering(numberSeq($seq_obj->getFixedSeq(), $seq_obj->getInsertionCount()));
    
    return $seq_obj->getFixedSeq(), $seq_obj -> getImgtNumbering()
}

sub checkInsertion
{
	my ($seq) = @_;
	my @seq = split('',$seq);
	my $tillTheEnd_length = length(join("", @seq[104..$#seq]));
	my $insertion_count = 0;
	if($tillTheEnd_length > 24)
	{
		$insertion_count = $tillTheEnd_length - 24;
	}
	
	return $insertion_count
}

sub fixAlignment
{
	my ($seq, $insertion_count) = @_;
	my @seq = split('',$seq);
	my $last_gap_pos = undef;
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

sub fixCdr
{
	my ($cdr_ref, $cdr_max_length) = @_;
	#my @seq = split('',$seq);
	
	#my @cdr = @seq[$cdr_start..$cdr_end];
	my $cdr_current_length = 0;
	my @no_gap_seq;
	for my $residue (@$cdr_ref)
	{
		if($residue ne "-")
		{
			$cdr_current_length++;
			push @no_gap_seq, $residue;
		}
	}
	if($cdr_current_length == 0)
	{
		return "-" x $cdr_max_length;
	}
	if($cdr_max_length == $cdr_current_length)
	{
		return join("", @no_gap_seq);
	}
	my $left_part = ceil($cdr_current_length/2);
	my $right_part = $cdr_current_length - $left_part;
	my $gaps_part = $cdr_max_length - $right_part - $left_part;
	my @fixed_cdr;
	for(my $i = 0; $i<$left_part; $i++)
	{
		push @fixed_cdr, $no_gap_seq[$i];
	}
	
	for(my $i = 0; $i<$gaps_part; $i++)
	{
		push @fixed_cdr, "-";
	}
	
	for(my $i = $left_part; $i < $left_part + $right_part; $i++)
	{
		push @fixed_cdr, $no_gap_seq[$i];
	}
	
	return join("", @fixed_cdr);
}


sub numberSeq
{
	my ($seq, $insertion_count) = @_;
	return [1..128] if $insertion_count == 0;
	
	my $index = 1;
	my $insertion_left;
	my $insertion_right;
	my @numbering = (1..111);
	if($insertion_count != 0)
	{
		$insertion_right = ceil($insertion_count/2);
		$insertion_left = $insertion_count - $insertion_right;
		for(my $i = 0; $i < $insertion_left; $i++)
		{
			push @numbering, 111 . " " . lc(chr(65 + $i));
		}
		for(my $i = 0; $i < $insertion_right; $i++)
		{
			push @numbering, 112 . " " . lc(chr(64 + $insertion_right - $i));
		}
		
	}
	for(my $i = 112; $i < 129; $i++)
	{
		my $current_num = $i;
		push @numbering, $current_num;
	}
	
	return \@numbering
}
1;
