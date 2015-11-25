use t::boilerplate;

use Test::More;

use_ok 'Data::CloudWeights';

my $cloud = Data::CloudWeights->new;

isa_ok $cloud, 'Data::CloudWeights';
can_ok $cloud, 'add';
can_ok $cloud, 'formation';

my $nimbus = $cloud->formation;

ok $nimbus && ref $nimbus eq 'ARRAY' && !$nimbus->[ 0 ], 'Null formation';

is $cloud->add(), undef, 'Returns undef without tag';

is $cloud->add( 'tag1' ), 0, 'Must have a count value';

is $cloud->add( 'tag1', 1, 1 ), 1, 'Add return value - 1';

$nimbus = $cloud->formation;

is $nimbus && $nimbus->[ 0 ]->{count}, 1, 'Single count';

is $nimbus->[ 0 ]->{colour}, '#FF0000', 'Single colour';

is $cloud->add( 'tag0', 1, 1 ), 1, 'Add return value - 3';

$nimbus = $cloud->formation;

is $nimbus->[ 1 ]->{tag}, 'tag1', 'Second tag';

$cloud->sort_field( undef ); $nimbus = $cloud->formation;

is $nimbus->[ 1 ]->{tag}, 'tag0', 'No sort';

is $cloud->add( 'tag2', 1, 3 ), 1, 'Add return value - 4';

$cloud->sort_field( 'value' ); $cloud->sort_type( 'numeric' );

$cloud->sort_order( 'desc' ); $nimbus = $cloud->formation;

is $nimbus->[ 0 ]->{tag}, 'tag2', 'Sort desc numeric';

is $cloud->add( 'tag1', 1, 2 ), 2, 'Add return value - 2';

$cloud->sort_field( 'tag' ); $cloud->sort_type( 'alpha' );

$nimbus = $cloud->formation;

is $nimbus->[ 1 ]->{value}->[ 1 ], 2, 'Tag value';

is @{ $nimbus }, 3, 'No output limit';

$cloud->limit( 1 ); $nimbus = $cloud->formation;

is @{ $nimbus }, 1, 'Output limit';

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
