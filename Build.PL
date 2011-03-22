# @(#)$Id$

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

Bob->new( {
   sign       => 1,
   license    => q(perl),
   module     => q(Data::CloudWeights),
   home_page  => q(http://www.roxsoft.co.uk),
   bugtracker => q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=),
   requires   => {
      'perl'            => 5.008,
      'parent'          => 0.221,
      'version'         => 0.74,
      'Color::Spectrum' => 1.06,
      'Moose'           => 1.21, },
   configure_requires   => { 'Module::Build' => 0.32,
                             'version'       => 0.74, },
   build_requires       => { 'Test::More'    => 0.74, },
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# tab-width: 3
# End:
