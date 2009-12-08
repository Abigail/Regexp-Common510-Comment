package t::Common;

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Tie::Scalar;
use Exporter ();

our @ISA    = qw [Tie::StdScalar Exporter];
our @EXPORT = qw [$W];

our $ams = eval "require Acme::MetaSyntactic; 1";

my @random;
if ($ams) {
    local $^W = 0;  # Surpress a warning in Acme::MetaSyntactic.
    push @random => "Acme::MetaSyntactic" -> new ($_) -> name (0)
          for "Acme::MetaSyntactic" -> themes;
}
else {
    @random = qw [plugh thud corge grault fred foobar fubar garply qux
                  waldo foo quux xyzzy baz bar];
}

sub FETCH {my $_ = $random [rand @random]; s/_+/ /g; $_}

tie our $W => __PACKAGE__;


__END__
