#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2009121001;
use t::Common;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my @alphabet = qw { < > [ ] + - . , };

my $pattern1 = RE Comment => 'Brainfuck'; 
my $pattern2 = RE Comment => 'Brainfuck', -Keep => 1;
ok $pattern1, no_nl "Got a pattern for HTML: qr {$pattern1}";
ok $pattern2, no_nl "Got a keep pattern for HTML: qr {$pattern2}";

my $checker = Test::Regexp -> new -> init (
    pattern      => $pattern1,
    keep_pattern => $pattern2,
    name         => "Comment Brainfuck",
);


my @valid = (
    [" ",            "space"],
    ["\n",           "newline"],
    ["$W",           "word"],
    ["$W $W",        "words"],
    ["$W\n$W",       "newline in body"],
    ["/* */",        "C comment"],
);

my @invalid = (
    ["",             "Empty string"],
    ["<>",           "Contains commands"],
);

foreach my $char (@alphabet) {
    push @invalid => ["$W $char $W" => "Contains command"],
}

run_tests
    pass          => \@valid,
    fail          => \@invalid,
    checker       => $checker,
    make_subject  => sub {$_ [0]},
    make_captures => sub {[
        [comment         => $_ [0]],
        [body            => $_ [0]],
    ]}
;

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
