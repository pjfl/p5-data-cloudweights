# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

use Module::Build;

my $requires = { 'perl'                  => q(5.008),
                 'parent'                => q(0.221),
                 'version'               => q(0.74),
                 'Class::Accessor::Fast' => q(0.31) };
my $build = Module::Build->new
   ( add_to_cleanup     => [ 'Data-CloudWeights-*',
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::More'          => q(0.74) },
     configure_requires => { 'ExtUtils::MakeMaker' => q(6.42),
                             'version'             => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/Data/CloudWeights.pm),
     license            => q(perl),
     module_name        => q(Data::CloudWeights),
     notes              => { cpan_testers_version => 1 },
     requires           => $requires, );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
