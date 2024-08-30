package HWDATA::PCI;
use strict;
use warnings;

our $VERSION = '0.0.1';

=head1 NAME

HWDATA::PCI - perl interface to HWDATA PCI data

=head1 SYNOPSIS

    use HWDATA::PCI;

    my $pci = HWDATA::PCI->new;
    my $lspci = $pci->get_lspci;

    for my $device (sort keys %$lspci) {
        my $device_name = $pci->get_devicename($device);
        print "[$device] $device_name\n";
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

Constructor.  Build B<lspci> and B<hwdata> internal hashes.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = {
        ids => $args->{ids} || '/usr/share/hwdata/pci.ids',
        hwdata => undef,
        lspci => undef,
    };
    my $blessed = bless $self, $class;

    $self->{hwdata} = _hwdata($self->{ids});
    $self->{lspci} = _lspci();

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

=item B<< get_lspci >>

Parsed output from C<lspci -n -vmm>, returned as hashref:

    {
        'HEX:HEX' => [ { 'tag' => 'value' }, ... ]
    }

Note: primary key is C<< $pcivendor:$pcidevice >> containg array of B<< lspci >>
tag:value pairs, one per device installed.

Note: the B<lspci> hash is built at contruction time, see L</Internals>.

=cut

sub get_lspci {
    my $self = shift;
    return $self->{lspci};
}


=back

=cut

################################################################################
################################################################################
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
        next if ($line =~ m/^C\s/);
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

=item B<< _lspci >>

Run C<< lspci -vmm -n >>, parse, return hashref.

=cut

sub _lspci {
    my %devices = ();
    my %device = ();
    for my $line ( qx[lspci -vmm -n] ) {
        chomp $line;
        if (length($line)) {
            if ($line =~ m{^(\S+):\s*(\S+)\s*$}) {
                $device{$1} = $2;
            }
        } else {
            ## blank line terminates record
            push @{ $devices{"$device{Vendor}:$device{Device}"} }, {%device};
            %device = ();
        }
    }
    return \%devices;
}

=back

=cut

1;
__END__
