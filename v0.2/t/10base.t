# @(#)$Id$

use strict;
use warnings;
use File::Spec::Functions;
use English  qw(-no_match_vars);
use FindBin  qw( $Bin );
use lib (catdir( $Bin, updir, q(lib) ));
use Test::More;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

BEGIN {
   if ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
       || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx
       || ($ENV{PERL5_CPANPLUS_IS_RUNNING} && $ENV{PERL5_CPAN_IS_RUNNING})) {
      plan skip_all => q(CPAN Testing stopped);
   }

   plan tests => 14;
}

use_ok q(Data::CloudWeights);

my $cloud  = Data::CloudWeights->new();
my $nimbus = $cloud->formation();

ok( $nimbus && ref $nimbus eq q(ARRAY) && !$nimbus->[0], q(Null formation) );

ok( $cloud->add( q(tag1), 1, 1 ) == 1, q(Add return value - 1) );

$nimbus = $cloud->formation();

ok( $nimbus && $nimbus->[0]->{count} == 1, q(Single count) );

ok( $nimbus->[0]->{colour} eq q(FF0000), q(Single colour) );

ok( $cloud->add( q(tag0), 1, 1 ) == 1, q(Add return value - 3) );

$nimbus = $cloud->formation();

ok( $nimbus->[1]->{tag} eq q(tag1), q(Second tag) );

$cloud->sort_field( undef );
$nimbus = $cloud->formation();

ok( $nimbus->[1]->{tag} eq q(tag0), q(No sort) );

ok( $cloud->add( q(tag2), 1, 3 ) == 1, q(Add return value - 4) );

$cloud->sort_field( q(value) );
$cloud->sort_type(  q(numeric) );
$cloud->sort_order( q(desc) );
$nimbus = $cloud->formation();

ok( $nimbus->[0]->{tag} eq q(tag2), q(Sort desc numeric) );

ok( $cloud->add( q(tag1), 1, 2 ) == 2, q(Add return value - 2) );

$cloud->sort_field( q(tag) );
$cloud->sort_type(  q(alpha) );
$nimbus = $cloud->formation();

ok( $nimbus->[1]->{value}->[1] == 2, q(Tag value) );

ok( @{ $nimbus } == 3, q(No output limit) );

$cloud->limit( 1 );
$nimbus = $cloud->formation();

ok( @{ $nimbus } == 1, q(Output limit) );

# Local Variables:
# mode: perl
# tab-width: 3
# End:
