#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 'Comment';

my @languages = (
    [Perl   =>  "#"],
);

foreach my $language (@languages) {
    my ($lang, $token) = @$language;

    my $pattern = RE Comment => $lang;
    ok $pattern, "Got a pattern";
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
