#!/usr/bin/perl

use strict;
use warnings;

use HWDATA::PCI;


my $pci = HWDATA::PCI->new;
my $lspci = $pci->get_lspci;

for my $device (sort keys %$lspci) {
    my $device_name = $pci->get_devicename($device);
    print "[$device] $device_name\n";
}
