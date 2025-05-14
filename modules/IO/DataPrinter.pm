package IO::DataPrinter;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(generateStandartOut);

sub generateStandartOut
{
    my ($header, $sequence, $domain, $organism, $numbering_ref) = @_;
    $header =~ s/>//;
    my $outputText ="# Domain: $domain\n# Organism: $organism\n# Sequence: $header\n";
    my @seq = @{ $sequence };
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
