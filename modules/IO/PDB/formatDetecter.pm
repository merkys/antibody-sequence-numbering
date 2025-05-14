package IO::PDB::formatDetecter;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(detectFormat);

sub detectFormat
{
    my ($unknown_file) = @_;
    
    open my $fh, '<', $unknown_file
        or die "Can't open $unknown_file: $!";
        
     while(<$fh>)
     {
        chomp;
        return 'cif' if /^loop_|^data_/;
        return 'pdb' if /^(?:HEADER|TITLE|COMPND|SOURCE|EXPDTA|AUTHOR|REVDAT|JRNL)/x;
     }
     close $fh;
     return 'unknown'
}

1;
