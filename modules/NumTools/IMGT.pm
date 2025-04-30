package NumTools::IMGT;

use strict;
use warnings;
use Exporter 'import';
use POSIX qw(ceil);

use IMGT_Utils::Alignment qw(fixAlignment fixLowContextZones);
use IMGT_Utils::Cdr qw(fixCdrS);
use IMGT_Utils::Numbering qw(formNumbering);

our @EXPORT_OK = qw(numberSeq);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

sub numberSeq
{
    my ($seq_obj, $error_fix_mode) = @_;
    $seq_obj->setAlignedSeq(fixLowContextZones($seq_obj->getAlignedSeq(), $seq_obj->getSeq())) if $error_fix_mode eq 'fit';
    my $fixed_seq_ref = fixAlignment($seq_obj->getAlignedSeq());
       $fixed_seq_ref = fixCdrS($fixed_seq_ref);
    my $numbering_ref = formNumbering($fixed_seq_ref);
    
    return $fixed_seq_ref, $numbering_ref
}


1;
