# @(#)Ident: CPANTesting.pm 2013-07-15 12:12 pjf ;

package CPANTesting;

use strict;
use warnings;

use Sys::Hostname; my $host = lc hostname; my $osname = lc $^O;

# Is this an attempted install on a CPAN testing platform?
sub is_testing { !! ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
                 || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) }

sub should_abort {
   is_testing() or return 0;

   $host eq q(xphvmfred) and return
      "ABORT: ${host} - cc06993e-a5e9-11e2-83b7-87183f85d660";
   return 0;
}

sub test_exceptions {
   my $p = shift; is_testing() or return 0;

   $p->{stop_tests}     and return 'TESTS: CPAN Testing stopped in Build.PL';
   $osname eq q(mirbsd) and return 'TESTS: Mirbsd OS unsupported';

   $host =~ m{ cthomas       }mx and return
      'TESTS: 8d51a280-e872-11e2-9fd4-a5333fc76d31';
   $host =~ m{ jasonclifford }mx and return
      'TESTS: 21ecef88-ea3c-11e2-9b36-562531b64f85';
   return 0;
}

1;

__END__
