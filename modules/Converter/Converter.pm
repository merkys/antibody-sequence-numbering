package Converter::Converter;

use strict;
use warnings;
use Exporter 'import';
use lib '.';
use Converter::Kabat qw(convertToKabat);
use Converter::Chothia qw(convertToChothia);

our @EXPORT_OK = qw(convertImgt);

sub convertImgt
{
    my ($seq, $domain, $scheme) = @_;
    return convertToKabat($seq, $domain) if $scheme eq 'kabat';
    return convertToChothia($seq, $domain) if $scheme eq 'chothia';
}

1;
