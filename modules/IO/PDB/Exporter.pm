package IO::PDB::Exporter;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(renumberPDB);

use IO::PDB::Atom;

sub renumberPDB
{
    my ($pdb_file, $chains_ref, $numbering_ref) = @_;
    
    open my $fh, '<', $pdb_file
        or die "Could not open $pdb_file: $!";
    
    my $chain_vector_index = 0;
    my $numbering_vector_index = 0;
    
    my $output = '';
    my $current_chain = $chains_ref->[$chain_vector_index];
    my $current_res_index;
    my $current_ins;
    
    my ($numbering, $ins);
    my $if_numbering_end = 0;
    while( <$fh> ) {
        if( !/^ATOM/ ) {
            $output .= $_;
            next;
        }

        my $atom = IO::PDB::Atom->new( $_ );
        if( $atom->chain eq $current_chain ) {
            if( !defined $current_res_index || $current_res_index != $atom->residue_number ||
                !defined $current_ins || $current_ins ne $atom->insertion_code ) {
                $current_res_index = $atom->residue_number;
                $current_ins = $atom->insertion_code;
                if( $numbering_ref->[$chain_vector_index]->[$numbering_vector_index] ) {
                    ($numbering, $ins) = _parse_numbering( $numbering_ref->[$chain_vector_index]->[$numbering_vector_index] );
                    $numbering_vector_index++;
                } else {
                    $if_numbering_end = 1;
                }
            }
            if( $if_numbering_end ) {
                $numbering = $atom->residue_number;
                $ins = $atom->insertion_code;
            }
            $atom->residue_number( $numbering );
            $atom->insertion_code( $ins );
        } else {
            $chain_vector_index++;
            $numbering_vector_index = 0;
            $current_chain = $atom->chain;
            $if_numbering_end = 0;
        }

        $output .= $_;
    }

    close $fh;
    return $output
}

sub _parse_numbering
{
    my ($numbering_unit) = @_;
    $numbering_unit =~ /^(\d+)\s*([A-Za-z])?$/;
    my $number = $1;
    my $insertion = $2 || ' ';
    return $number, $insertion
}

1;
