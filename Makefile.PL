# MAKEMAKER REFERENCES
# https://metacpan.org/pod/ExtUtils::MakeMaker
# https://metacpan.org/pod/ExtUtils::MakeMaker::Tutorial
# https://metacpan.org/pod/ExtUtils::Manifest


use strict;
use warnings;
use ExtUtils::MakeMaker;

use Data::Dumper;

my $pmname = 'HWDATA::PCI';
my $pmfile = 'lib/HWDATA/PCI.pm';
my %pl_files;

## Distribution files which can be built *without* appealing to git
$pl_files{'DISTFILES.PL'} = {
    README  => [$pmfile],
    VERSION => [$pmfile],
    CHANGELOG => [],
};

sub MY::postamble {
    my @makefile;

    ## define dummy target for DISTFILES
    my $distfiles = join(' ', sort keys %{ $pl_files{'DISTFILES.PL'} } );
    push @makefile, <<"__DISTFILES__";
.PHONY: DISTFILES
DISTFILES: $distfiles
__DISTFILES__

    return join("\n", @makefile);
}

WriteMakefile( NAME           => $pmname,
               AUTHOR         => 'Magnus Lewis-Smith <mlewissmith@users.noreply.github.com>',
               VERSION_FROM   => $pmfile,
               ABSTRACT_FROM  => $pmfile,
               LICENSE        => 'unrestricted',
               EXE_FILES      => [ glob "./bin/*" ],
               PL_FILES       => \%pl_files,
    );
