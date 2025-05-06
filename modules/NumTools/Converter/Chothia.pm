package Converter::Chothia;

use strict;
use warnings;
use Exporter 'import';

use Converter::Utils qw(convertRegion countInsertions countInsertionsCdr3 formNumbering);

our @EXPORT_OK   = qw(convertToChothia);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

#res_till_kabat_insetions source: https://www.imgt.org/IMGTScientificChart/Numbering/CDR3-IMGTgaps.html
my %CothiaTypes = (
    IGL => {
        region_starts                => [ 0,     26, 40,    55,    65,    104,   -11   ], # Region Start Indices,       IMGT
        region_ends                  => [ 25,    39, 54,    64,    103,   'END', -1    ], # Region END   Indices,       IMGT
        numbering_start              => [ 1,     27, 35,    50,    53,    89,    98    ], # Region Start Indices,       CHOTHIA
        numbering_end                => [ 26,    34, 49,    52,    88,    97,    107   ], # Region END   Indices,       CHOTHIA
        regions_max_length           => [ 26,    14, 15,    10,    39,    undef, 11    ], # Region Length,              IMGT
        region_insertions_count      => [ 0,     3,  0,     0,     0,     0,     0     ], # Region Insertions Count,    CHOTHIA
        region_structural_gaps_count => [ 0,     3,  0,     7,     3,     4,     1     ], # Res untill Structural Gaps, Stockholm file 
        residues_till_struct_gap     => [ 9,     1,  0,     0,     7,     0,     0     ], # Res untill Structural Gaps, Stockholm file 
        insertion_positions          => [ undef, 30, undef, undef, undef, 95,    undef ], # Region Insertions positions,CHOTHIA
        res_till_chothia_insetions   => 7,
    },
    IGK => {
        region_starts                => [ 0,     26, 40,    55,    65,    104,   -11   ], # Region Start Indices,       IMGT
        region_ends                  => [ 25,    39, 54,    64,    103,   'END', -1    ], # Region END   Indices,       IMGT
        numbering_start              => [ 1,     27, 35,    50,    53,    89,    98    ], # Region Start Indices,       CHOTHIA
        numbering_end                => [ 26,    34, 49,    52,    88,    97,    107   ], # Region END   Indices,       CHOTHIA
        regions_max_length           => [ 26,    14, 15,    10,    39,    undef, 11    ], # Region Length,              IMGT
        region_insertions_count      => [ 0,     5,  0,     0,     0,     0,     0     ], # Region Insertions Count,    CHOTHIA
        region_structural_gaps_count => [ 0,     1,  0,     7,     3,     4,     1     ], # Res untill Structural Gaps, Stockholm file 
        residues_till_struct_gap     => [ 0,     0,  0,     0,     7,     0,     0     ], # Res untill Structural Gaps, Stockholm file 
        insertion_positions          => [ undef, 30, undef, undef, undef, 95,    undef ], # Region Insertions positions,CHOTHIA
        res_till_chothia_insetions   => 7,
    },
    IGH => {
        region_starts                => [ 0,     26,  40,    55,     65,   104,    -11   ],
        region_ends                  => [ 25,    39,  54,    64,     103,  'END',  -1    ],
        numbering_start              => [ 1,     26,  36,    51,     58,    93,    103   ],
        numbering_end                => [ 25,    35,  50,    57,     92,    102,   113   ],
        regions_max_length           => [ 26,    14,  15,    10,     39,    undef, 11    ],
        region_insertions_count      => [ 0,     2,   0,     2,      3,     0,     0     ],
        region_structural_gaps_count => [ 1,     2,   0,     1,      1,     1,     0     ],
        residues_till_struct_gap     => [ 9,     4,   0,     2,      7,     0,     0     ],
        insertion_positions          => [ undef, 31,  undef, 52,     82,    100,   undef ],
        res_till_chothia_insetions   => 8,
    },
);

my @region_names = qw(fr1 cdr1 fr2 cdr2 fr3 cdr3 fr4);

sub convertToChothia
{
    my ($seq_ref, $ig_type_key) = @_;
    my $type_info = $CothiaTypes{$ig_type_key}
        or die "Unknown type '$ig_type_key'\n";
        
    my @seq = @$seq_ref;

    my $end_idx = scalar(@seq) - 12;
    my @region_ends = map { $_ eq 'END' ? $end_idx : $_ } @{$type_info->{region_ends}};

    my @converted_seq;
    my @chothia_numbering;

    for my $i (0 .. $#region_names)
    {
        my @region = @seq[ $type_info->{region_starts}[$i] .. $region_ends[$i] ];

        my $good_idx = convertRegion(\@region,
                                    $type_info->{region_structural_gaps_count}[$i],
                                    $type_info->{region_insertions_count}[$i],
                                    $type_info->{residues_till_struct_gap}[$i]);
        @region = @region[@$good_idx];

        my $ins_count = 0;
        if ($region_names[$i] =~ /cdr1|cdr2|fr3/)
        {
            $ins_count = countInsertions($type_info->{regions_max_length}[$i],
                                         scalar(@region),
                                         $type_info->{region_structural_gaps_count}[$i],
                                         $type_info->{region_insertions_count}[$i]);
        }
        elsif ($region_names[$i] eq 'cdr3')
        {
            $ins_count = countInsertionsCdr3(\@region,
                                             $type_info->{res_till_chothia_insetions});
        }

        push @chothia_numbering, formNumbering($type_info->{numbering_start}[$i],
                                               $type_info->{numbering_end}[$i],
                                               $ins_count,
                                               $type_info->{insertion_positions}[$i]);

        push @converted_seq, @region;
    }

    return \@converted_seq, \@chothia_numbering;
}

1;
