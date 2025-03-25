package Structures::HMM_model;

use strict;
use warnings;
use Structures::Seq;
use File::Temp qw/ tempfile /;

sub new
{
    my ($class, $seq_ref) = @_;
    my $self = { original_seq => $seq_ref->{seq},
                 header       => $seq_ref->{header},
                 id           => $seq_ref->{id},
                 sequence     => undef };
                 
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
    my ($tmp_fh, $tmpFile) = tempfile();
    print $tmp_fh ">" . $header . "\n";
    print $tmp_fh join('', @$seq_ref), "\n";
    close($tmp_fh);
    return $tmpFile
}


sub findBestDomain
{
    my ($seq_id, $seq_array_ref) = @_;
    my $seqFile = writeFastaToTMP($seq_id, $seq_array_ref);
    my ($fh, $domTblout) = tempfile();
    close($fh);
    my $hmmScanResult = qx(hmmscan --domT 100 -T 100 --domtblout $domTblout --noali hmms/IG_combined.hmm $seqFile);
	
    open(my $tblout_fh, "<", $domTblout)
        or die "Could not open hmmscan domain table out file: $domTblout";
	
    local $/ = "\n";
    my %sequences;
    my $bestScore = 0;
    my $bestDomain = {};
    while(my $line = <$tblout_fh>)
    {
        next if $line =~ /^#/;
        my @field = split(/\s+/, $line);
        $field[0] =~ /^(\S+)_(\S+)$/;
        my $organism = $1;
        my $domain = $2;
        my $seqInfo = { organism => $organism,
                        domain	 => $domain,
                        tLen 	 => $field[2],
                        qLen 	 => $field[5],
                        e_value	 => $field[6],	
                        score	 => $field[7],	
                        bias	 => $field[8],
                        acc      => $field[-2],
                        seq      => '',
                        fullName => ''};
		
        if($bestScore < $seqInfo -> {score})
        {
            $bestDomain = $seqInfo;
            $bestScore = $seqInfo -> {score};
        }
    }
    unlink $domTblout or warn "Could not unlink $domTblout: $!";
    unlink $seqFile or warn "Could not unlink $seqFile: $!";
    return $bestDomain;
}

sub alignToDomain
{
    my ($seq_id, $seq_array_ref, $domain, $organism) = @_;
	
    my $seqFile = writeFastaToTMP($seq_id, $seq_array_ref);
    my $hmmAlignResults = qx(hmmalign --outformat afa --trim hmms/$organism/$domain.hmm $seqFile);
    my @hmmAlignResults = split("\n", $hmmAlignResults);
    my $aligned_seq = join("", @hmmAlignResults[1 .. $#hmmAlignResults]);
    return $aligned_seq
}

1;
