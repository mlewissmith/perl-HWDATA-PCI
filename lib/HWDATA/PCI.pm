package HWDATA::PCI;

# OO-PERL REFERENCES
# https://perldoc.perl.org/perlootut
# https://www.perl.com/article/25/2013/5/20/Old-School-Object-Oriented-Perl/

use strict;
use warnings;

our $VERSION = '1.0.0';

=head1 NAME

HWDATA::PCI - perl interface to HWDATA PCI data

=head1 SYNOPSIS

    use HWDATA::PCI;

    $pci = HWDATA::PCI->new;
    $hwdata = $pci->get_hwdata;
    $vendors = $pci->get_hwdata_vendors;
    $devices = $pci->get_hwdata_devices;
    $classes = $pci->get_hwdata_classes;

    ## vendors
    for $v (sort keys %$vendors) {
        say "[$v] $vendors->{$v}";
        ## equivalent
        say "[$v] " . $pci->get_name($v);
    }

    ## devices
    for $d (sort keys %$devices) {
        say "[$d] $devices->{$d}";
        ## equivalent...ish, a bit more verbose
        say "[$d] " . $pci->get_name($d);
    }

    ## classes
    for $c (sort keys %$classes) {
        say "[$c] $classes->{$c}";
        ## equivalent
        say "[$c] " . $pci->get_name("::$c");
    }


=head1 DESCRIPTION

Provide perl interface to HWDATA PCI data as stored at C<<
/usr/share/hwdata/pci.ids >> (or system equivalent)

=cut

################################################################################
################################################################################
################################################################################
################################################################################

=head1 API

=head2 Methods

=over

=item B<< new >>

=item B<< new( { pciids => 'I</usr/share/hwdata/pci.ids>' } ) >>

Constructor.  Build B<hwdata> internal hashes.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = {
        pciids => $args->{pciids} || '/usr/share/hwdata/pci.ids',
        hwdata => undef,
    };
    my $blessed = bless $self, $class;

    $self->{hwdata} = _hwdata($self->{pciids});

    return $blessed;
}

=item B<< get_name( "I<< VENDOR >>[:I<< DEVICE >>[:I<< CLASS >>]]" ) >>

=item B<< get_name( "[I<< VENDOR >>]:[I<< DEVICE >>]:I<< CLASS >>" ) >>

Return formatted device/class name given hex values.

    print $pci->get_devicename("10de:1fb0")
    NVIDIA Corporation TU117GLM [Quadro T1000 Mobile]

=cut

sub get_name {
    my $self = shift;
    my $key = shift;
    my ($vendor_id, $device_id, $class_id) = split(/:/, $key);
    my ($vendor_name, $device_name, $class_name);

    my @returnstrs;

    if (defined $vendor_id) {
        if (defined $self->{hwdata}{vendors}{$vendor_id}) {
            $vendor_name = $self->{hwdata}{vendors}{$vendor_id};
        } else {
            $vendor_name = $vendor_id;
        }
        push @returnstrs, $vendor_name;

        if (defined $device_id) {
            if (defined $self->{hwdata}{devices}{"${vendor_id}:${device_id}"}) {
                $device_name = $self->{hwdata}{devices}{"${vendor_id}:${device_id}"};
            } else {
                $device_name = $device_id;
            }
            push @returnstrs, $device_name;
        }
    }

    if (defined $class_id) {
        if (defined $self->{hwdata}{classes}{$class_id}) {
            $class_name = $self->{hwdata}{classes}{$class_id};
        } else {
            $class_name = $class_id;
        }
        unshift @returnstrs, ${class_name};
    }

    return join(" ", @returnstrs);
}

=item B<< get_hwdata >>

=item B<< get_hwdata_vendors >>

=item B<< get_hwdata_devices >>

=item B<< get_hwdata_classes >>

Parsed hwdata C<pci.ids> file, returned as hashref:

   {
        'vendors' => { 'HEX' => 'VENDOR_NAME', ... },
        'devices' => { 'HEX:HEX' => 'DEVICE_NAME', ... }
        'classes' => { 'HEX' => 'CLASS_NAME', ... }
   }

Note: the B<hwdata> hash is built at construction time, see L</Internals>.

=cut

sub get_hwdata {
    my $self = shift;
    return $self->{hwdata};
}

sub get_hwdata_vendors {
    my $self = shift;
    return $self->{hwdata}{vendors};
}

sub get_hwdata_devices {
    my $self = shift;
    return $self->{hwdata}{devices};
}

sub get_hwdata_classes {
    my $self = shift;
    return $self->{hwdata}{classes};
}

=back

=cut

################################################################################
################################################################################

=head2 Internals

=over

=item B<< _hwdata( I<< DATAFILE >> ) >>

Read hwdata C<< pci.ids >> file, parse, return hashref.

=cut

sub _hwdata {
    my $datafile = shift;
    my %pci;
    my $recordtype;
    my ($pci_vendor_id, $pci_vendor_name);
    my ($pci_device_id, $pci_device_name);
    my ($pci_class_id, $pci_class_name);
    my ($pci_subclass_id, $pci_subclass_name);
    open(my $fh, "<${datafile}") or die "${datafile}: $!";
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\#.+//;
        next unless $line;
        ## PCI vendor (set recordtype = "device")
        if ( $line =~ m{^\s{0}([[:xdigit:]]{4})\s+(.+)$} ) {
            $recordtype = "device";
            $pci_vendor_id = $1;
            $pci_vendor_name = $2;
            $pci{vendors}{$1} = $2;
        }
        ## PCI device (iff recordtype == "device")
        if ( $line =~ m{^\s{1}([[:xdigit:]]{4})\s+(.+)$} and $recordtype eq "device" ) {
            $pci_device_id = $1;
            $pci_device_name = $2;
            $pci{devices}{"${pci_vendor_id}:${pci_device_id}"} = "${pci_device_name}";
        }
        ## PCI Class (set recordtype = "class")
        if ( $line =~ m{^C\s+([[:xdigit:]]{2})\s+(.+)$} ) {
            $recordtype = "class";
            $pci_class_id = $1;
            $pci_class_name = $2;
            #$pci{classes}{"${pci_class_id}"} = "${pci_class_name}";
        }
        ## PCI Subclass (iff recordtype == "class")
        if ( $line =~ m{^\s+([[:xdigit:]]{2})\s+(.+)$} and $recordtype eq "class") {
            $pci_subclass_id = $1;
            $pci_subclass_name = $2;
            $pci{classes}{"${pci_class_id}${pci_subclass_id}"} = "${pci_class_name}[${pci_subclass_name}]";
        }
    }
    close $fh or die "${datafile}: $!";
    return \%pci;
}

=back

=cut

1;
__END__
