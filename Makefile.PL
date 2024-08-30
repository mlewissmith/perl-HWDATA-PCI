# MAKEMAKER REFERENCES
# https://metacpan.org/pod/ExtUtils::MakeMaker
# https://metacpan.org/pod/ExtUtils::MakeMaker::Tutorial
# https://metacpan.org/pod/ExtUtils::Manifest


use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HWDATA::PCI',
    AUTHOR              => 'Magnus Lewis-Smith <ccsgac@csc.warwick.ac.uk>',
    VERSION_FROM        => 'lib/HWDATA/PCI.pm',
    ABSTRACT_FROM       => 'lib/HWDATA/PCI.pm',
    LICENSE             => 'restricted',
);
