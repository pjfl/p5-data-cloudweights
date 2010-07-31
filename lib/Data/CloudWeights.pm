# @(#)$Id$
# Originally WWW::CloudCreator. Now returns even more raw result

package Data::CloudWeights;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(Class::Accessor::Fast);

my %I_ATTRS =
   ( # Input. Set in constructor or call mutator before formation method
     cold_colour    => q(0000FF),   # Blue
     colour_pallet  => [ qw(CC33FF 663399 3300CC 99CCFF
                            00FFFF 66FFCC 66CC99 006600
                            CCFF66 FFFF33 FF6600 FF0000) ],
     decimal_places => 3,           # Defaults for ems
     hot_colour     => q(FF0000),   # Red
     limit          => 0,           # Max size of returned list. Zero no limit
     max_size       => 3.0,         # Output size no more than
     min_size       => 1.0,         # Output size no less than
     sort_field     => q(tag),      # Output sorted by this field
     sort_order     => q(asc),      # Sort order - asc   or desc
     sort_type      => q(alpha), ); # Sort type  - alpha or numeric

my %O_ATTRS =
   ( # Output. Calling accessors becomes useful after last call to add method
     max_count      => 0,           # Current max value across all tags cloud
     min_count      => -1,          # Current min
     total_count    => 0, );        # Current total for all tags in the cloud

my %P_ATTRS =
   ( # Private.
     _base          => undef,
     _indx          => undef,
     _step          => undef,
     _tags          => undef, );

my %SORTS =
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

__PACKAGE__->mk_accessors( keys %I_ATTRS, keys %O_ATTRS, keys %P_ATTRS );

sub new {
   # Constructor accepts a hash ref or a list of key value pairs
   my ($self, @rest) = @_;

   my $new = bless $self->_merge_attrs( @rest ), ref $self || $self;

   $new->_base( [] );
   $new->_indx( {} );
   $new->_step( [] );
   $new->_tags( [] );

   return $new;
}

sub add {
   # Include the passed args in this cloud's formation
   my ($self, $tag, $count, $value) = @_;

   $tag or return; # Mandatory arg used as a key in tag ref index

   # Mask out null strings and negative numbers from the passed count value
   $count = defined $count ? abs $count : 0;

   # Add this count to the total for this cloud
   $self->total_count( $self->total_count + $count );

   unless (exists $self->_indx->{ $tag }) {
      # Create a new tag reference and add to both list and index
      my $tag_ref = { count => $count, tag => $tag, value => $value };

      push @{ $self->_tags }, $self->_indx->{ $tag } = $tag_ref;
   }
   else {
      # Calls with the same tag are cumulative
      $count += $self->_indx->{ $tag }->{count};
      $self->_indx->{ $tag }->{count} = $count;

      if (defined $value) {
         my $tag_value = $self->_indx->{ $tag }->{value};

         # Make an array if there are two or more calls to add the same tag
         $tag_value and ref $tag_value ne q(ARRAY)
            and $self->_indx->{ $tag }->{value} = [ $tag_value ];

         # Push passed value in each call onto the values array.
         if ($tag_value) { push @{ $self->_indx->{ $tag }->{value} }, $value }
         else { $self->_indx->{ $tag }->{value} = $value }
      }
   }

   # Update this cloud's max and min values
   $count > $self->max_count and $self->max_count( $count );
   $self->min_count == -1    and $self->min_count( $count );
   $count < $self->min_count and $self->min_count( $count );

   # Return the current cumulative count for this tag
   return $count;
}

sub formation {
   # Calculate the result set for this cloud
   my $self    = shift;
   my $prec    = 10**$self->decimal_places;
   my $range   = (abs $self->max_count - $self->min_count) || 1;
   my $step    = ($self->max_size - $self->min_size) / $range;
   my $compare = $self->_get_sort_method;
   my $ntags   = @{ $self->_tags };
   my $out     = [];

   $ntags == 0 and return $out; # No calls to add were made

   if ($ntags == 1) {            # One call to add was made
      $out = [ { colour  => $self->hot_colour || pop @{ $self->colour_pallet },
                 count   => $self->_tags->[ 0 ]->{count},
                 percent => 100,
                 size    => $self->max_size,
                 tag     => $self->_tags->[ 0 ]->{tag},
                 value   => $self->_tags->[ 0 ]->{value} } ];
      return $out;
   }

   for (sort { $compare->( $a, $b ) } @{ $self->_tags }) {
      my $count   = $_->{count};
      my $percent = 100 * $count / $self->total_count;
      my $size    = $self->min_size + $step * ($count - $self->min_count);

      # Push the return array with a hash ref for each key value pair
      # passed to the add method
      push @{ $out }, { colour  => $self->_calculate_temperature( $count ),
                        count   => $count,
                        percent => (int 0.5 + $prec * $percent) / $prec,
                        size    => (int 0.5 + $prec * $size   ) / $prec,
                        tag     => $_->{tag},
                        value   => $_->{value} };

      $self->limit and @{ $out } == $self->limit and last;
   }

   return $out;
}

# Private methods begin with _

sub _get_sort_method {
   # Multiple calls to add were made, determine the sorting method
   my $self = shift;

   # No sorting if sort field is false
   my $field = $self->sort_field or return sub { return 0 };

   ref $field and return $field; # User supplied subroutine

   my $orderby = $SORTS{ lc $self->sort_type  }
                       { lc $self->sort_order }->( $field );

   # Protect against wrong sort type for the data
   return $field ne q(tag)
        ? sub { return $orderby->( @_ ) || $_[ 0 ]->{tag} cmp $_[ 1 ]->{tag} }
        : $orderby;
}

sub _hex2dec {
   # Simple conversion sub
   my ($self, $index, $val) = @_;

   return 16 * (hex substr $val, 2 * $index, 1)
             + (hex substr $val, 2 * $index + 1, 1);
}

sub _calculate_temperature {
   # Generate an RGB colour for a given count
   my ($self, $cnt) = @_; $cnt -= $self->min_count;

   my $colour; my $range = (abs $self->max_count - $self->min_count) || 1;

   # Unsetting hot or cold colour strings in the constructor will cause
   # the pallet to be used instead of the exact calculation method

   if ($self->hot_colour and $self->cold_colour) {
      unless (defined $self->_base->[ 0 ]) {
         # Setup the RGB colour increment steps
         for (0 .. 2) {
            my $cold = $self->_base->[ $_ ]
                     = $self->_hex2dec( $_, $self->cold_colour );
            my $hot  = $self->_hex2dec( $_, $self->hot_colour );

            $self->_step->[ $_ ] = ($hot - $cold) / $range;
         }
      }

      # Exact calculation method
      for (0 .. 2) {
         my $hex = $self->_base->[ $_ ] + $cnt * $self->_step->[ $_ ];

         $colour .= sprintf '%02x', $hex;
      }
   }
   else {
      # Select colour from the pallet by allocating the value to a band
      my $bands = scalar @{ $self->colour_pallet };
      my $index = int 0.5 + ($cnt * ($bands - 1) / $range);

      $colour = $self->colour_pallet->[ $index ];
   }

   return $colour;
}

sub _merge_attrs {
   my ($self, @rest) = @_;

   my $args = $rest[ 0 ] && ref $rest[ 0 ] eq q(HASH) ? $rest[ 0 ] : { @rest };

   return { %I_ATTRS, %{ $args }, %O_ATTRS };
}

1;

__END__

=pod

=head1 Name

Data::CloudWeights - Calculate values for an HTML tag cloud

=head1 Version

0.3.$Rev$

=head1 Synopsis

   use Data::CloudWeights;

   # Create a new cloud
   my $cloud = Data::CloudWeights->new( \%cfg );

   # Add one or more tags to the cloud
   $cloud->add( $tag, $count, $value );

   # Calculate the tag cloud values
   my $nimbus = $cloud->formation();

=head1 Description

Each tag added to the cloud has a unique name to identify it, a count
which represents the size of the tag and a value that is associated
with the tag. The reference returned by C<< $cloud->formation() >> is a list
of hash refs, one hash ref per tag. In addition to the input
parameters each hash ref contains the scaled size, the percentage of
total and a colour value in the range hot to cold.

The cloud typically displays the tag name and count in the calculated
colour with a font size set equal to the scaled value in the result

=head1 Configuration and Environment

Attributes defined by this class:

=over 3

=item I<cold_colour>

The six character hex colour for the smallest count in the
cloud. Defaults to I<0000FF> (blue)

=item I<colour_pallet>

An array ref of hex colour values. If the cold_colour attribute is set
to null then the colour values from the pallet are used instead of
calculating the colour value from the scaled count. Defaults to twelve
values that give an even transition from blue to red

=item I<decimal_places>

The number of decimal places returned in the size attribute. Defaults
to 2.  With the default values for high and low this lets you set the
tags font size in ems. If set to 0 and the high/low values suitably
changed tag font size can be set in pixies

=item I<hot_colour>

The six character hex colour for the highest count in the
cloud. Defaults to I<FF0000> (red)

=item I<limit>

Limits the size of the returned list. Defaults to zero, no limit

=item I<max_size>

The upper boundary value to which the highest count in the cloud is
scaled. Defaults to 2.0 (ems)

=item I<min_size>

The lower boundary value to which the smallest count in the cloud is
scaled. Defaults to 0.66 (ems)

=item I<sort_field>

Select the field to sort the output by. Values are; I<tag>, I<count>
or I<value>.  If set to I<undef> the output order will be the same as
the order of the calls to C<add>. If set to a code ref it will be
called as a sort comparison subroutine and passed two tag references
whose keys are values listed above

=item I<sort_order>

Either I<asc> for ascending or I<desc> for descending sort order

=item I<sort_type>

Either I<alpha> to use the C<cmp> operator or I<numeric> to use the
C<< <=> >> operator in sorting comparisons

=back

=head1 Subroutines/Methods

=head2 new

   $cloud = Data::CloudWeights->new( [{] attr => value, ... [}] )

This is a class method, the constructor for
L<Data::CloudWeights>. Options are passed as either a list of keyword
value pairs or a hash ref

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

=head2 _merge_attrs

   $attrs = $class->_merge_attrs( @rest );

Merge config defaults with supplied parameters and return the object's
attribute hash. Called from the constructor

=head1 Diagnostics

None

=head1 Acknowledgements

=over 3

=item Originally L<WWW::CloudCreator>

This did not let me calculate font sizes in ems

=item L<HTML::TagCloud::Sortable>

I lifted the sorting code from here

=back

=head1 Dependencies

=over 3

=item L<Class::Accessor::Fast>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008-2009 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:

