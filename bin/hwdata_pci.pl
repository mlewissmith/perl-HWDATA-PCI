#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

use HWDATA::PCI;

my $pci = HWDATA::PCI->new;
my $devices = $pci->get_hwdata_devices;
for my $device ( sort keys %$devices ) {
    my $device_name = $pci->get_devicename($device);
    say "[$device] $device_name";
}

