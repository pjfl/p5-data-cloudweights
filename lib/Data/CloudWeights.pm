package Data::CloudWeights;

# @(#)$Id$
# Originally WWW::CloudCreator. Now returns even more raw result

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use Readonly;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

Readonly my %ATTRS =>
   ( # Input. Set in constructor or call mutator before formation method
     cold_colour    => q(0000FF),  # Blue
     colour_pallet  => [ qw(CC33FF 663399 3300CC 99CCFF
                            00FFFF 66FFCC 66CC99 006600
                            CCFF66 FFFF33 FF6600 FF0000) ],
     decimal_places => 2,          # Defaults for ems
     hot_colour     => q(FF0000),  # Red
     max_size       => 2.0,        # Output size no more than
     min_size       => 0.66,       # Output size no less than
     sort_field     => q(name),    # Output sorted by this field
     sort_order     => q(asc),     # Sort order - asc   or desc
     sort_type      => q(alpha),   # Sort type  - alpha or numeric

     # Output. Calling accessors becomes useful after last call to add method
     max_count      => 0,          # Current max value across all tags cloud
     min_count      => -1,         # Current min
     total_count    => 0,          # Current total for all tags in the cloud

     # Private.
     _base          => undef,
     _indx          => undef,
     _step          => undef,
     _tags          => undef, );

Readonly my %SORTS =>
   ( alpha => {
        asc  => sub {
           my $f = shift; return sub { $_[ 0 ]->{ $f } cmp $_[ 1 ]->{ $f } }
        },
        desc => sub {
           my $f = shift; return sub { $_[ 1 ]->{ $f } cmp $_[ 0 ]->{ $f } }
        },
     },
     numeric => {
        asc  => sub {
           my $f = shift; return sub { $_[ 0 ]->{ $f } <=> $_[ 1 ]->{ $f } }
        },
        desc => sub {
           my $f = shift; return sub { $_[ 1 ]->{ $f } <=> $_[ 0 ]->{ $f } }
        },
     }, );

__PACKAGE__->mk_accessors( keys %ATTRS );

sub new {
   # Constructor accepts a hash ref or a list of key value pairs
   my ($me, @rest) = @_;
   my $args        = $me->_arg_list( @rest );
   my $self        = bless { %ATTRS }, ref $me || $me;

   for (grep { exists $self->{ $_ } } keys %{ $args }) {
      $self->$_( $args->{ $_ } );
   }

   $self->_base( [] );
   $self->_indx( {} );
   $self->_step( [] );
   $self->_tags( [] );
   return $self;
}

sub add {
   # Include the passed args in this cloud's formation
   my ($me, $tag, $count, $value) = @_;

   return unless ($tag); # Mandatory arg used as a key in counts and values

   # Mask out null strings and negative numbers from the passed count value
   $count  = defined $count ? abs $count : 0;

   # Add this count to the total for this cloud
   $me->total_count( $me->total_count + $count );

   if (exists $me->_indx->{ $tag }) {
      # Calls with the same tag are cumulative
      $count += $me->_indx->{ $tag }->{counts};
      $me->_indx->{ $tag }->{counts} = $count;

      if (defined $value) {
         my $tag_value = $me->_indx->{ $tag }->{values};

         # Make an array if there are two or more calls to add the same tag
         if ($tag_value && ref $tag_value ne q(ARRAY)) {
            $me->_indx->{ $tag }->{values} = [ $tag_value ];
         }

         # Push passed value in each call onto the values array.
         if ($tag_value) { push @{ $me->_indx->{ $tag }->{values} }, $value }
         else { $me->_indx->{ $tag }->{values} = $value }
      }
   }
   else {
      # Create a new tag reference and add to both list and index
      my $tag_ref = { counts => $count, name => $tag, values => $value };
      $me->_indx->{ $tag } = $tag_ref;
      push @{ $me->_tags }, $tag_ref;
   }

   # Update this cloud's max and min values
   $me->max_count( $count ) if ($count > $me->max_count);
   $me->min_count( $count ) if ($me->min_count == -1);
   $me->min_count( $count ) if ($count < $me->min_count);

   # Return the current cumulative count for this tag
   return $count;
}

sub formation {
   # Calculate the result set for this cloud
   my ($count, $field, $me, $ntags, $orderby, $out, $prec, $ratio);
   my ($rng, $size, $sort_ref, $step);

   $me    = shift;
   $prec  = 10**$me->decimal_places;
   $rng   = abs $me->max_count - $me->min_count || 1;
   $step  = ($me->max_size - $me->min_size) / $rng;
   $ntags = @{ $me->_tags };
   $out   = [];

   return $out if ($ntags == 0); # No calls to add were made

   if ($ntags == 1) {            # One call to add was made
      $out = [ { colour  => $me->hot_colour || pop @{ $me->colour_pallet },
                 count   => $me->_tags->[0]->{counts},
                 percent => 100,
                 size    => $me->max_size,
                 tag     => $me->_tags->[0]->{name},
                 value   => $me->_tags->[0]->{values} } ];
      return $out;
   }

   # Multiple calls to add were made, determine the sorting method
   if ($field = $me->sort_field) {
      unless (ref $field) {
         $orderby  = $SORTS{ lc $me->sort_type  }
                           { lc $me->sort_order }->( $field );
         # Protect against wrong sort type for the data
         $sort_ref = $field ne q(name)
                   ? sub { return $orderby->( @_ )
                               || $_[0]->{name} cmp $_[1]->{name} }
                   : $orderby;
      }
      else { $sort_ref = $field } # User supplied subroutine
   }
   else { $sort_ref = sub { return 1 } } # No sorting if sort field is undef

   for (sort { $sort_ref->( $a, $b ) } @{ $me->_tags }) {
      $count = $_->{counts};
      $ratio = $count / $me->total_count;
      $size  = $me->min_size + $step * ($count - $me->min_count);

      # Push the return array with a hash ref for each key value pair
      # passed to the add method
      push @{ $out }, { colour  => $me->_calculate_temperature( $count ),
                        count   => $count,
                        percent => (int 0.5 + $prec * 100 * $ratio) / $prec,
                        size    => (int 0.5 + $prec * $size) / $prec,
                        tag     => $_->{name},
                        value   => $_->{values} };
   }

   return $out;
}

# Private methods begin with _

sub _arg_list {
   my ($me, @rest) = @_;

   return {} unless ($rest[0]);

   return ref $rest[0] eq q(HASH) ? $rest[0] : { @rest };
}

sub _hex2dec {
   # Simple conversion sub
   my ($me, $index, $val) = @_;

   return 16 * (hex substr $val, 2 * $index, 1)
             + (hex substr $val, 2 * $index + 1, 1);
}

sub _calculate_temperature {
   # Generate an RGB colour for a given count
   my ($me, $cnt) = @_; my ($bands, $cold, $colour, $hot, $index, $rng);

   $cnt -= $me->min_count;
   $rng  = (abs $me->max_count - $me->min_count) || 1;

   # Unsetting hot or cold colour strings in the constructor will cause
   # the pallet to be used instead of the exact calculation method

   if ($me->hot_colour && $me->cold_colour) {
      unless (defined $me->_base->[0]) {
         # Setup the RGB colour increment steps
         for (0 .. 2) {
            $cold = $me->_base->[$_] = $me->_hex2dec( $_, $me->cold_colour );
            $hot  = $me->_hex2dec( $_, $me->hot_colour );
            $me->_step->[$_] = ($hot - $cold) / $rng;
         }
      }

      # Exact calculation method
      for (0 .. 2) {
         $colour .= sprintf '%02x', $me->_base->[$_] + $cnt * $me->_step->[$_];
      }
   }
   else {
      # Select colour from the pallet by allocating the value to a band
      $bands  = scalar @{ $me->colour_pallet };
      $index  = int 0.5 + ($cnt * ($bands - 1) / $rng);
      $colour = $me->colour_pallet->[ $index ];
   }

   return $colour;
}

1;

__END__

=pod

=head1 Name

Data::CloudWeights - Calculate values for an HTML tag cloud

=head1 Version

0.2.$Rev$

=head1 Synopsis

   use Data::CloudWeights;

   # Create a new cloud
   my $cloud = Data::CloudWeights->new( \%cfg );

   # Add one or more tags to the cloud
   $cloud->add( $name, $count, $value );

   # Calculate the tag cloud values
   my $nimbus = $cloud->formation();

=head1 Description

Each tag added to the cloud has a unique name to identify it, a count
which represents the size of the tag and a value that is associated
with the tag. The reference returned by C<$cloud-E<gt>formation()> is a list
of hash refs, one hash ref per tag. In addition to the input
parameters each hash ref contains the scaled size, the percentage of
total and a colour value in the range hot to cold.

The cloud typically displays the tag name and count in the calculated
colour with a font size set equal to the scaled value in the result

=head1 Configuration and Environment

=head2 new

   $cloud = Data::CloudWeights->new( [{] attr => value, ... [}] )

This is a class method, the constructor for Data::CloudWeights. Options are
passed as either a list of keyword value pairs or a hash ref. Options are:

=head3 cold_colour

The six character hex colour for the smallest count in the
cloud. Defaults to 0000FF (blue)

=head3 colour_pallet

An array ref of hex colour values. If the cold_colour attribute is set
to null then the colour values from the pallet are used instead of
calculating the colour value from the scaled count. Defaults to twelve
values that give an even transition from blue to red

=head3 decimal_places

The number of decimal places returned in the size attribute. Defaults
to 2.  With the default values for high and low this lets you set the
tags font size in ems. If set to 0 and the high/low values suitably
changed tag font size can be set in pixies

=head3 hot_colour

The six character hex colour for the highest count in the
cloud. Defaults to FF0000 (red)

=head3 max_size

The upper boundary value to which the highest count in the cloud is
scaled. Defaults to 2.0 (ems)

=head3 min_size

The lower boundary value to which the smallest count in the cloud is
scaled. Defaults to 0.66 (ems)

=head3 sort_field

Select the field to sort the output by. Values are; I<name>, I<counts>
or I<values>.  If set to I<undef> the output order will be the same as
the order of the calls to C<add>. If set to a code ref it will be
called as a sort comparison subroutine and passed two tag references
whose fields are values listed above

=head3 sort_order

Either I<asc> for ascending or I<desc> for descending sort order

=head3 sort_type

Either I<alpha> to use the C<cmp> operator or I<numeric> to use the
C<E<lt>=E<gt>> operator in sorting comparisons

=head1 Subroutines/Methods

=head2 add

   $cloud->add( $name, $count, $value );

Adds the tag name, count, and value triple to the cloud. The formation
method returns a ref to an array of hash refs. Each hash ref contains
one of these triples and the calculated attributes. The value arg is
optional. Passing a count of zero will do nothing but returns the
current cumulative total count for this tag name

=head2 formation

   $cloud->formation();

Return a ref to an array of hash refs. The attributes of each hash ref
are:

=head3 colour

Calculated or dereferenced via the pallet, this is the hex colour
string for this tag

=head3 count

The supplied size for this tag. Multiple calls to the add method for
the same tag cause these counts to accumulate

=head3 percent

The percentage of the total count that this tag represents

=head3 size

The count scaled to a value between max_size and min_size

=head3 tag

The supplied name for this tag

=head3 value

The supplied value for this tag. This is usually an href but can be
any scalar. If multiple calls to add the same tag were made this will
be an array ref containing each of the passed values

=head2 _hex2dec

   $class->_hex2dec( $index, $hex_value );

Private method converts a two character string representation of a
number to a decimal integer in the range 0 - 255

=head2 _calculate_temperature

   $obj->_calculate_temperature( $count );

Private method used internally to calculate a colour value for a
tag. If the 'hot' or 'cold' value is undefined a discreet colour value
will be selected from the 'pallet' instead of calculating it using a
continuous function

=head1 Diagnostics

None

=head1 Acknowledgements

=over 4

=item Originally L<WWW::CloudCreator>

This did not let me calculate font sizes in ems

=item L<HTML::TagCloud::Sortable>

I lifted the sorting code from here

=back

=head1 Dependencies

=over 4

=item L<Class::Accessor::Fast>

=item L<Readonly>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module.

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome.

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008 Peter Flanigan. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
