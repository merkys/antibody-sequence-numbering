package IO::PDB::Parser;

use strict;
use warnings;

use Exporter 'import';
use IO::PDB::Atom;
use List::Util qw( uniqstr );

our @EXPORT_OK = qw(readPDB readMMCIF);

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

    my @atoms;
    while (<$fh>) {
        push @atoms, IO::PDB::Atom->new( $_ ) if /^ATOM/;
    }
    close $fh;

    my @first_of_residue;
    for (@atoms) {
        next if @first_of_residue &&
                $first_of_residue[-1]->chain eq $_->chain &&
                $first_of_residue[-1]->residue_number == $_->residue_number &&
                $first_of_residue[-1]->insertion_code eq $_->insertion_code;
        push @first_of_residue, $_;
    }

    my @chains = uniqstr map { $_->chain } @atoms;
    my @sequences;
    for my $chain (@chains) {
        push @sequences, [ map  { $aa3_to_1{$_->residue_name} }
                           grep { $_->chain eq $chain }
                                @first_of_residue ];
    }

    return \@chains, \@sequences;
}

sub readMMCIF
{
    my ($cif_file) = @_;
    open my $fh, '<', $cif_file
        or die "Can't open $cif_file: $!";

    my (@loop_tags, $i_group, $i_amino, $i_res, $i_chain, $i_ins);
    my $in_loop = 0;

    my @chains;
    my @sequences;
    my $current_chain;
    my $current_res_index = 0;
    my @current_sequence;
    my $current_ins = '';
    while (<$fh>)
    {
        chomp;
        if (/^loop_/)
        {
            @loop_tags = ();
            $in_loop = 0;
            next;
        }
        if (/^\_(\S+)/)
        {
            push @loop_tags, "_$1";
            next;
        }
        if (! /^\_/ and @loop_tags)
        {
            if (grep { $_ eq '_atom_site.group_PDB' } @loop_tags)
            {
                ($i_group, $i_amino, $i_res, $i_chain, $i_ins) = map { my $tag = $_;
                    my ($idx) = grep { $loop_tags[$_] eq $tag } 0..$#loop_tags;
                    $idx}
                          qw(_atom_site.group_PDB
                             _atom_site.label_comp_id
                             _atom_site.label_seq_id
                             _atom_site.auth_asym_id
                             _atom_site.pdbx_PDB_ins_code);
                $in_loop = 1;
            }
            else
            {
                $in_loop = 0;
            }
        }

        if ($in_loop)
        {
            my @F = split;
            next unless $F[$i_group] eq 'ATOM';
            my $new_chain     = $F[$i_chain];
            my $new_res_index = $F[$i_res] + 0;
            my $amino_code    = $F[$i_amino];
            my $new_ins       = $F[$i_ins] || '';
            
            $current_chain = $new_chain if not $current_chain;
            
            if ($new_chain ne $current_chain)
            {
                push @chains,    $current_chain;
                push @sequences, [ @current_sequence ];
                @current_sequence = ();
                $current_chain   = $new_chain;
            }
            if ($new_res_index != $current_res_index or $current_ins ne $new_ins)
            {
                push @current_sequence, $aa3_to_1{$amino_code} || 'X';
                $current_res_index = $new_res_index;
                $current_ins = $new_ins;
            }
        }
    }

    if (defined $current_chain)
    {
        push @chains,    $current_chain;
        push @sequences, [ @current_sequence ];
    }

    close $fh;
    return \@chains, \@sequences;
}

1;
