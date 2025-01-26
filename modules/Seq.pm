package Seq;

use strict;
use warnings;

sub new
{
	my ($class, $seq_ref, $domain_ref) = @_;
	my $self = {
			seq 	=> $seq_ref-> {seq},
			header 	=> $seq_ref-> {header},
			id 	=> $seq_ref-> {id},
			domain 	=> $domain_ref-> {domain},
			tLen	=> $domain_ref-> {tLen},
			qLen 	=> $domain_ref-> {qLen},
			e_value	=> $domain_ref-> {e_value},
			score	=> $domain_ref-> {score},
			bias	=> $domain_ref-> {bias},
			acc	=> $domain_ref-> {acc}
			};
	return bless $self, $class;
}


sub getDomain
{
	my ($self) = @_;
	return $self -> {domain}
}

sub getSeq
{
	my ($self) = @_;
	return $self -> {seq}
}


1;
