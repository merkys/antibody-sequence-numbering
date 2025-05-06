package IMGT_Utils::Cdr;

use strict;
use warnings;
use POSIX qw(ceil);
use Exporter 'import';
our @EXPORT_OK = qw(fixCdrS);


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
               
       
       
sub fixCdrS
{
    my ($fixed_seq_ref) = @_;
    my $clone_ref = [ @{$fixed_seq_ref} ];

    splice @$clone_ref,
        FR1_END, CDR1_END - FR1_END,
        fixCdr([ @$clone_ref[FR1_END..CDR1_END-1] ], CDR1_MAX_LEN);
    
    
    splice @$clone_ref,
        FR2_END, CDR2_END - FR2_END,
        fixCdr([ @$clone_ref[FR2_END..CDR2_END-1] ], CDR2_MAX_LEN);

    splice @$clone_ref,
        FR3_END, CDR3_END - FR3_END,
        fixCdr([ @$clone_ref[FR3_END..CDR3_END-1] ], CDR3_MAX_LEN);
    
    return $clone_ref;
}
     
        
sub fixCdr
{
    my ($cdr_ref, $cdr_max_length) = @_;
    
    my @no_gap_seq = grep { $_ ne '-' } @{ $cdr_ref };
    my $cdr_current_length = scalar(@no_gap_seq);
    die "CDR length ($cdr_current_length) exceeds max ($cdr_max_length)"
        if $cdr_current_length > $cdr_max_length;
        
    return (('-') x $cdr_max_length) if $cdr_current_length == 0;

    return @no_gap_seq if $cdr_current_length == $cdr_max_length;
	
    my $left_part = ceil($cdr_current_length/2);
    my $right_part = $cdr_current_length - $left_part;
    my $gaps_part = $cdr_max_length - $right_part - $left_part;

    return (@no_gap_seq[ 0 .. $left_part-1 ],
            ('-') x $gaps_part,
            @no_gap_seq[ $left_part .. $left_part+$right_part-1 ]);
}
