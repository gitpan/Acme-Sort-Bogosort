package Acme::Sort::Bogosort;

use 5.010;

use strict;
use warnings;

use parent qw/Exporter/;
use Carp 'croak';

use List::Util qw/shuffle/;

our @EXPORT = qw/bogosort/;

our $VERSION = '0.04';



#   bogosort()
#   Usage:
#   Sort a list in standard string comparison order.
#
#   my @sorted = bogosort( @unsorted );
#
#   Sort a list in ascending numerical order:
#   sub compare { return $_[0] <=> $_[1] };
#   my @sorted = bogosort( \&compare, @unsorted );
#
#   Warning: Average case is O( (e-1) * n! ).
#   Warning: Worst case approaches O(INF).
#
#   bogosort() is exported automatically upon use.

sub bogosort {
    my $compare = ref( $_[0] ) =~ /CODE/ 
        ?   shift
        :   \&compare;
    return @_ if @_ < 2;
    my @list = @_;
    @list = shuffle( @list ) while not is_ordered( $compare, \@list );
    return @list;
}



# Internal use, not exported.  Verifies order based on $compare->().
sub is_ordered {
    my ( $compare, $listref ) = @_;
    ref( $compare ) =~ /CODE/ 
        or croak "is_ordered() expects a coderef as first arg.";
    ref( $listref ) =~ /ARRAY/
        or croak "is_ordered() expects an arrayref as second arg.";
    foreach( 0 .. $#{$listref} - 1 ) {
        return 0 
            if $compare->( $listref->[ $_ ], $listref->[ $_ + 1 ] ) > 0;
    }
    return 1;
}

# Default compare() is ascending standard string comparison order.
sub compare {
    croak "compare() requires two args."
        unless scalar @_ == 2;
    return $_[0] cmp $_[1];
}


=head1 NAME

Acme::Sort::Bogosort - Implementation of a Bogosort (aka 'stupid sort' or 'slowsort').

=head1 VERSION

Version 0.04

=head1 SYNOPSIS

The Bogosort is a sort that is based on the "generate and test" paradigm.  It works by 
first testing whether the input is in sorted order.  If so, return the list.  But if not, 
randomly shuffle the input and test again.  Repeat until the shuffle comes back sorted.

    use Acme::Sort::Bogosort;

    my @unsorted = qw/ E B A C D /;
    my @ascending = bogosort( @unsorted );
    
    my @descending = bogosort(
        sub{ return $_[1] cmp $_[0]; },
        @unsorted
    );

The Bogosort has a worst case of O(INF), though as time approaches infinity the odds of not 
finding a solution decline toward zero (assuming a good random number generator).  The average 
case is O( (n-1) * n! ).  The n! term signifies how many shuffles will be required to obtain 
a sorted result in the average case.  However, there is no guarantee that any particular sort 
will come in anywhere near average.

Keep in mind that a list of five items consumes an average of 5!, or 120 iterations.  10! is 
3,628,800 shuffles.  Also keep in mind that each shuffle itself is an O(n-1) operation.  
Unless you need to heat a cold office with your processor avoid sorts on large data sets.

=head1 EXPORT

Always exports one function: C<bogosort()>.

=head1 SUBROUTINES/METHODS

=head2 bogosort( @unsorted )

Accepts a list as a parameter and returns a sorted list.

If the first parameter is a reference to a subroutine, it will be used as the
comparison function.

The Bogosort is probably mostly useful as a teaching example of a terrible sort 
algorithm.  There are approximately 1e80 atoms in the universe.  A sort list of 
59 elements will gain an average case solution of 1e80 iterations, with a worst 
case approaching infinite iterations to find a solution.  Anything beyond just a 
few items takes a considerable amount of work.

Each iteration checks first to see if the list is in order.  Here a comparatively 
minor optimization is that the first out-of-order element will short-circuit the 
check.  That step has a worst case of O(n), and average case of nearly O(1).  
That's the only good news.  Once it is determined that the list is out 
of order, the entire list is shuffled (an O(n) operation).  Then the test happens 
all over again, repeating until a solution is happened across by chance.

There is a potential for this sort to never finish, since a typical random number
synthesizer does not generate an infinitely non-repeating series.  Because this 
algorithm has the capability of producing O(INF) iterations, it would need an 
infinite source of random numbers to find a solution in any given dataset.  

Small datasets are unlikely to encounter this problem, but as the dataset grows, 
so does the propensity for running through the entire set of pseudo-random numbers 
generated by Perl's rand() for a given seed.  None of this really matters, of course, 
as no sane individual would ever use this for any serious sorting work.

Not every individual is sane.

=cut


=head2 compare( $a, $b )

By passing a subref as the first parameter to C<bogosort()>, the user is able to 
manipulate sort orders just as is done with Perl's built in C< sort { code } @list > 
routine.

The comparison function is easy to implement using Perl's C<< <=> >> and C< cmp > 
operators, but any amount of creativity is ok so long as return values are negative 
for "Order is ok", positive for "Order is not ok", and 0 for "Terms are equal 
(Order is ok)".

=cut


=head1 AUTHOR

David Oswald, C<< <davido[at]cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-acme-sort-bogosort at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Acme-Sort-Bogosort>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Acme::Sort::Bogosort


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Acme-Sort-Bogosort>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Acme-Sort-Bogosort>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Acme-Sort-Bogosort>

=item * Search CPAN

L<http://search.cpan.org/dist/Acme-Sort-Bogosort/>

=back


=head1 ACKNOWLEDGEMENTS

L<http://en.wikipedia.org/wiki/Bogosort> - A nice Wikipedia article on the Bogosort.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 David Oswald.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Acme::Sort::Bogosort
