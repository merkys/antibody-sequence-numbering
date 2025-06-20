package IO::PDB::Atom;

use strict;
use warnings;

use overload '""' => sub { $_[0]->{line} };

sub new
{
    my( $class, $line ) = @_;
    return bless { line => $line }, $class;
}

sub chain
{
    my $self = shift;
    return substr $self->{line}, 21, 1;
}

sub residue_name
{
    my $self = shift;
    return substr $self->{line}, 17, 3;
}

sub residue_number
{
    my( $self, $number_new ) = @_;
    my $number = 0 + substr $self->{line}, 22, 4;
    if( defined $number_new ) {
        substr( $self->{line}, 22, 4 ) = sprintf '% 4d', $number_new;
    }
    return $number;
}

sub insertion_code
{
    my( $self, $code_new ) = @_;
    my $code = substr $self->{line}, 26, 1;
    substr( $self->{line}, 26, 1 ) = $code_new if defined $code_new;
    return $code;
}

1;
