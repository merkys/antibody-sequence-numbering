package IMGT;

use strict;
use warnings;
use File::Temp qw/ tempfile /;
use Exporter 'import';
use POSIX qw(ceil);


our @EXPORT_OK = qw(findBestDomain alignToDomain checkInsertion numberSeq fixAlignment outIMGT);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

sub findBestDomain
{
	my ($seq_file) = @_;
	my ($fh, $domTblout) = tempfile();
	close($fh);
	my $hmmScanResult = qx(hmmscan --domT 100 -T 100 --domtblout $domTblout --noali ../hmms/IG_combined.hmm $seq_file);
	
	open(my $tblout_fh, "<", $domTblout)
		or die "Could not open hmmscan domain table out file: $domTblout";
	
	local $/ = "\n";
	my %sequences;
	my $bestScore = 0;
	my $bestDomain = {};
	while(my $line = <$tblout_fh>)
	{
		
		next if $line =~ /^#/;
		my @field = split(/\s+/, $line);
		my $seqInfo = {
					domain	=> $field[0],
					tLen 	=> $field[2],
					qLen 	=> $field[5],
					e_value	=> $field[6],	
					score	=> $field[7],	
					bias	=> $field[8],
					acc	=> $field[-2],
					seq	=> '',
					fullName=> ''
				};
		

		if($bestScore < $seqInfo -> {score})
		{
			$bestDomain = $seqInfo;
			$bestScore = $seqInfo -> {score};
		}
	}
	unlink $domTblout or warn "Could not unlink $domTblout: $!";
	unlink $seq_file or warn "Could not unlink $seq_file: $!";
	return $bestDomain;
}

sub alignToDomain
{
	my ($seqFile, $domain) = @_;
	my $hmmAlignResults = qx(hmmalign --outformat afa --trim ../hmms/$domain.hmm $seqFile);
	my @hmmAlignResults = split("\n", $hmmAlignResults);
	my $sequence = join("", @hmmAlignResults[1 .. $#hmmAlignResults]);
	
	return $sequence;
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
	my $cdr1 = fixCdr($seq, 26, 37, 12);
	my $cdr2 = fixCdr($seq, 55, 64, 10);
	my $tillTheEnd_length = length(join("", @seq[104..$#seq]));
	my $cdr3;
	if($insertion_count != 0)
	{
		$cdr3 = join("",@seq[104..116]);
		
	}
	else
	{
		$cdr3 = fixCdr($seq, 104, 116, 13);
	}
	
	return join("", @seq[0..25]) 
		. $cdr1 
		. join("", @seq[38..54]) 
		. $cdr2 
		. join("", @seq[65..103]) 
		. $cdr3 
		. join("", @seq[117..$#seq]);
}

sub fixCdr
{
	my ($seq, $cdr_start,$cdr_end, $cdr_max_length) = @_;
	my @seq = split('',$seq);
	
	my @cdr = @seq[$cdr_start..$cdr_end];
	my $cdr_current_length = 0;
	my @no_gap_seq;
	for my $residue (@cdr)
	{
		#print $residue;
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

sub outIMGT
{
	my ($header, $sequence, $domain, $numbering_ref) = @_;
	$header =~ s/>//;
	my $outputText ="# Domain: $domain\n# Sequence: $header\n";
	my @seq = split('', $sequence);
	if ($seq[-1] eq '-')
	{
		pop @seq;
		pop @$numbering_ref;
	}
	for(my $i = 0; $i < @seq; $i++)
	{
		$outputText .=  uc($seq[$i]) . "\t" . $numbering_ref->[$i] . "\t\n";
	}
	return $outputText . "//\n";
}

1;
