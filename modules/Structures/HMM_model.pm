package Structures::HMM_model;

use strict;
use warnings;
use Structures::Seq;
use File::Temp qw(tempfile);
use List::Util qw(reduce);

sub new
{
    my ($class, $seq_ref) = @_;
    my $self = { original_seq => $seq_ref->{seq},
                 header       => $seq_ref->{header},
                 id           => $seq_ref->{id},
                 sequence     => undef};
    
    my $domain_ref = findBestDomain($self->{id}, $seq_ref->{seq});
    my $seq = Structures::Seq->new($seq_ref, $domain_ref);
    $seq->setAlignedSeq(alignToDomain($seq->getId(), $seq->getSeq(),
                                      $seq->getDomain(), $seq->getOrganism()));
    $self->{sequence} = $seq;
    return bless $self, $class;
}


sub getSequence
{
    my ($self) = @_;
    return $self->{sequence}
}

sub writeFastaToTMP
{
    my ($header, $seq_ref) = @_;
    my ($tmp_fh, $tmpFile) = tempfile( UNLINK => 1 );
    print $tmp_fh ">" . $header . "\n";
    print $tmp_fh join('', @$seq_ref), "\n";
    close($tmp_fh);
    return $tmpFile
}

sub runHmmScan
{
    my ($seq_id, $seq_array_ref) = @_;
    
    my $seq_file = writeFastaToTMP($seq_id, $seq_array_ref);
    my ($fh, $dom_tblout) = tempfile( UNLINK => 1 );
    close($fh);
    
    my $params = "--domT 100 -T 100 --domtblout $dom_tblout --noali";
    my $hmm_file = 'hmms/IG_combined.hmm';
    my $command = "hmmscan $params $hmm_file $seq_file > /dev/null 2>&1";
    qx($command);
    
    open(my $tblout_fh, "<", $dom_tblout)
        or die "Could not open hmmscan domain table out file: $dom_tblout";
    
    local $/ = "\n";
    my @domain_hits = grep { !(/^#/) } <$tblout_fh>;
    
    close($tblout_fh);
    return \@domain_hits;
}


sub findBestDomain
{
    my ($seq_id, $seq_array_ref) = @_;
    my $domain_hits = runHmmScan($seq_id, $seq_array_ref);
    
    my @hits = map { my @field = split(/\s+/, $_);
                     $field[0] =~ /^(\S+)_(\S+)$/;
                     { organism => $1,
                       domain   => $2,
                       tLen     => $field[2],
                       qLen     => $field[5],
                       e_value  => $field[6],
                       score    => $field[7],
                       bias     => $field[8],
                       acc      => $field[-2],
                       seq      => '',
                       fullName => '' }} @{ $domain_hits };
    
    my $best_domain = reduce { $a->{score} < $b->{score} ? $b : $a } @hits;
    return $best_domain;
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
