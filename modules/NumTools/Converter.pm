package NumTools::Converter;
use strict;
use warnings;
use Exporter 'import';
use Converter::Kabat qw(convertToKabat);
use Converter::Chothia qw(convertToChothia);

our @EXPORT_OK = qw(convertImgt);

sub convertImgt
{
    my ($seq, $domain, $scheme, $if_filter_gaps) = @_;
    return convertToKabat($seq, $domain, $if_filter_gaps) if $scheme eq 'kabat';
    return convertToChothia($seq, $domain, $if_filter_gaps) if $scheme eq 'chothia';
}

1;
