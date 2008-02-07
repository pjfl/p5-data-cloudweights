#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $class    = q(Module::Build);
my $requires = { 'perl'                  => '5.8',
                 'Class::Accessor::Fast' => '0.31' };
my $build    = $class->new( create_readme     => 1,
                            create_packlist   => 0,
                            dist_version_from => 'lib/Data/CloudWeights.pm',
                            license           => q(perl),
                            module_name       => q(Data::CloudWeights),
                            requires          => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
