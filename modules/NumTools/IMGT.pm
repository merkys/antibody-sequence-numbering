package NumTools::IMGT;

use strict;
use warnings;
use Exporter 'import';
use POSIX qw(ceil);
use List::Util qw(sum);
use IMGT_Utils::Alignment qw(fixAlignment fixLowContextZones detectNonTipicalInsertions);
use IMGT_Utils::Cdr qw(fixCdrS);
use IMGT_Utils::Numbering qw(formNumbering);

our @EXPORT_OK = qw(numberSeq);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

sub numberSeq
{
    my ($seq_obj, $error_fix_mode) = @_;
    $seq_obj->setAlignedSeq(fixLowContextZones($seq_obj->getAlignedSeq(), $seq_obj->getSeq())) if $error_fix_mode eq 'fit';
    my $ins_vector = detectNonTipicalInsertions($seq_obj->getAlignedSeq());
    my $adittion_len_until_cdr3 = sum(@$ins_vector);
    my $aligned_seq = $seq_obj->getAlignedSeq();
    my $fixed_seq_ref = fixAlignment($seq_obj->getAlignedSeq(), $ins_vector);
       $fixed_seq_ref = fixCdrS($fixed_seq_ref, $ins_vector);
    my $numbering_ref = formNumbering($fixed_seq_ref, $ins_vector, $adittion_len_until_cdr3);
    return $fixed_seq_ref, $numbering_ref
}


1;
