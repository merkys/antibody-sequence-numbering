package Structures::Seq;

use strict;
use warnings;

sub new
{
    my ($class, $seq_ref, $domain_ref) = @_;
    my $self = { seq 	  => $seq_ref-> {seq},
                 header   => $seq_ref-> {header},
                 id       => $seq_ref-> {id},
                 domain   => $domain_ref-> {domain},
                 organism => $domain_ref-> {organism},
                 score	  => $domain_ref-> {score},
                 bias	  => $domain_ref-> {bias},
                 aligned_seq	=> undef,
                 fixed_seq	=> '',
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
