#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $requires = { 'perl'                  => q(5.008),
                 'version'               => q(0.74),
                 'Readonly'              => q(1.03),
                 'Class::Accessor::Fast' => q(0.31) };
my $build = Module::Build->new
   ( add_to_cleanup     => [ 'Data-CloudWeights-*',
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::Harness'       => q(2.64),
                             'Test::More'          => q(0.74),
                             'Test::Pod'           => q(1.14),
                             'Test::Pod::Coverage' => q(1.08) },
     configure_requires => { 'ExtUtils::MakeMaker' => q(6.42),
                             'version'             => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/Data/CloudWeights.pm),
     license            => q(perl),
     module_name        => q(Data::CloudWeights),
     notes              => { cpan_testers_version => 1 },
     requires           => $requires,
     sign               => 1 );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
