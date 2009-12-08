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
   'C--'             =>  'C__',
   'Funge-98'        =>  'Funge_98',
   'PL/I'            =>  'PL_I',
   '*W'              =>  '_W',
);

my @data = (
    ALPACA           =>  '/*',      '*/',
    B                =>  '/*',      '*/',
    BML              =>  '<?_c',    '_c?>',
    C                =>  '/*',      '*/',
   'C--'             =>  '/*',      '*/',
   'Algol 60'        =>  'comment', ';',
   'Befunge-98'      =>  ';',       ';',
   'Funge-98'        =>  ';',       ';',
    False            =>  '!{',      '}!',
    Haifu            =>  ',',       ',',
    LPC              =>  '/*',      '*/',
    Oberon           =>  '(*',      '*)',
   'PL/I'            =>  '/*',      '*/',
    Shelta           =>  ';',       ';',
    Smalltalk        =>  '"',       '"',
   '*W'              =>  '||',      '!!',
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

    my $wack = $lang eq '*W' ? '??' : '!!';
    push @fail => 
        ["$open$close$close"         =>  "extra close delimiter"],
        ["$open $W $W"               =>  "no close delimiter"],
        ["$open $wack"               =>  "no close delimiter"],
        ["$open"                     =>  "no close delimiter"],
        ["$open $W $W $close\n"      =>  "trailing newline"],
        ["$open $W $W $close$close"  =>  "extra close delimiter"],
        ["\n $open $W $W $close"     =>  "leading newline"],
        ["$open$close$BIG"           =>  "body after close delimiter"]
        ;

    run_tests
        pass          => \@pass,
        fail          => \@fail,
        checker       => $checker,
        make_subject  => sub {$open . $_ [0] . $close},
        make_captures => sub {[[$key            => $open . $_ [0] . $close],
                               [open_delimiter  => $open],
                               [body            => $_ [0]],
                               [close_delimiter => $close]]};

}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
