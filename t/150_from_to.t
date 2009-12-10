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

my @data = (
    ALPACA           =>  '/*',      '*/',
    B                =>  '/*',      '*/',
    BML              =>  '<?_c',    '_c?>',
    C                =>  '/*',      '*/',
   'C--'             =>  '/*',      '*/',
   'C++'             =>  '/*',      '*/',
   'C#'              =>  '/*',      '*/',
    Cg               =>  '/*',      '*/',
   'Algol 60'        =>  'comment', ';',
   'Befunge-98'      =>  ';',       ';',
    ECMAScript       =>  '/*',      '*/',
    FPL              =>  '/*',      '*/',
   'Funge-98'        =>  ';',       ';',
    False            =>  '!{',      '}!',
    Haifu            =>  ',',       ',',
    Java             =>  '/*',      '*/',
    JavaScript       =>  '/*',      '*/',
    LPC              =>  '/*',      '*/',
    Nickle           =>  '/*',      '*/',
    PEARL            =>  '/*',      '*/',
    PHP              =>  '/*',      '*/',
    Oberon           =>  '(*',      '*)',
   'PL/I'            =>  '/*',      '*/',
   [SQL => 'PL/SQL'] =>  '/*',      '*/',
    Shelta           =>  ';',       ';',
    Smalltalk        =>  '"',       '"',
   '*W'              =>  '||',      '!!',
);

while (@data) {
    my ($lang, $open, $close) = splice @data, 0, 3;

    my @args;
    if (ref $lang) {
        @args = (-flavour => $$lang [1]);
        $lang = $$lang [0];
    }

    my $pattern1 = RE Comment => $lang, @args;
    my $pattern2 = RE Comment => $lang, @args, -Keep => 1;
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

    if (length ($open) > 1) {
        my $Open = $open;
        $Open =~ s/^.\K/ /;
        push @fail => ["$Open$close"        => "garbled open delimiter"],
                      ["$Open $W $W $close" => "garbled open delimiter"];
    }
    if (length ($close) > 1) {
        my $Close = $close;
        $Close =~ s/(.)$/ $1/;
        push @fail => ["$open$Close"        => "garbled close delimiter"],
                      ["$open $W $W $Close" => "garbled close delimiter"];
    }


    run_tests
        pass          => \@pass,
        fail          => \@fail,
        checker       => $checker,
        make_subject  => sub {$open . $_ [0] . $close},
        make_captures => sub {[[comment         => $open . $_ [0] . $close],
                               [open_delimiter  => $open],
                               [body            => $_ [0]],
                               [close_delimiter => $close]]};

}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
