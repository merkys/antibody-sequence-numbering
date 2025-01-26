package FastaParser;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(readFasta);

sub readFasta
{
	my ($record) = @_;
	my ($header, @seq_lines) = split(/\n/, $record);
	my $seq = join('', @seq_lines);

       
	my $id = $header;
	if ($id =~ /^(\S+)/)
	{
		$id = $1;
	}

	return {header => $header, seq => $seq, id =>$id};
}
1;
