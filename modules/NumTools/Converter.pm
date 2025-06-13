package NumTools::Converter;
use strict;
use warnings;
use Exporter 'import';
use NumTools::Converter::Kabat qw(convertToKabat);
use NumTools::Converter::Chothia qw(convertToChothia);

our @EXPORT_OK = qw(convertImgt);

sub convertImgt
{
    my ($seq, $domain, $scheme, $if_filter_gaps, $ins_vector) = @_;
    return convertToKabat($seq, $ins_vector, $domain, $if_filter_gaps) if $scheme eq 'kabat';
    return convertToChothia($seq, $domain, $if_filter_gaps) if $scheme eq 'chothia';
}

1;
