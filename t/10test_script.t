# @(#)Ident: 10test_script.t 2013-08-15 15:08 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.10.%d', q$Rev: 1 $ =~ /\d+/gmx );
use File::Spec::Functions   qw( catdir updir );
use FindBin                 qw( $Bin );
use lib                 catdir( $Bin, updir, 'lib' );

use Module::Build;
use Test::More;

my $notes = {};

BEGIN {
   my $builder = eval { Module::Build->current };
      $builder and $notes = $builder->notes;
}

SKIP: {
   use English qw( -no_match_vars );
   use Data::CloudWeights;

   my $cloud = Data::CloudWeights->new;

   isa_ok $cloud, 'Data::CloudWeights';
   can_ok $cloud, 'add';
   can_ok $cloud, 'formation';

   my $nimbus = $cloud->formation;

   ok $nimbus && ref $nimbus eq q(ARRAY) && !$nimbus->[0], 'Null formation';

   is $cloud->add( q(tag1), 1, 1 ), 1, 'Add return value - 1';

   $nimbus = $cloud->formation;

   is $nimbus && $nimbus->[0]->{count}, 1, 'Single count';

   is $nimbus->[0]->{colour}, '#FF0000', 'Single colour';

   is $cloud->add( q(tag0), 1, 1 ), 1, 'Add return value - 3';

   $nimbus = $cloud->formation;

   is $nimbus->[1]->{tag}, q(tag1), 'Second tag';

   $cloud->sort_field( undef ); $nimbus = $cloud->formation;

   is $nimbus->[1]->{tag}, q(tag0), 'No sort';

   is $cloud->add( q(tag2), 1, 3 ), 1, 'Add return value - 4';

   $cloud->sort_field( q(value) ); $cloud->sort_type( q(numeric) );

   $cloud->sort_order( q(desc) ); $nimbus = $cloud->formation;

   is $nimbus->[0]->{tag}, q(tag2), 'Sort desc numeric';

   is $cloud->add( q(tag1), 1, 2 ), 2, 'Add return value - 2';

   $cloud->sort_field( q(tag) ); $cloud->sort_type( q(alpha) );

   $nimbus = $cloud->formation;

   is $nimbus->[1]->{value}->[1], 2, 'Tag value';

   is @{ $nimbus }, 3, 'No output limit';

   $cloud->limit( 1 ); $nimbus = $cloud->formation;

   is @{ $nimbus }, 1, 'Output limit';
}

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
