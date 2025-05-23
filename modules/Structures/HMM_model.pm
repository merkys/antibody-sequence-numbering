package Structures::HMM_model;

use strict;
use warnings;
use Structures::Seq;
use File::Temp qw(tempfile);
use List::Util qw(reduce);

sub new
{
    my ($class, $seq_ref) = @_;
    
    my $tmp_fasta = writeFastaToTMP($seq_ref->{id}, $seq_ref->{seq});
    my $hmm_scan_out = runHmmScan($tmp_fasta);
    my $parced_data = parceDomainHits($hmm_scan_out);
    my $target_organism = findBestOrganism($parced_data);
    my $sequences = detectSequences($parced_data, $target_organism);
    my @seq_objects;
    for my $seq (@$sequences)
    {
        my $from = $seq->{start} - 1;
        my $to = $seq ->{end} - 1;
        my @sub_seq = @{ $seq_ref->{seq} }[ $from .. $to ];
        my $sub_seq_ref = { header => $seq_ref->{header},
                            seq    => \@sub_seq,
                            id     => $seq_ref->{id}};
                            
        my $domain_ref = { domain   => $seq->{domain},
                           organism => $target_organism,
                           score	=> $seq->{score},
                           bias	    => $seq->{bias}};
        
        push @seq_objects, Structures::Seq->new($sub_seq_ref, $domain_ref);
    }
    
    my $self = { original_seq => $seq_ref->{seq},
                 header       => $seq_ref->{header},
                 id           => $seq_ref->{id},
                 sequences    => \@seq_objects};
                 
    for my $seq (@{ $self->{sequences} })
    {
        $seq->setAlignedSeq(alignToDomain($seq->getId(), $seq->getSeq(),
                                      $seq->getDomain(), $seq->getOrganism()));
    }
    return bless $self, $class;
}


sub getSequences
{
    my ($self) = @_;
    return $self->{sequences}
}

sub writeFastaToTMP
{
    my ($header, $seq_ref) = @_;
    my ($tmp_fh, $tmp_fasta_file) = tempfile( UNLINK => 1 );
    print $tmp_fh ">" . $header . "\n";
    print $tmp_fh join('', @$seq_ref), "\n";
    close($tmp_fh);
    return $tmp_fasta_file
}

sub runHmmScan
{
    my ($tmp_fasta) = @_;
    
    my ($fh, $dom_tblout) = tempfile( UNLINK => 1 );
    close($fh);
    
    my $params = "--domT 80 --domtblout $dom_tblout --noali";
    my $hmm_file = 'hmms/IG_combined.hmm';
    my $command = "hmmscan $params $hmm_file $tmp_fasta > /dev/null 2>&1";
    qx($command);
    
    open(my $tblout_fh, "<", $dom_tblout)
        or die "Could not open hmmscan domain table out file: $dom_tblout";
    
    local $/ = "\n";
    my @domain_hits = grep { !(/^#/) } <$tblout_fh>;
    
    close($tblout_fh);
    return \@domain_hits
}

sub parceDomainHits
{
    my ($hmm_scan_out) = @_;
    my @hits;

    for my $line (@$hmm_scan_out)
    {
        my @field = split /\s+/, $line;
        my ($org, $dom) = $field[0] =~ /^(\S+)_(\S+)$/;
        push @hits, [$org,         # [0] organism
                     $dom,         # [1] domain
                     $field[6],    # [2] Seq E-value
                     $field[8],    # [3] Seq bias
                     $field[13],   # [4] Domain Score
                     $field[17],   # [5] ali start
                     $field[18],   # [6] ali end
                     $field[21]];  # [7] Accuracy
    }
    return \@hits
}

sub findBestOrganism
{
    my ($domain_hits) = @_;
    die "No hits" unless @$domain_hits;
    my $best = reduce {($a->[4] < $b->[4]) ? $b : $a} @$domain_hits;

    return $best->[0] 
}

sub detectSequences
{
    my ($domain_hits, $target_organism) = @_;
    
    my @hits = grep { $_->[0] eq $target_organism } @$domain_hits;
    return [] unless @hits;
    
    
    @hits = sort { $a->[5] <=> $b->[5] } @hits;
    my @segments;
    for my $hit (@hits)
    {
        my ($f, $t) = @$hit[5,6];  # ali_from, ali_to
        if (!@segments || $f > $segments[-1]{end})
        {
            push @segments, { start => $f, end => $t, hits => [ $hit ] };
        }
        else
        {
            $segments[-1]{end} = $t if $t > $segments[-1]{end};
            push @{ $segments[-1]{hits} }, $hit;
        }
    }
    
    my @sequences;
    for my $seg (@segments)
    {
        my @h = @{ $seg->{hits} };
        
        if (my ($heavy) = grep { $_->[1] eq 'IGH' } @h)
        {
            push @sequences, { domain  => 'IGH',
                               start => $seg->{start},
                               end   => $seg->{end},
                               bias  => $heavy ->[3],
                               score => $heavy->[4]};
        }
        
        my @light = grep { $_->[1] eq 'IGK' || $_->[1] eq 'IGL' } @h;
        if (@light)
        {
            my ($best) = sort { $b->[4] <=> $a->[4] } @light;
            push @sequences, { domain  => $best->[1],
                               start => $seg->{start},
                               end   => $seg->{end},
                               bias  => $best ->[3],
                               score => $best->[4]};
        }
    }
    
    return \@sequences;
}

sub alignToDomain
{
    my ($seq_id, $seq_array_ref, $domain, $organism) = @_;
    
    my $seq_file = writeFastaToTMP($seq_id, $seq_array_ref);
    my $params = "--outformat afa --trim";
    my $hmm = "hmms/$organism/$domain.hmm";
    my $command = "hmmalign $params $hmm $seq_file";
    
    local $/ = "\n";
    my @hmm_align_results = qx($command);
    chomp(@hmm_align_results);
    my $result_str = join("", @hmm_align_results[1 .. $#hmm_align_results]);
    my @residues = split //, $result_str;
    return \@residues;
}

1;
