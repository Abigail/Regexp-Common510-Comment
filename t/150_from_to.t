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

my @data = (
    ALPACA           =>  '/*',      '*/',
   'Algol 68'        =>  '{',       '}',
   'Algol 68'        =>  '#',       '#',
   'Algol 68'        =>  'CO',      'CO',
   'Algol 68'        =>  'COMMENT', 'COMMENT',
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
   [SQL => 'MySQL']  =>  '/*',      '*/',
   [SQL => 'MySQL']  =>  '/*',      ';',
   [SQL => 'PL/SQL'] =>  '/*',      '*/',
    Shelta           =>  ';',       ';',
    Smalltalk        =>  '"',       '"',
   '*W'              =>  '||',      '!!',
    XML              =>  '<!--',    '-->',
);

while (@data) {
    my ($lang, $flavour) = parse_lang shift @data;
    my  $open            =            shift @data;
    my  $close           =            shift @data;

    my @pass;  # Only bodies.
    my @fail;  # Complete subjects.

    my $arr;

    push @pass => 
        ["\n"               =>  "body is newline"],
        ["- "               =>  "leading hyphen"],
        ["//"               =>  "slashes"],
        [" "                =>  "body is a space"],
        ;

    if ($lang eq 'Algol 68' && $open =~ /C/) {
        push @fail =>
            ["$open$close"        =>  "Cannot seperate open/end delimiters"],
            ["$open$W $W$close"            =>  "Word flushed against token"],
            ["$open $W \x{BB} $W$close"    =>  "Word flushed against token"],
            ["$open$W \x{4E00} $W $close"  =>  "Word flushed against token"],
            ["$open$BIG$close"             =>  "Word flushed against token"],
        ;
        push @pass =>
            [" $W $W "          =>  "standard body"],
            [" $W \x{BB} $W "   =>  "Latin-1 in body"],
            [" $W \x{4E00} $W " =>  "Unicode in body"],
        ;
    }
    else {
        push @pass =>
            [""                 =>  "empty body"],
            ["$W $W"            =>  "standard body"],
            ["$W \x{BB} $W"     =>  "Latin-1 in body"],
            ["$W \x{4E00} $W"   =>  "Unicode in body"],
        ;
    }

    if ($lang eq 'XML') {
        push @fail => ["$open--$close"    =>  "double hyphen"],
                      ["$open $W-$close"  =>  "trailing hyphen"],
                      ["$open-$close"     =>  "single hyphen"],
        ;
    }
    else {
        push @pass => ["--"     =>  "double hyphen"],
                      [" $W-"   =>  "trailing hyphen"],
                      ["-"      =>  "single hyphen"],
        ;
    }

    if ($open ne $close) {
        if ($lang eq 'XML') {
            push @fail =>
                ["$open$open"       =>  "extra hyphens"],
                ["$open$open$open"  =>  "extra hyphens"],
            ;
        }
        elsif (-1 == index ("$open$open" => $close) &&
             !($lang eq 'SQL'  &&  $flavour eq 'MySQL')) {
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

        if ($lang  eq 'XML') {
            push @fail => ["$open /* $open */ $close" => "extra hyphens"],
            ;
        }
        elsif ($close eq '*/' ||
            $lang  eq 'SQL' && $flavour eq 'MySQL') {
            push @fail => ["$open /* $open */ $close" => "trailing garbage"],
            ;
        }
        else {
            push @pass => ["/* $open */"  => "C comment"],
            ;
        }

        if (($close ne '*/' || $lang  eq 'SQL' && $flavour eq 'MySQL') &&
             $lang ne 'Algol 60') {
            push @pass => 
                [" '*/' "          =>  "single quoted */"],
                [' "*/" '          =>  "double quoted */"],
                [" '; ' "          =>  "single quoted ; "],
                [' "; " '          =>  "double quoted ; "],
                [q { '*/ $W' ';'}  => "multiple escapes"],
                [q { "*/ $W" ';'}  => "multiple escapes"],
            ;
        }

        push @fail =>
            ["$open $W $W $open"   => "open instead of close delimiter"],
            ["$open \n $open"      => "open instead of close delimiter"],
            ["$close$open"         => "reversed delimiters"],
            ["$close \n $open"     => "reversed delimiters"]
            ;
    }

    if ($lang eq 'XML') {
        no warnings 'utf8';
        push @fail => 
            ["<!-- \x{0C} -->"     => "form feed"],
        ;
    }
    else {
        no warnings 'utf8';
        push @pass =>
            [" \x{0C} "            => "form feed"],
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

    if ($lang eq 'Algol 68' && !state $seen ++) {
        foreach my $open (qw [# { CO COMMENT]) {
            foreach my $close (qw [# } CO COMMENT]) {
                next if $open eq $close || $open eq '{' && $close eq '}';
                push @fail => 
                    ["$open $close"    =>  'Wrong delimiter match'],
                    ["$open $W $close" =>  'Wrong delimiter match'],
                ;
            }
        }
    }

    run_tests
        pass          => \@pass,
        fail          => \@fail,
        language      =>  $lang,
        flavour       =>  $flavour,
        make_subject  => sub {$open . $_ [0] . $close},
        make_captures => sub {[[comment         => $open . $_ [0] . $close],
                               [open_delimiter  => $open],
                               [body            => $_ [0]],
                               [close_delimiter => $close]]};

}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
