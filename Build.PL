# @(#)$Id$

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );

Bob->new( {
   module     => q(Data::CloudWeights),
   home_page  => q(http://www.roxsoft.co.uk),
   requires   => {
      'perl'                 => 5.010,
      'namespace::autoclean' => 0.13,
      'parent'               => 0.221,
      'version'              => 0.74,
      'Color::Spectrum'      => 1.06,
      'Moose'                => 2.0402, },
   configure_requires   => { 'version'       => 0.74,
                             'Module::Build' => 0.32, },
   build_requires       => { 'Test::More'    => 0.74, },
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# tab-width: 3
# End:
