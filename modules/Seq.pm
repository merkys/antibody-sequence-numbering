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
			organism => $domain_ref-> {organism},
			score	=> $domain_ref-> {score},
			bias	=> $domain_ref-> {bias},
			FRs	=> [],
			CDRs	=> [],
			aligned_seq	=> '',
			fixed_seq	=> '',
			insertion_count	=> '',
			imgt_numbering	=> ''
			};
	return bless $self, $class;
}


sub getDomain
{
	my ($self) = @_;
	return $self -> {domain}
}

sub getOrganism
{
	my ($self) = @_;
	return $self -> {organism}
}

sub getSeq
{
	my ($self) = @_;
	return $self -> {seq}
}

sub getId
{
	my ($self) = @_;
	return $self -> {id}
}

sub getHeader
{
	my ($self) = @_;
	return $self -> {header}
}

sub addFr
{
	my ($self, $fr) = @_;
	push @{$self -> {FRs}}, $fr; 
}

sub getFr
{
	my ($self, $index) = @_;
	return $self -> {FRs}[$index]
}

sub addCdr
{
	my ($self, $cdr) = @_;
	push @{$self -> {CDRs}}, $cdr; 
}

sub getCdr
{
	my ($self, $index) = @_;
	return $self -> {CDRs}[$index]
}

sub setAlignedSeq
{
	my ($self, $aligned_seq) = @_;
	$self -> {aligned_seq} = $aligned_seq;
}

sub getAlignedSeq
{
	my ($self) = @_;
	return $self -> {aligned_seq}
}

sub setFixedSeq
{
	my ($self, $fixed_seq) = @_;
	$self -> {fixed_seq} = $fixed_seq;
}

sub getFixedSeq
{
	my ($self) = @_;
	return $self -> {fixed_seq}
}

sub setInsertionCount
{
	my ($self, $insertion_count) = @_;
	return $self -> {insertion_count} = $insertion_count;
}

sub getInsertionCount
{
	my ($self) = @_;
	return $self -> {insertion_count}
}

sub setImgtNumbering
{
	my ($self, $numbering_ref) = @_;
	$self -> {imgt_numbering} = $numbering_ref;
}

sub getImgtNumbering
{
	my ($self) = @_;
	return $self -> {imgt_numbering}
}

1;
