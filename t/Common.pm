package t::Common;

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Tie::Scalar;
use Exporter ();
use Regexp::Common510 -api => 'RE';

our @ISA     = qw [Tie::StdScalar Exporter];
our @EXPORT  = qw [$W $BIG run_tests parse_lang];

my  $LANG    = "";
my  $FLAVOUR = "";

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

sub FETCH {
  start:
    my $_ = $random [rand @random];
    s/_+/ /g;
    goto start if $LANG eq 'Algol 68' && /^co(?:mment)?$/i
               || $LANG eq 'INTERCAL' && /DO/;
    $_
}

tie our $W => __PACKAGE__;

our $BIG = (join "" => 'a' .. 'z', 'A' .. 'Z', 0 .. 9) x 20;

sub parse_lang ($) {
    $LANG    = "";
    $FLAVOUR = "";
    if (ref $_ [0]) {
        $LANG    = $_ [0] [0];
        $FLAVOUR = $_ [0] [1] // "";
    }
    else {
        $LANG    = $_ [0];
    }
    ($LANG, $FLAVOUR);
}

sub run_tests {
    my %arg           = @_;
    my $pass          = $arg {pass} || [];
    my $fail          = $arg {fail} || [];
    my $checker       = $arg {checker};
    my $make_subject  = $arg {make_subject};
    my $make_captures = $arg {make_captures};
    my $lang          = $arg {language};
    my $flavour       = $arg {flavour};

    unless ($checker) {
        return unless $lang;
        
        my $pat_name  = $lang;
        my @args;
        if ($flavour) {
            @args     =        (-flavour => $flavour);
            $pat_name = "$lang (-flavour => $flavour)";
        }

        my $pattern1 = RE Comment => $lang, @args;
        my $pattern2 = RE Comment => $lang, @args, -Keep => 1;
        ok $pattern1, "Got a pattern for $pat_name ($pattern1)";
        ok $pattern2, "Got a keep pattern for $pat_name ($pattern2)";

        $checker = Test::Regexp -> new -> init (
            pattern      => $pattern1,
            keep_pattern => $pattern2,
            name         => "Comment $pat_name",
        );
    }

    my $errors = 0;

    foreach my $test (@$pass) {
        my $reason   = pop @$test;
        my $subject  = $make_subject  -> (@$test);
        my $captures = $make_captures -> (@$test);
        my @args;
        push @args   => test => $reason;
        push @args   => ghost_name_captures => $arg {ghost_name_captures} || 0;
        push @args   => ghost_num_captures  => $arg {ghost_num_captures}  || 0;
        push @args   => filter_undef        => $arg {filter_undef}        || 0;
        $errors ++ unless
            $checker -> match ($subject, $captures, @args);
    }

    foreach my $fail (@$fail) {
        my ($subject, $reason) = @$fail;
        my @args;
        push @args   => reason => $reason;
        $errors ++ unless
            $checker -> no_match ($subject, @args);
    }

    BAIL_OUT if $errors && $ENV {BAILOUT_EARLY};
}

__END__
