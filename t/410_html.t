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

my $pattern1 = RE Comment => 'HTML'; 
my $pattern2 = RE Comment => 'HTML', -Keep => 1;
ok $pattern1, "Got a pattern for HTML: qr {$pattern1}";
ok $pattern2, "Got a keep pattern for HTML: qr {$pattern2}";

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
);

run_tests
    pass          => \@valid,
    checker       => $checker,
    make_subject  => sub {"<!--" . $_ [0] . "-->"},
    make_captures => sub {[
        [comment         => "<!--" . $_ [0] . "-->"],
        [MDO             => "<!"],
        [body            => "--" . $_ [0] . "--"],
        [COM             => "--"],
        [first           => $_ [0]],
        [MDC             => ">"]],
    };


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
