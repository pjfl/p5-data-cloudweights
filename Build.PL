# @(#)$Id$

use strict;
use warnings;

use English qw(-no_match_vars);

sub testing { !! ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
              || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) }

sub whimper { print {*STDOUT} $_[ 0 ]."\n"; exit 0 }

BEGIN {
   eval { require 5.008; }; $EVAL_ERROR and whimper 'Perl minimum 5.8';
   $ENV{PATH}   =~ m{ \A /home/sand }mx and whimper 'Stopped Konig';
}

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

use Module::Build;

Module::Build->new
   ( add_to_cleanup       => [ 'Debian_CPANTS.txt', 'Data-CloudWeights-*',
                               map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires       => { 'Test::More'    => 0.74, },
     configure_requires   => { 'Module::Build' => 0.32,
                               'version'       => 0.74, },
     create_license       => 1,
     create_packlist      => 0,
     create_readme        => 1,
     dist_version_from    => q(lib/Data/CloudWeights.pm),
     license              => q(perl),
     module_name          => q(Data::CloudWeights),
     no_index             => { directory  => [ qw(t) ] },
     notes                => { stop_tests => testing },
     requires             => {
        'perl'            => 5.008,
        'parent'          => 0.221,
        'version'         => 0.74,
        'Color::Spectrum' => 1.06,
        'Moose'           => 1.21, },
     sign                 => 1, )->create_build_script;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
