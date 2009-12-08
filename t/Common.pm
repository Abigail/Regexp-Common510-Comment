package t::Common;

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Tie::Scalar;
use Exporter ();

our @ISA    = qw [Tie::StdScalar Exporter];
our @EXPORT = qw [$W run_tests];

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


sub run_tests {
    my %arg           = @_;
    my $pass          = $arg {pass} || [];
    my $fail          = $arg {fail} || [];
    my $checker       = $arg {checker},
    my $make_subject  = $arg {make_subject};
    my $make_captures = $arg {make_captures};

    my $errors = 0;

    foreach my $test (@$pass) {
        my $reason   = pop @$test;
        my $subject  = $make_subject  -> (@$test);
        my $captures = $make_captures -> (@$test);
        $errors ++ unless
            $checker -> match ($subject, $captures,
                               test    => $reason);
    }

    foreach my $fail (@$fail) {
        my ($subject, $reason) = @$fail;
        $errors ++ unless
            $checker -> no_match ($subject, reason => $reason);
    }

    BAIL_OUT if $errors && $ENV {BAILOUT_EARLY};
}

__END__
