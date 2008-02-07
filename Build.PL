#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use File::Spec::Functions;
use FindBin qw($Bin);
use lib qq($Bin/lib);
use CatalystX::Usul::Module::Build::Resource;
use NEXT;
use Readonly;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my  $DBNAME  => 'library';
Readonly my  $PREFIX  => '/opt';
Readonly my  $APPNAME => 'dasWerk';
Readonly my  $APPLREL => 'v0.1p3';

my $builder = q(CatalystX::Usul::Module::Build::Resource);
my $class   = $builder->subclass( class => 'Bob', code  => <<'EOB' );

use File::Copy;
use File::Spec::Functions;

sub ACTION_install {
   my $me = shift;
   my ($base, $dir, $from, $gid, $name, $path, $prog, $res, $text, $uid);

   $me->NEXT::ACTION_install();

   $base  = $me->{cfg}->{base};
   $prog  = $me->{cfg}->{prog};
   $name  = lc $me->module_name;
   $from  = catdir($me->notes( q(prefix) ), $name, 'default', 'lib');
   $path  = catfile( $me->{cfg}->{binsdir}, $name.'_suid' );

   # Fix hard coded path in suid program
   $me->replace( $me->{cfg}->{prog}, $from, $me->{cfg}->{libsdir}, $path );
   $gid   = getgrnam $me->{cfg}->{group} || 0;
   chown 0, $gid, $path;
   chmod oct q(04750), $path if ($me->{cfg}->{set_uid_root});

   # Restrict access for these files to root only
   $dir   = catdir( $base, 'var', 'secure' );
   chown 0, $gid, $dir;
   chown 0, $gid, catfile( $dir, $me->{cfg}->{administrators}.'.sub' );
   chown 0, $gid, catfile( $dir, 'apache.sub' );

   # Final permission tweaks
   chmod oct q(02770), catfile( $base, 'var', 'etc' );
   chmod oct q(0660),  catfile( $base, 'var', 'logs', 'misc.log' );
   chmod oct q(0640),  catfile( $me->{cfg}->{binsdir}, $name.'_suenv' );

   # Delete the temporary of self that we've just installed from
   $prog->run_cmd( 'rm -rf '.$me->orig_dir() );

   # Announce application availability
   $text  = 'You can connect to the application at http://';
   $text .= $prog->{hostname}.q(/).$name;
   $prog->info( $text );

   # Run custom commands. Can take a *long* time so leave til now
   if ($me->{cfg}->{run_cmd} eq 'yes') {
      $text = 'These commands may take a *long* time to complete';
      $prog->info( $text );

      for $path (@{ $me->{cfg}->{run_cmds} }) {
         $path = catdir( $me->{cfg}->{binsdir}, $path )
            unless ($path =~ m{ \A [/.] }xms);
         $prog->info( 'Running '.$path );
         $prog->info( $prog->run_cmd( $path, { err => q(out) } )->out );
      }
   }
   else {
      for $path (@{ $me->{cfg}->{run_cmds} }) {
         $path = catdir( $me->{cfg}->{binsdir}, $path )
            unless ($path =~ m{ \A [/.] }xms);
         $prog->info( 'Would run '.$path );
      }
   }

   return;
}

sub replace {
   my ($me, $prog, $this, $that, $path) = @_; my ($rdr, $tmp, $wtr);

   unless (-s $path && ($rdr = IO::File->new( $path, q(r) ))) {
      $prog->fatal( 'cannot read '.$path );
   }

   $tmp = $path.'.tmp';

   unless ($wtr = IO::File->new( $tmp, q(w) )) {
      $prog->fatal( 'cannot write '.$tmp );
   }

   while (<$rdr>) { s{ $this }{$that}mx; print {$wtr} $_ }

   $rdr->close(); $wtr->close();

   unless (move( $tmp, $path )) {
      $prog->fatal( 'failed to move '.$tmp.' to '.$path );
   }

   return;
}

sub process_data_files {
   my $me = shift;  return $me->process_files( 'var/db/recipes.tgz', 'blib' );
}

sub process_var_files {
   my $me = shift;

   $Bob::skip_pattern = qr{/recipes|/reports};

   return $me->process_files( 'var', 'blib/var' );
}
EOB
# End of Bob

# Main

my $requires = {
   'perl'                                  => '5.8',
   'Cache::FastMmap'                       => '1.09',
   'Catalyst'                              => '5.70',
   'Catalyst::Plugin::FillInForm'          => '0.06',
   'Catalyst::Plugin::Log::Handler'        => '0.07',
   'Catalyst::Plugin::RequestToken'        => '0.04',
   'Crypt::Twofish_PP'                     => '0.17',
   'Data::Pageset'                         => '1.03',
   'DBIx::Class'                           => '0.07005',
   'Date::Discordian'                      => '1.36',
   'Date::Format'                          => '2.22',
   'DateTime::Event::Sunrise'              => '0.0501',
   'DateTime::Fiction::JRRTolkien::Shire'  => '0.02',
   'Digest::SHA1'                          => '2.11',
   'Email::Valid'                          => '0.179',
   'Exception::Class'                      => '1.23',
   'File::Remove'                          => '0.34',
   'File::ShareDir'                        => '0.05',
   'Getopt::Mixed'                         => '1.008',
   'HTML::GenerateUtil'                    => '1.07',
   'HTML::Tagset'                          => '3.10',
   'Hash::Merge'                           => '0.08',
   'IO::All'                               => '0.38',
   'IO::AtomicFile'                        => '2.110',
   'IO::Interactive'                       => '0.000003',
   'IO::Prompt'                            => '0.099004',
   'KinoSearch'                            => '0.20_04',
   'LWP::UserAgent'                        => '2.033',
   'Log::Handler'                          => '0.11',
   'MealMaster'                            => '0.28',
   'Module::Build'                         => '0.2805',
   'Pod::ProjectDocs'                      => '0.31',
   'Proc::ProcessTable'                    => '0.40',
   'Regexp::Common'                        => '2.120',
   'Syntax::Highlight::Perl'               => '1.00',
   'Template::Stash'                       => '2.9',
   'Template'                              => '2.18',
   'Text::Lorem::More'                     => '0.12',
   'Text::ParseWords'                      => '3.22',
   'Text::Tabs'                            => '98.112801',
   'Time::Elapsed'                         => '0.10',
   'Time::Zone'                            => '2.22',
   'XML::Simple'                           => '2.14' };

my $build = $class->new( create_readme     => 1,
                         create_packlist   => 0,
                         dist_version_from => 'lib/'.$APPNAME.'.pm',
                         license           => q(perl),
                         module_name       => $APPNAME,
                         notes             => { applrel => $APPLREL,
                                                dbname  => $DBNAME,
                                                prefix  => $PREFIX },
                         requires          => $requires );

$build->add_build_element( q(data) );
$build->add_build_element( q(xml) );
$build->add_build_element( q(var) );
$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
