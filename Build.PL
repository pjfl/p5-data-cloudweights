# @(#)Ident: Build.PL 2013-07-10 15:00 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev: 2 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(Data::CloudWeights),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'             => 5.01,
      'namespace::sweep' => 0.006,
      'Color::Spectrum'  => 1.06,
      'Moo'              => 1.002000,
      'Type::Tiny'       => 0.012, },
   recommends            => {
      'App::cpanminus'   => 1.6005, },
   configure_requires    => {
      'version'          => 0.88,
      'Module::Build'    => 0.4004, },
   build_requires        => {
      'version'          => 0.88,
      'Module::Build'    => 0.4004, },
} )->create_build_script; # Goal!

# Local Variables:
# tab-title: CloudWeights
# eval: (load-project-state "data-cloudweights")
# mode: perl
# tab-width: 3
# End:
