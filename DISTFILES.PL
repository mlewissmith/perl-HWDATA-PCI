use strict;
use warnings;
use feature qw(say);

use Pod::Usage;

use HWDATA::PCI;

## perl normalised version "vX.Y.Z"
my $pmversion = version->parse($HWDATA::PCI::VERSION)->normal;


## ARGV == ($target, @dependecies)
our $target = $ARGV[0];
our @deps = @ARGV[1..$#ARGV];

for ($target) {
    /VERSION/ and do {
        writefile( $target,
                   "$pmversion\n");
        last;
    };
    /README/ and do {
        pod2usage( -output => $target,
                   -input => $deps[0],
                   -sections => "NAME|DESCRIPTION",
                   -verbose => 99,
                   -exitval => 'NOEXIT' );
        last;
    };
    /CHANGELOG/ and do {
        appendfile($target);
        last;
    };
    # fallthru
    warn "unsupported target '$_'";
}

sub writefile {
    my $outfile = shift;
    open( my $fh, '>', $outfile ) or die "$outfile: $!";
    print $fh $_ for @_;
    close $fh or die "$outfile: $!";
}

sub appendfile {
    my $outfile = shift;
    open( my $fh, '>>', $outfile ) or die "$outfile: $!";
    print $fh $_ for @_;
    close $fh or die "$outfile: $!";
}

sub touchfile {
    my $outfile = shift;
    appendfile($outfile);
}
