#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';
use t::Common;

use strict;
use warnings;
no  warnings 'syntax';

our $r = eval "require Test::NoWarnings; 1";

my @alphabet = qw { < > [ ] + - . , };

my $pattern      = RE Comment => 'Brainfuck'; 
my $keep_pattern = RE Comment => 'Brainfuck', -Keep => 1;

my $test = Test::Regexp -> new -> init (
    pattern      => $pattern,
    keep_pattern => $keep_pattern,
    name         => "Brainfuck Comment",
);

my @pass_data = (
    ["Space comment"    =>  " "],
    ["Newline comment"  =>  "\n"],
    ["Text comment"     =>  "This is a comment"],
    ["C-style comment"  =>  "/* */"],
);

foreach my $entry (@pass_data) {
    my ($test_name, $comment) = @$entry;
    my  $captures = [
        [comment  =>  $comment],
        [body     =>  $comment],
    ];
    $test -> match ($comment,
                     test     => $test_name,
                     captures => $captures);
}


my @fail_data = (
    ["Empty string"   =>  ""],
);
foreach my $char (@alphabet) {
    push @fail_data => 
        ["Contains $char character"  =>  "This is $char a comment"];
}

foreach my $entry (@fail_data) {
    my ($reason, $subject) = @$entry;

    $test -> no_match ($subject, reason => $reason);
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
