package IO::PDB::Exporter;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(renumberPDB);


sub renumberPDB
{
    my ($pdb_file, $chains_ref, $numbering_ref) = @_;
    
    open my $fh, '<', $pdb_file
        or die "Could not open $pdb_file: $!";
    
    my $chain_vector_index = 0;
    my $numbering_vector_inddex = 0;
    
    my $output ='';
    my $current_chain = $chains_ref->[$chain_vector_index];
    my $current_res_index = 0;
    my $current_ins = "";
    
    my ($numbering, $ins);
    my $if_numbering_end = 0;
    while(<$fh>)
    {
        if( $_ !~ /^ATOM/ )
        {
            $output .= $_;
            next;
        }
        my ($chain_id, $res_index, $res_ins) = unpack("x21 A1 A4 A1", $_);
        $res_index += 0;
        if($chain_id eq $current_chain)
        {
            if( $current_res_index != $res_index or $current_ins ne $res_ins)
            {
                $current_res_index = $res_index;
                $current_ins = $res_ins;
                if($numbering_ref->[$chain_vector_index]->[$numbering_vector_inddex])
                {
                    ($numbering, $ins) = _parse_numbering($numbering_ref->[$chain_vector_index]->[$numbering_vector_inddex]);
                    $numbering_vector_inddex++;
                }
                else
                {
                    $if_numbering_end = 1;
                }
            }
            if( $if_numbering_end )
            {
                $numbering = $res_index;
                $ins = $res_ins;
            }
            substr($_, 22, 4) = sprintf("%4d", $numbering);
            substr($_, 26, 1) = $ins;
        }
        else
        {
            $chain_vector_index++;
            $numbering_vector_inddex = 0;
            $current_chain = $chain_id;
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
