package PDB::PDBparcer;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(readPDB);

my %aa3_to_1 = (ALA => 'A',  ARG => 'R',  ASN => 'N',  ASP => 'D',
                CYS => 'C',  GLN => 'Q',  GLU => 'E',  GLY => 'G',
                HIS => 'H',  ILE => 'I',  LEU => 'L',  LYS => 'K',
                MET => 'M',  PHE => 'F',  PRO => 'P',  SER => 'S',
                THR => 'T',  TRP => 'W',  TYR => 'Y',  VAL => 'V');

sub readPDB
{
    my ($pdb_file) = @_;
    open my $fh, '<', $pdb_file
        or die "Could not open file: $pdb_file: $!";
    
    my @chains;
    my @sequences;
    
    my $current_chain;
    my $current_res_index = 0;
    my $current_ins = "";
    my @current_sequence;
    while (<$fh>)
    {
        next unless /^ATOM/;
        my ($new_chain, $new_res_index, $new_ins) = unpack("x21 A1 A4 A1", $_);
        $new_res_index += 0;
        $current_chain = $new_chain if not $current_chain;
        if($current_chain ne $new_chain)
        {
            push @chains, $current_chain;
            push @sequences, [ @current_sequence ];
            $current_chain = $new_chain;
            @current_sequence = ();
        }
        
        if( $current_res_index != $new_res_index or $current_ins ne $new_ins)
        {
            push @current_sequence, $aa3_to_1{ substr($_, 17, 3) } || 'X';
            $current_res_index = $new_res_index;
            $current_ins = $new_ins;
        }
    }
    if (defined $current_chain)
    {
        push @chains, $current_chain;
        push @sequences, \@current_sequence;
    }
    close $fh;
    return \@chains, \@sequences;
}

1;
