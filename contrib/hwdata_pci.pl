#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

use HWDATA::PCI;

my $pci = HWDATA::PCI->new;
my $hwdata = $pci->get_hwdata;
my $vendors = $pci->get_hwdata_vendors;
my $devices = $pci->get_hwdata_devices;
my $classes = $pci->get_hwdata_classes;

for my $v (sort keys %$vendors) {
    say "[$v] $vendors->{$v}";
    ## equivalent
    say "[$v] " . $pci->get_name($v);
}

for my $d (sort keys %$devices) {
    say "[$d] $devices->{$d}";
    ## equivalent...ish, a bit more verbose
    say "[$d] " . $pci->get_name($d);
}

for my $c (sort keys %$classes) {
    say "[$c] $classes->{$c}";
    ## equivalent
    say "[$c] " . $pci->get_name("::$c");
}
