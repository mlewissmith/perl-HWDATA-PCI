package HWDATA::PCI;
use strict;
use warnings;
use version;

our $VERSION = version->parse("0.0.1");


sub new {
    my ($class, $args) = @_;
    my $self = {
        pci_ids = '/usr/share/hwdata/pci.ids',
    };
    return bless $self, $class;
}




1;
__END__
