#!perl

use Test::More tests => 12;
use Try::Tiny;
use List::Util qw/shuffle/;
use v5.10;

BEGIN {
    use_ok( 'ACME::Sort::Bogosort' ) || print "Bail out!\n";
}

diag( "Testing ACME::Sort::Bogosort $ACME::Sort::Bogosort::VERSION, Perl $], $^X" );

can_ok( 'ACME::Sort::Bogosort', qw/bogosort is_ordered compare/ );


note ( "Testing ACME::Sort::Bogosort::compare()" );
my %comparisons = (
    descending  => [ 'B', 'A',  1, "compare( qw/B A/ ) ==  1" ],
    ascending   => [ 'A', 'B', -1, "compare( qw/A B/ ) == -1" ],
    equal       => [ 'A', 'A',  0, "compare( qw/A A/ ) ==  0" ],
);
foreach my $comp ( keys %comparisons ) {
    is( 
        ACME::Sort::Bogosort::compare( 
            $comparisons{$comp}[0], 
            $comparisons{$comp}[1] 
        ),
        $comparisons{$comp}[2],
        $comparisons{$comp}[3]
    );
}

my $caught;
try {
    ACME::Sort::Bogosort::compare( 'A' );
} catch {
    $caught = $_;
};

like(
    $caught,
    qr/requires two/,
    "compare() throws exception if given other than two args to compare."
);


note( "Testing ACME::Sort::Bogosort::is_ordered() -- Default ascending order." );
my $compare = \&ACME::Sort::Bogosort::compare;
is( 
    ACME::Sort::Bogosort::is_ordered( $compare, [ qw/ A B C D E / ] ), 
    1, 
    "is_ordered( \&compare, [ qw/ A B C D E / ] ) returns true." 
);

isnt(
    ACME::Sort::Bogosort::is_ordered( $compare, [ qw/ E D C B A / ] ),
    1,
    "is_ordered( \&compare, [ qw/ E D C B A / ] ) returns false."
);

undef $caught;
try {
    ACME::Sort::Bogosort::is_ordered( [ qw/ A B C D E / ] );
} catch { $caught = $_ };
like( 
    $caught, 
    qr/expects a coderef/, 
    "is_ordered() throws exception when not handed a coderef as first param."
);

undef $caught;
try {
    ACME::Sort::Bogosort::is_ordered( $compare, qw/ A B C D E / );
} catch { $caught = $_ };
like(
    $caught,
    qr/expects an arrayref/,
    "is_ordered() throws an exception when not handed an arrayref as second param."
);

note "Testing ACME::Sort::Bogosort::bogosort().";
my @unsorted = shuffle( 'A' .. 'E' );
my @sorted = bogosort( @unsorted );
is_deeply( 
    \@sorted, 
    [ qw/ A B C D E / ], 
    "bogosort( qw/ A B C D E / ) - Default sort order returns correct results."
);
@sorted = bogosort( \&my_cmp, @unsorted );
is_deeply( 
    \@sorted, 
    [ qw/ E D C B A / ], 
    "bogosort( \&my_cmp, @unsorted ) - Alternate sort order via coderef returns correct results." 
);

# Provide a reverse standard string comparison order alternative.
sub my_cmp {
    return $_[1] cmp $_[0];
}
