package IMGT_Utils::Numbering;

use strict;
use warnings;
use POSIX qw(ceil);
use List::Util qw(sum);
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

use constant {A_CHAR_CODE => 65};

sub formNumbering
{
    my ($seq, $ins_vector, $ins_offset) = @_;
    return [ NUMBERING_START .. NUMBERING_END ] if sum(@$ins_vector) == 0;
	
    my @numbering;
    my $index = NUMBERING_START - 1;
    my $ins_code = A_CHAR_CODE;
    for( my $i = 0; $i < INSERTION_START + $ins_offset; $i++)
    {
    	if($ins_vector->[$i])
    	{
    	    push @numbering, $index . " " . lc(chr($ins_code));
    	    $ins_code++;
    	}
    	else
    	{
            $index++;
    	    push @numbering, $index;
    	    $ins_code = A_CHAR_CODE;
    	}
    }
    my $cdr_3_ins = _countInsertions($ins_vector, FR3_END + $ins_offset);
    if( $cdr_3_ins == 0)
    {
        push @numbering, ( $index + 1 .. NUMBERING_END );
        return \@numbering;
    }
    
    my $insertion_right = ceil($cdr_3_ins/2);
    my $insertion_left = $cdr_3_ins - $insertion_right;
    push @numbering, map { INSERTION_START . ' ' . lc(chr(65 + $_)) } (0 .. $insertion_left - 1);
    push @numbering, map { INSERTION_END . ' ' . lc(chr(64 + $insertion_right - $_)) } (0 .. $insertion_right - 1);
    push @numbering, ( INSERTION_END .. NUMBERING_END );
    return \@numbering
}

sub _countInsertions
{
    my ($ins_vector, $start) = @_;	
    return sum(@$ins_vector[ $start .. $#$ins_vector ])
}
