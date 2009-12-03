#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2009120301;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 'Comment';

my %name2key = (
);

my @data = (
    Haifu            =>  ',', ',',
    Smalltalk        =>  '"', '"',
);

my $BIG = (join "" => 'a' .. 'z', 'A' .. 'Z', 0 .. 9) x 20;

while (@data) {
    my ($lang, $open, $close) = splice @data, 0, 3;

    my $key      = "Comment__" . ($name2key {$lang} // $lang);

    my $pattern1 = RE Comment => $lang;
    my $pattern2 = RE Comment => $lang, -Keep => 1;
    ok $pattern1, "Got a pattern ($pattern1)";
    ok $pattern2, "Got a keep pattern ($pattern2)";

    my $checker = Test::Regexp -> new -> init (
        pattern      => $pattern1,
        keep_pattern => $pattern2,
        name         => "Comment $lang",
        show_line    => 1,
    );

    my @pass;  # Only bodies.
    my @fail;  # Complete subjects.

    push @pass => "", "foo bar", "\n", "baz \x{4E00} quux", $BIG, "--", "//";
    if ($open ne $close) {
        push @pass => $open, "$open$open$open", "/* $open */";
        push @fail => "$open foo bar $open", "$open \n $open";
        push @fail => "$close$open", "$close \n $open";
    }

    push @fail => "$open$close$close",
                  "$open foo bar",
                  "$open !!",
                  "$open",
                  "$open foo bar $close\n",
                  "$open foo bar $close$close",
                  "\n $open foo bar $close",
                  "$open$close$BIG";

    foreach my $body (@pass) {
        my $subject = "$open$body$close";
        $checker -> match ($subject, [[$key            => $subject],
                                      [open_delimiter  => $open],
                                      [body            => $body],
                                      [close_delimiter => $close]]);
    }

    foreach my $subject (@fail) {
        $checker -> no_match ($subject);
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
