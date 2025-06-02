package IO::FastaParser;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(readFasta);

sub readFasta
{
	my ($record) = @_;
	my ($header, @seq_lines) = split(/\n/, $record);
	my $seq = join('', @seq_lines);
	my @residue = split('', $seq);
       
	my $id = $header;
	if ($id =~ /^(\S+)/)
	{
		$id = $1;
	}

	return {header => $header, seq => \@residue, id =>$id};
}
1;
