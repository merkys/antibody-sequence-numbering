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
    my $self = shift;
    return 0 + substr $self->{line}, 22, 4;
}

sub insertion_code
{
    my $self = shift;
    return substr $self->{line}, 26, 1;
}

1;
