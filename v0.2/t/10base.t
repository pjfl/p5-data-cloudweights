#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use lib qq($Bin/../lib);
use Test::More tests => 7;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

BEGIN { use_ok q(Data::CloudWeights) }

my $cloud  = Data::CloudWeights->new();
my $nimbus = $cloud->formation();

ok( $nimbus && ref $nimbus eq q(ARRAY) && !$nimbus->[0], q(Null formation) );

ok( $cloud->add( q(tag0), 1, 1 ) == 1, q(Add return value - 1) );

$nimbus = $cloud->formation();

ok( $nimbus && $nimbus->[0]->{count} == 1, q(Single count) );

ok( $nimbus->[0]->{colour} eq q(FF0000), q(Single colour) );

ok( $cloud->add( q(tag0), 1, 2 ) == 2, q(Add return value - 2) );

$nimbus = $cloud->formation();

ok( $nimbus->[0]->{value}->[1] == 2, q(Tag value) );
