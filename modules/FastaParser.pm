package FastaParser;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(readFasta);

sub readFasta
{
	my ($fastaFile) = @_;
	
	my @sequences;
	my ($current_header, $current_seq) = ('','');
	
	open(my $fasta_fh, "<", $fastaFile)
		or die "Could not open fasta file: $fastaFile";
		
	while(my $line = <$fasta_fh>)
	{
		chomp($line);
		next if $line =~ /^\s*$/;
		if($line =~ /^>(.+)/)
		{
			push @sequences, {
						header => $current_header,
						seq => $current_seq
					} if $current_seq;
			$current_header = $1;
			$current_seq = '';
		}
		else
		{
			$current_seq .= $line;
		}
	}
	
	push @sequences, {
				header => $current_header,
				seq => $current_seq
			} if $current_seq;
	close($fasta_fh);
	return \@sequences;
}

1;
