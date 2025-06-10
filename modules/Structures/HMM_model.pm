package Structures::HMM_model;

use strict;
use warnings;

use File::Temp qw(tempfile);
use FindBin;
use List::Util qw(reduce);
use Structures::Seq;

sub new
{
    my( $class, $seq_ref ) = @_;
    
    my $tmp_fasta = writeFastaToTMP( $seq_ref->{id}, $seq_ref->{seq} );
    my @hmm_scan_out = runHmmScan($tmp_fasta);
    my @parsed_data = parseDomainHits(@hmm_scan_out);
    my $target_organism = findBestOrganism(@parsed_data);
    my @sequences = detectSequences(\@parsed_data, $target_organism);
    my @seq_objects;
    for my $seq (@sequences) {
        my $from = $seq->{start} - 1;
        my $to   = $seq->{end}   - 1;
        my @sub_seq = @{ $seq_ref->{seq} }[ $from .. $to ];
        my $sub_seq_ref = { header => $seq_ref->{header},
                            seq    => \@sub_seq,
                            id     => $seq_ref->{id}};
                            
        my $domain_ref = { domain   => $seq->{domain},
                           organism => $target_organism,
                           score	=> $seq->{score},
                           bias	    => $seq->{bias}};
        
        push @seq_objects, Structures::Seq->new( $sub_seq_ref, $domain_ref );
    }
    
    my $self = bless { original_seq => $seq_ref->{seq},
                       header       => $seq_ref->{header},
                       id           => $seq_ref->{id},
                       sequences    => \@seq_objects },
                     $class;
                 
    for my $seq ($self->getSequences) {
        $seq->setAlignedSeq(alignToDomain( $seq->getId,
                                           $seq->getSeq,
                                           $seq->getDomain,
                                           $seq->getOrganism ));
    }
    return $self;
}


sub getSequences
{
    my( $self ) = @_;
    return @{$self->{sequences}};
}

sub writeFastaToTMP
{
    my( $header, $seq_ref ) = @_;
    my( $tmp_fh, $tmp_fasta_file ) = tempfile( UNLINK => 1 );
    print $tmp_fh ">" . $header . "\n";
    print $tmp_fh join( '', @$seq_ref ), "\n";
    close $tmp_fh;
    return $tmp_fasta_file;
}

sub runHmmScan
{
    my( $tmp_fasta ) = @_;
    
    my( $fh, $dom_tblout ) = tempfile( UNLINK => 1 );
    close $fh;
    
    my $params = "--domT 80 --domtblout $dom_tblout --noali";
    my $hmm_file = $FindBin::Bin . '/hmms/IG_combined.hmm';
    my $command = "hmmscan $params $hmm_file $tmp_fasta > /dev/null 2>&1";
    qx($command);
    
    open my $tblout_fh, '<', $dom_tblout
        or die "Could not open hmmscan domain table out file: $dom_tblout";
    
    local $/ = "\n";
    my @domain_hits = grep { !(/^#/) } <$tblout_fh>;
    
    close $tblout_fh;
    return @domain_hits;
}

sub parseDomainHits
{
    my @hmm_scan_out = @_;
    my @hits;

    for my $line (@hmm_scan_out) {
        my @field = split /\s+/, $line;
        my( $org, $dom ) = $field[0] =~ /^(\S+)_(\S+)$/;
        push @hits, { organism => $org,         # [0] organism
                      domain   => $dom,         # [1] domain
                      evalue   => $field[6],    # [2] Seq E-value
                      bias     => $field[8],    # [3] Seq bias
                      score    => $field[13],   # [4] Domain Score
                      start    => $field[17],   # [5] ali start
                      end      => $field[18],   # [6] ali end
                      accuracy => $field[21] }; # [7] Accuracy
    }
    return @hits;
}

sub findBestOrganism
{
    my @domain_hits = @_;
    die "No hits" unless @domain_hits;
    my $best = reduce { $a->{score} < $b->{score} ? $b : $a } @domain_hits;

    return $best->{organism};
}

sub detectSequences
{
    my ($domain_hits, $target_organism) = @_;
    
    my @hits = sort { $a->{start} <=> $b->{start} }
               grep { $_->{organism} eq $target_organism } @$domain_hits;
    return () unless @hits;

    my @segments;
    for my $hit (@hits) {
        if (!@segments || $hit->{start} > $segments[-1]{end})
        {
            push @segments, { start => $hit->{start}, end => $hit->{end}, hits => [ $hit ] };
        }
        else
        {
            $segments[-1]{end} = $hit->{end} if $hit->{end} > $segments[-1]{end};
            push @{$segments[-1]{hits}}, $hit;
        }
    }
    
    my @sequences;
    for my $seg (@segments) {
        my @h = @{$seg->{hits}};
        
        if( my( $heavy ) = grep { $_->{domain} eq 'IGH' } @h ) {
            push @sequences, { domain => 'IGH',
                               start  => $seg->{start},
                               end    => $seg->{end},
                               bias   => $heavy->{bias},
                               score  => $heavy->{score} };
        }
        
        my @light = grep { $_->{domain} =~ /^IG[KL]$/ } @h;
        if( @light ) {
            my( $best ) = sort { $b->{score} <=> $a->{score} } @light;
            push @sequences, { domain => $best->{domain},
                               start  => $seg->{start},
                               end    => $seg->{end},
                               bias   => $best->{bias},
                               score  => $best->{score} };
        }
    }
    
    return @sequences;
}

sub alignToDomain
{
    my ($seq_id, $seq_array_ref, $domain, $organism) = @_;
    
    my $seq_file = writeFastaToTMP($seq_id, $seq_array_ref);
    my $params = "--outformat afa --trim";
    my $hmm = "$FindBin::Bin/hmms/$organism/$domain.hmm";
    my $command = "hmmalign $params $hmm $seq_file";
    
    local $/ = "\n";
    my @hmm_align_results = qx($command);
    chomp @hmm_align_results;
    my $result_str = join("", @hmm_align_results[1 .. $#hmm_align_results]);
    my @residues = split //, $result_str;
    return \@residues;
}

1;
