#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2009121001;
use t::Common;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 'Comment';

my $SPACE   = " ";        # Space
my $SEPCHAR = "\t";       # Tab
my $RS      = "\x{0A}";   # \r, Carriage Return
my $RE      = "\x{0D}";   # \n, New Line
my $MDO     = "<!";
my $MDC     = ">";
my $COM     = "--";

my $pattern1 = RE Comment => 'HTML'; 
my $pattern2 = RE Comment => 'HTML', -Keep => 1;
ok $pattern1, no_nl "Got a pattern for HTML: qr {$pattern1}";
ok $pattern2, no_nl "Got a keep pattern for HTML: qr {$pattern2}";

my $checker = Test::Regexp -> new -> init (
    pattern      => $pattern1,
    keep_pattern => $pattern2,
    name         => "Comment HTML",
);


my @valid = (
    ["",             "empty body"],
    [" ",            "body is space"],
    ["\n",           "body is newline"],
    ["$W",           "standard body"],
    ["$W $W",        "standard body"],
    ["$W\n$W",       "newline in body"],
    [" - ",          "dash"],
    [" - $W - ",     "dashes"],
    [" /* */ ",      "C comment"],
    [" /* $W */ ",   "C comment"],
    ["> $W ",        "Fake close"],
    ["\n <!",        "Fake open"],
    ["> <!",         "Fake open/close"],
);

my @invalid = (
    ["<!-- -- -->",   "COM inside"],
    ["< !-- -->",     "Broken MDO"],
    ["<!- - -->",     "Broken COM"],
    ["<!-- - ->",     "Broken COM"],
    ["<! -- -->",     "Leading whitespace"],
    ["-- $W -->",     "No MDO"],
    ["<!-- $W --",    "No MDC"],
    ["<! $W -->",     "No COM"],
    ["<!-- $W >",     "No COM"],
    [" <!-- $W -->",  "Leading garbage"],
    ["<!-- $W --> ",  "Trailing garbage"],
    ["<!-- $W -->\n", "Trailing newline"],
    ["<!- $W -->",    "Incomplete COM"],
    ["<!-- $W ->",    "Incomplete COM"],
);

my @whitespace = (
    "", $SPACE, $RS, $RE, ($SPACE x 4), ($RS x 2), ($RE x 11),
    ($SEPCHAR x 7),
    "$RE$SPACE$RS$SPACE$RE$SEPCHAR"
);

my @bad_ws = (
    "\x{0b}", "\x{85}", "\x{A0}", "\x{2029}", "\x{2002}", 
    " $W ",
);


run_tests
    pass          => \@valid,
    fail          => \@invalid,
    checker       => $checker,
    make_subject  => sub {"$MDO$COM" . $_ [0] . "$COM$MDC"},
    make_captures => sub {[
        [MDO             => $MDO],
        [body            => $COM . $_ [0] . $COM],
        [COM             => $COM],
        [first           => $_ [0]],
        [MDC             => $MDC]],
    }
;


#
# Trailing whitespace tests.
#
my @pass = map {
    [$valid [rand @valid] [0], $_, "whitespace"];
} @whitespace;
my @fail = map {
    ["<!--" . $valid [rand @valid] [0] . "--$_", "bad whitespace"]
} @bad_ws;


run_tests
    pass          => \@pass,
    fail          => \@fail,
    checker       => $checker,
    make_subject  => sub {"$MDO$COM" . $_ [0] . $COM . $_ [1] . $MDC},
    make_captures => sub {[
        [MDO             => $MDO],
        [body            => $COM . $_ [0] . $COM . $_ [1]],
        [COM             => $COM],
        [first           => $_ [0]],
        [MDC             => $MDC]],
    }
;

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
