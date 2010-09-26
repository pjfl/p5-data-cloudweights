# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev$ =~ /\d+/gmx );

use English qw( -no_match_vars );
use Module::Build;

sub whimper { my $text = shift; print {*STDOUT} $text."\n"; exit 0 }

BEGIN {
   eval { require 5.008; }; $EVAL_ERROR and whimper 'Perl minimum 5.8';
}

Module::Build->new
   ( add_to_cleanup     => [ 'Debian_CPANTS.txt', 'Data-CloudWeights-*',
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::More' => q(0.74) },
     configure_requires => { 'version'    => q(0.74) },
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/Data/CloudWeights.pm),
     license            => q(perl),
     module_name        => q(Data::CloudWeights),
     requires           => {
        'perl'                  => q(5.008),
        'parent'                => q(0.221),
        'version'               => q(0.74),
        'Class::Accessor::Fast' => q(0.31), },
     sign               => 1, )->create_build_script;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
