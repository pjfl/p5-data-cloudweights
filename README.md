# Name

Data::CloudWeights - Calculate values for an HTML tag cloud

# Version

Describes version v0.8.$Rev: 1 $ of [Data::CloudWeights](https://metacpan.org/module/Data::CloudWeights)

# Synopsis

    use Data::CloudWeights;

    # Create a new cloud
    my $cloud = Data::CloudWeights->new( \%cfg );

    # Add one or more tags to the cloud
    $cloud->add( $tag, $count, $value );

    # Calculate the tag cloud values
    my $nimbus = $cloud->formation;

# Description

Each tag added to the cloud has a unique name to identify it, a count
which represents the size of the tag and a value that is associated
with the tag. The reference returned by `$cloud->formation()` is a list
of hash refs, one hash ref per tag. In addition to the input
parameters each hash ref contains the scaled size, the percentage of
total and a colour value in the range hot to cold.

The cloud typically displays the tag name and count in the calculated
colour with a font size set equal to the scaled value in the result

# Configuration and Environment

Attributes defined by this class:

- _cold\_colour_

    The six character hex colour for the smallest count in the
    cloud. Defaults to _\#0000FF_ (blue)

- _colour\_pallet_

    An array ref of hex colour values. If the cold\_colour attribute is set
    to null then the colour values from the pallet are used instead of
    calculating the colour value from the scaled count. Defaults to twelve
    values that give an even transition from blue to red

- _decimal\_places_

    The number of decimal places returned in the size attribute. Defaults
    to 2.  With the default values for high and low this lets you set the
    tags font size in ems. If set to 0 and the high/low values suitably
    changed tag font size can be set in pixies

- _hot\_colour_

    The six character hex colour for the highest count in the
    cloud. Defaults to _\#FF0000_ (red)

- _limit_

    Limits the size of the returned list. Defaults to zero, no limit

- _max\_size_

    The upper boundary value to which the highest count in the cloud is
    scaled. Defaults to 3.0 (ems)

- _min\_size_

    The lower boundary value to which the smallest count in the cloud is
    scaled. Defaults to 1.0 (ems)

- _sort\_field_

    Select the field to sort the output by. Values are; _tag_, _count_
    or _value_.  If set to _undef_ the output order will be the same as
    the order of the calls to `add`. If set to a code ref it will be
    called as a sort comparison subroutine and passed two tag references
    whose keys are values listed above

- _sort\_order_

    Either `asc` for ascending or `desc` for descending sort order

- _sort\_type_

    Either `alpha` to use the `cmp` operator or `numeric` to use the
    `<=>` operator in sorting comparisons

# Subroutines/Methods

## new

    $cloud = Data::CloudWeights->new( [{] attr => value, ... [}] )

This is a class method, the constructor for
[Data::CloudWeights](https://metacpan.org/module/Data::CloudWeights). Options are passed as either a list of keyword
value pairs or a hash ref

## BUILD

If the `hot_colour` or `cold_colour` attributes are undefined a
discreet colour value will be selected from the 'pallet' instead of
calculating it using [Color::Spectrum](https://metacpan.org/module/Color::Spectrum)

## add

    $cloud->add( $name, $count, $value );

Adds the tag name, count, and value triple to the cloud. The formation
method returns a ref to an array of hash refs. Each hash ref contains
one of these triples and the calculated attributes. The value argument is
optional. Passing a count of zero will do nothing but returns the
current cumulative total count for this tag name

## formation

    $cloud->formation();

Return a ref to an array of hash refs. The attributes of each hash ref
are:

### colour

Calculated or dereferenced via the pallet, this is the hex colour
string for this tag

### count

The supplied size for this tag. Multiple calls to the add method for
the same tag cause these counts to accumulate

### percent

The percentage of the total count that this tag represents

### size

The count scaled to a value between max\_size and min\_size

### tag

The supplied name for this tag

### value

The supplied value for this tag. This is usually an URI but can be
any scalar. If multiple calls to add the same tag were made this will
be an array ref containing each of the passed values

# Diagnostics

None

# Acknowledgements

- Originally [WWW::CloudCreator](https://metacpan.org/module/WWW::CloudCreator)

    This did not let me calculate font sizes in ems

- [HTML::TagCloud::Sortable](https://metacpan.org/module/HTML::TagCloud::Sortable)

    I lifted the sorting code from here

# Dependencies

- [Color::Spectrum](https://metacpan.org/module/Color::Spectrum)
- [Moose](https://metacpan.org/module/Moose)

# Incompatibilities

There are no known incompatibilities in this module

# Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2008-2012 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/module/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
