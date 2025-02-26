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
	#my @fr1 = @seq[0..25];
	#my @fr2 = @seq[38..54];
	#my @fr3 = @seq[65..103];
	#my @fr4 = @seq[117..$#seq];
	#my @cdr1 = @seq[26..37];
	#my @cdr2 = @seq[55..64];
	#my @cdr3 = @seq[104..116];
	my $output ='';
	my $num_index = 0;
	for( my $i = 0; $i < @seq; $i++)
	{
		next if $i == 9 or $i ==38 or $i == 39 or $i == 72;
		if($i == 36 and $seq[$i] ne '-')
		{
			$output .= $seq[$i] . "\t$num_index a\n";
			next;
		}
		if($i == 37 and $seq[$i] ne '-')
		{
			$output .= $seq[$i] . "\t$num_index b\n";
			next;
		}
		
		if($i == 57 and $seq[$i] ne '-')
		{
			$output .= $seq[$i] . "\t$num_index a\n";
			next;
		}
		if($i == 58 and $seq[$i] ne '-')
		{
			$output .= $seq[$i] . "\t$num_index b\n";
			next;
		}
		if($i == 59 and $seq[$i] ne '-')
		{
			$output .= $seq[$i] . "\t$num_index c\n";
			next;
		}
		$num_index++;
		$output .= $seq[$i] . "\t$num_index\n";
		
	}
	
	return $output
}


1;
