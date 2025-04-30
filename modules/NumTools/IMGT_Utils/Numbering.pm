package IMGT_Utils::Numbering;

use strict;
use warnings;
use POSIX qw(ceil);
use Exporter 'import';
our @EXPORT_OK = qw(formNumbering);

use constant { FR1_END   => 26,
               CDR1_END  => 38,
               FR2_END   => 55,
               CDR2_END  => 65,
               FR3_END   => 104,
               CDR3_END  => 117,
               TOTAL_LEN => 128 };

use constant {NUMBERING_START => 1,
              NUMBERING_END   => 128};

use constant {INSERTION_START => 111,
              INSERTION_END   => 112,
              WITHOUT_INS_LEN => 24};

sub formNumbering
{
    my ($seq) = @_;
    my $insertion_count = checkInsertion($seq);
    return [ NUMBERING_START .. NUMBERING_END ] if not $insertion_count;
	
    my @numbering = ( NUMBERING_START .. INSERTION_START);
    my $insertion_right = ceil($insertion_count/2);
    my $insertion_left = $insertion_count - $insertion_right;
    push @numbering, map { INSERTION_START . ' ' . lc(chr(65 + $_)) } (0 .. $insertion_left - 1);
    push @numbering, map { INSERTION_END . ' ' . lc(chr(64 + $insertion_right - $_)) } (0 .. $insertion_right - 1);

    push @numbering, ( INSERTION_END .. NUMBERING_END );
	
    return \@numbering
}

sub checkInsertion
{
    my ($seq) = @_;
    my $tillTheEnd_length =  length(join("", @{ $seq }[ FR3_END .. (scalar(@{$seq}) - 1) ]));
    my $insertion_count = 0;
    if($tillTheEnd_length > WITHOUT_INS_LEN)
    {
        $insertion_count = $tillTheEnd_length - WITHOUT_INS_LEN;
    }
	
    return $insertion_count
}
