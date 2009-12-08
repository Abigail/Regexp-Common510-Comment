#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2009120801;
use t::Common;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 'Comment';

my %name2key = (
   'Algol 60'        =>  'Algol_60',
   'Befunge-98'      =>  'Befunge_98',
   'Funge-98'        =>  'Funge_98',
);

my @data = (
    ALPACA           =>  '/*',      '*/',
   'Algol 60'        =>  'comment', ';',
   'Befunge-98'      =>  ';',       ';',
   'Funge-98'        =>  ';',       ';',
    Haifu            =>  ',',       ',',
    Shelta           =>  ';',       ';',
    Smalltalk        =>  '"',       '"',
);

my $BIG = (join "" => 'a' .. 'z', 'A' .. 'Z', 0 .. 9) x 20;

while (@data) {
    my ($lang, $open, $close) = splice @data, 0, 3;

    my $key      = "Comment__" . ($name2key {$lang} // $lang);

    my $pattern1 = RE Comment => $lang;
    my $pattern2 = RE Comment => $lang, -Keep => 1;
    ok $pattern1, "Got a pattern for $lang: qr {$pattern1}";
    ok $pattern2, "Got a keep pattern for $lang: qr {$pattern2}";

    my $checker = Test::Regexp -> new -> init (
        pattern      => $pattern1,
        keep_pattern => $pattern2,
        name         => "Comment $lang",
    );

    my @pass;  # Only bodies.
    my @fail;  # Complete subjects.

    push @pass => 
        [""                 =>  "empty body"],
        ["$W $W"            =>  "standard body"],
        ["\n"               =>  "body is newline"],
        ["$W \x{BB} $W"     =>  "Latin-1 in body"],
        ["$W \x{4E00} $W"   =>  "Unicode in body"],
        [$BIG               =>  "Large body"],
        ["--"               =>  "hyphens"],
        ["//"               =>  "slashes"],
        [" "                =>  "body is a space"]
        ;

    if ($open ne $close) {
        if (-1 == index "$open$open" => $close) {
            push @pass => 
                [$open              =>  "body consists of opening delimiter"],
                ["$open$open$open"  =>  "body consists of multiple opening " .
                                        "delimiters"],
            ;
        }
        else {
            push @fail =>
                ["$open$open"       =>  "trailing garbage"],
                ["$open$open$open"  =>  "trailing garbage"],
                ;
        }

        if ($close ne '*/') {
            push @pass => ["/* $open */"  => "C comment"],
            ;
        }
        else {
            push @fail => ["$open /* $open */ $close" => "trailing garbage"],
            ;
        }

        push @fail =>
            ["$open $W $W $open"   => "open instead of close delimiter"],
            ["$open \n $open"      => "open instead of close delimiter"],
            ["$close$open"         => "reversed delimiters"],
            ["$close \n $open"     => "reversed delimiters"]
            ;
    }

    push @fail => 
        ["$open$close$close"         =>  "extra close delimiter"],
        ["$open foo bar"             =>  "no close delimiter"],
        ["$open !!"                  =>  "no close delimiter"],
        ["$open"                     =>  "no close delimiter"],
        ["$open $W $W $close\n"      =>  "trailing newline"],
        ["$open $W $W $close$close"  =>  "extra close delimiter"],
        ["\n $open $W $W $close"     =>  "leading newline"],
        ["$open$close$BIG"           =>  "body after close delimiter"]
        ;

    my $errors = 0;

    foreach my $test (@pass) {
        my ($body, $reason) = @$test;
        my $subject = "$open$body$close";
        $errors ++ unless
            $checker -> match ($subject, [[$key            => $subject],
                                          [open_delimiter  => $open],
                                          [body            => $body],
                                          [close_delimiter => $close]],
                               test    => $reason);
    }

    foreach my $test (@fail) {
        my ($subject, $reason) = @$test;
        $errors ++ unless
            $checker -> no_match ($subject, reason => $reason);
    }

    BAIL_OUT if $errors && $ENV {BAILOUT_EARLY};
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
