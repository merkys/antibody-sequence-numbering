package NumTools::Converter::Kabat;

use strict;
use warnings;
use Exporter 'import';
use NumTools::Converter::Utils qw(:ALL);

our @EXPORT_OK = qw(convertToKabat);
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

#Below are the resources where you can see the origin of the essential_residues values.
#Essential_residues refers to the number of mandatory residues defined by a particular scheme.
#This number does not account for structural gaps or insertions.
#If it turns out that the number of residues in the alignment is smaller than required by the scheme,
#the program will retain some gaps to ensure that the final output matches the specific numbering scheme.
#cdr1 https://www.imgt.org/IMGTScientificChart/Numbering/CDR1-IMGTgaps.html
#cdr2 https://www.imgt.org/IMGTScientificChart/Numbering/CDR2-IMGTgaps.html
#res_till_kabat_insetions source: https://www.imgt.org/IMGTScientificChart/Numbering/CDR3-IMGTgaps.html
#cdr1\cdr2\fr1\fr2\fr3: https://www.imgt.org/IMGTScientificChart/Numbering/IMGT-Kabat_part1.html
#It is important to note that the correct count of essential residues must be calculated based on
#the region specified in the program (region_start and region_end), since region indices do not always match
#the CDR/FR boundaries defined in IMGT. This approach was implemented to simplify the calculation of insertions.
#For example, in the Kabat scheme, insertions in heavy chain CDR1 are not accounted for within
#the IMGT-defined CDR1, as they extend beyond it and are described as part of FR2. In other words,
#this method anticipates such cases and facilitates accurate residue and insertion counting.

my %KabatTypes = (                  #FR1   CDR1  FR2    CDR2   FR3    CDR3   FR4      Information                   Source of information
  IGL => {
    region_starts                => [ 0,     26, 40,    55,    65,    104,   117   ], # Region Start Indices,       IMGT
    region_ends                  => [ 25,    39, 54,    64,    103,   116,   127    ], # Region END   Indices,       IMGT
    numbering_start              => [ 1,     27, 35,    50,    53,    89,    98    ], # Region Start Indices,       KABAT
    numbering_end                => [ 26,    34, 49,    52,    88,    97,    107   ], # Region END   Indices,       KABAT
    insertion_positions          => [ 0,     27,  0,     0,     0,    95,    106   ], # Region Insertions positions,KABAT
    esenntial_residues_count     => [ 26,    8,   15,    3,     36,    9,    10    ],
    res_till_kabat_insetions     => 7,
  },
  IGK => {                           #FR1   CDR1  FR2    CDR2   FR3    CDR3   FR4
    region_starts                => [ 0,     26,  40,    55,    65,    104,   117  ],
    region_ends                  => [ 25,    39,  54,    64,    103,   116,   127   ],
    numbering_start              => [ 1,     27,  35,    50,    53,    89,    98    ],
    numbering_end                => [ 26,    34,  49,    52,    88,    97,    107   ],
    insertion_positions          => [ 0,     27,  0,     0,     0,     95,    106   ],
    esenntial_residues_count     => [ 26,    8,   15,    3,     36,    9,     10    ],
    res_till_kabat_insetions     => 7,
  },
  IGH => {                           #FR1   CDR1  FR2    CDR2   FR3    CDR3   FR4
    region_starts                => [ 0,     26,  40,    55,     65,    104,   117   ],
    region_ends                  => [ 25,    39,  54,    64,     103,   116,   127    ],
    numbering_start              => [ 1,     26,  36,    51,     58,    93,    103   ],
    numbering_end                => [ 25,    35,  50,    57,     92,    102,   113   ],
    insertion_positions          => [ 0,     35,  0,     52,     82,    100,   0     ],
    esenntial_residues_count     => [ 25,    10,  15,    7,      35,    10,    11    ],
    res_till_kabat_insetions     => 8,
  }
);

my @region_names = qw(fr1 cdr1 fr2 cdr2 fr3 cdr3 fr4);

sub convertToKabat
{
    my ($seq_ref, $ins_ref, $ig_type_key, $if_filter_gaps) = @_;
    my $type_info = $KabatTypes{$ig_type_key}
        or die "Unknown type '$ig_type_key'\n";
    my @seq = @$seq_ref;
    my @converted;
    my @numbering;
    my $ignore_start_gaps = 3;
    my $end_offset = 0;
    my $start_offset = 0;
    for my $i (0 .. $#region_names)
    {
        my $offset = countInsertionOffset($ins_ref, $type_info->{region_starts}[$i] + $start_offset,
                                       $type_info->{region_ends}[$i] + $end_offset) if $region_names[$i];
        $end_offset += $offset;
        my $region_start = $type_info->{region_starts}[$i] + $start_offset;
        my $region_end = $type_info->{region_ends}[$i] + $end_offset;
        my @region = @seq[ $region_start .. $region_end ];
        my @region_ins_vector = @$ins_ref[ $region_start .. $region_end ];
        my $good_idx_ref = convertRegion(\@region,
                                          $type_info->{esenntial_residues_count}[$i],
                                          $ignore_start_gaps);
                                          
        $ignore_start_gaps = 0;
        @region = @region[@$good_idx_ref];
        @region_ins_vector = @region_ins_vector[@$good_idx_ref];
        my $insertions = 0;
        if ($region_names[$i] =~ /cdr1|cdr2|fr3/)
        {
            $insertions = countInsertions($type_info->{esenntial_residues_count}[$i],
                                          scalar(@region),
                                          $offset);
        }
        elsif ($region_names[$i] eq 'cdr3')
        {
            $insertions = countInsertionsCdr3(\@region, 
                                              $type_info->{res_till_kabat_insetions});
        }
        if ($region_names[$i] eq 'cdr3')
        {
            push @numbering, formNumberingCdr3($type_info->{numbering_start}[$i],
                                           $type_info->{numbering_end}[$i],
                                           $insertions,
                                           $type_info->{insertion_positions}[$i]);
        }
        else
        {
            push @numbering, formNumbering($type_info->{numbering_start}[$i],
                                               $type_info->{numbering_end}[$i],
                                               $insertions,
                                               $type_info->{insertion_positions}[$i],
                                               \@region_ins_vector);
        }
        $start_offset += $offset;
        push @converted, @region;
    }
    if( $if_filter_gaps ) {
        my ($f_converted, $f_numbering) = filterGaps( \@converted, \@numbering );
        @converted = @$f_converted;
        @numbering = @$f_numbering;
    }
    return \@converted, \@numbering;
}

1;
