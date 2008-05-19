#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $dist     = q(lib/Data/CloudWeights.pm);
my $requires = { 'perl'                  => q(5.8),
                 'version'               => q(0.74),
                 'Readonly'              => q(1.03),
                 'Class::Accessor::Fast' => q(0.31) };
my $build    = Module::Build->new( create_makefile_pl => q(traditional),
                                   create_readme      => 1,
                                   create_packlist    => 0,
                                   dist_version_from  => $dist,
                                   license            => q(perl),
                                   module_name        => q(Data::CloudWeights),
                                   requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
