package HWDATA::PCI;

# OO-PERL REFERENCES
# https://perldoc.perl.org/perlootut
# https://www.perl.com/article/25/2013/5/20/Old-School-Object-Oriented-Perl/

use strict;
use warnings;

our $VERSION = '0.1.0';

=head1 NAME

HWDATA::PCI - perl interface to HWDATA PCI data

=head1 SYNOPSIS

    use HWDATA::PCI;

    $pci = HWDATA::PCI->new;
    $devices = $pci->get_hwdata_devices;

    for ( sort keys %$devices ) {
        $device_name = $pci->get_devicename($_);
    }

=head1 DESCRIPTION

TBD

=cut

################################################################################
################################################################################
################################################################################
################################################################################

=head2 Methods

=over

=item B<< new >>

=item B<< new( {ids => '/usr/share/hwdata/pci.ids'} ) >>

Constructor.  Build B<hwdata> internal hashes.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = {
        ids => $args->{ids} || '/usr/share/hwdata/pci.ids',
        hwdata => undef,
    };
    my $blessed = bless $self, $class;

    $self->{hwdata} = _hwdata($self->{ids});

    return $blessed;
}

=item B<< get_devicename( "$pcivendor:$pcidevice" ) >>

Return device name given C<< $pcivendor:$pcidevice >> hex pair.

    print $pci->get_devicename("10de:1fb0")
    NVIDIA Corporation TU117GLM [Quadro T1000 Mobile]

=cut

sub get_devicename {
    my $self = shift;
    my $vendor_device = shift;
    my ($pcivendor, $pcidevice) = split(/:/, $vendor_device);
    my $vendor_name = $self->{hwdata}{vendors}{$pcivendor} || "[VENDOR:$pcivendor]";
    my $device_name = $self->{hwdata}{devices}{$vendor_device} || "[DEVICE:$pcidevice]";
    return "$vendor_name $device_name";
}

=item B<< get_hwdata >>

=item B<< get_hwdata_devices >>

=item B<< get_hwdata_vendors >>

Parsed hwdata C<pci.ids> file, returned as hashref:

   {
        'vendors' => { 'HEX' => 'VENDOR_NAME', ... },
        'devices' => { 'HEX:HEX' => 'DEVICE_NAME', ... }
   }

Note: the B<hwdata> hash is built at construction time, see L</Internals>.

=cut

sub get_hwdata {
    my $self = shift;
    return $self->{hwdata};
}

sub get_hwdata_devices {
    my $self = shift;
    return $self->{hwdata}{devices};
}

sub get_hwdata_vendors {
    my $self = shift;
    return $self->{hwdata}{vendors};
}

=back

=cut

################################################################################
################################################################################

=head2 Internals

=over

=item B<< _hwdata( >> I<< DATAFILE >> B<< ) >>

Read hwdata C<< pci.ids >> file, parse, return hashref.

=cut

sub _hwdata {
    my $datafile = shift;
    my %pci;
    my ($pci_vendor_id, $pci_vendor_name, $pci_device_id, $pci_device_name);
    open(my $fh, "<${datafile}") or die "${datafile}: $!";
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\#.+//;
        next unless $line;
        last if ($line =~ m/^C\s/); ## ABORT once we reach the device class stuff
        if ( $line =~ m/^\s{0}([[:xdigit:]]+)\s+(.+)$/ ) {
            $pci_vendor_id = $1;
            $pci_vendor_name = $2;
            $pci{vendors}{$1} = $2
        }
        if ( $line =~ m/^\s{1}([[:xdigit:]]+)\s+(.+)$/ ) {
            $pci_device_id = $1;
            $pci_device_name = $2;
            $pci{devices}{"${pci_vendor_id}:${pci_device_id}"} = "${pci_device_name}";
        }
    }
    close $fh or die "${datafile}: $!";
    return \%pci;
}

=back

=cut

1;
__END__
