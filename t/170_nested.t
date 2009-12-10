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
    Dylan            =>  '/*',      '*/',
    Caml             =>  '(*',      '*)',
    Haskell          =>  '{-',      '-}',
    Hugo             =>  '!\\',     '\\!',
   'Modula-2'        =>  '(*',      '*)',
   'Modula-3'        =>  '(*',      '*)',
    SLIDE            =>  '(*',      '*)',
);

while (@data) {
    my ($lang, $flavour) = parse_lang shift @data;
    my  $open            =            shift @data;
    my  $close           =            shift @data;

    my @pass;  # Only bodies.
    my @fail;  # Complete subjects.

    my $nest = $W;
       $nest = "$open$nest$close" for 1 .. 100;

    my $nest7 = $W;
    my $nest9 = $W;
       $nest7 = "$open$nest7$close" for 1 .. 7;
       $nest9 = "$open$nest9$close" for 1 .. 9;

    push @pass => 
        [""                      =>  "empty body"],
        ["$W $W"                 =>  "standard body"],
        ["\n"                    =>  "body is newline"],
        ["$W \x{BB} $W"          =>  "Latin-1 in body"],
        ["$W \x{4E00} $W"        =>  "Unicode in body"],
        [$BIG                    =>  "Large body"],
        ["--"                    =>  "hyphens"],
        [" // "                  =>  "slashes"],
        [" "                     =>  "body is a space"],
        ["*"                     =>  "body is a star"],
        ["$open$close"           =>  "simple nested"],
        ["$W $open $W $close $W" =>  "nested"],
        [$nest                   =>  "deeply nested"],
        ["$nest7 $W $nest9"      =>  "double nested"],
        ;


    push @fail => 
        ["$open"                 =>  "no close delimiters"],
        ["$open $open $close"    =>  "not enough close delimiters"],
        ["$open $close $close $open"
                                 =>  "unbalanced delimiters"],
        ["$open $close//"        =>  "trailing garbage"],
        ["$open $close "         =>  "trailing space"],
        ["$open $open $close $close\n"
                                 =>  "trailing newline"],
        ["$open $W $W $open"     =>  "open instead of close delimiter"],
        ["$open \n $open"        =>  "open instead of close delimiter"],
        ["$open $close$open $close"
                                 =>  "unbalanced delimiters"],
        ["$close$open"           =>  "reversed delimiters"],
        ["$close $W $open"       =>  "reversed delimiters"],
        ["$open$close$close"     =>  "extra close delimiter"],
        ["$open $W $W"           =>  "no close delimiter"],
        ["$open ??"              =>  "no close delimiter"],
        [" $open $W $close"      =>  "leading space"],
        ["\n$open $open $close $close"
                                 =>  "leading newline"],
        ["$open $open $close $close $BIG"
                                 =>  "body after close delimiter"],
    ;

    if (length ($open) > 1) {
        my $Open = $open;
        $Open =~ s/^.\K/ /;
        push @fail =>
            ["$Open$close"               => "garbled open delimiter"],
            ["$Open $W $W $close"        => "garbled open delimiter"],
            ["$Open $open $close $close" => "garbled open delimiter"];
    }
    if (length ($close) > 1) {
        my $Close = $close;
        $Close =~ s/(.)$/ $1/;
        push @fail =>
            ["$open$Close"               => "garbled close delimiter"],
            ["$open $W $W $Close"        => "garbled close delimiter"],
            ["$open $open $close $Close" => "garbled close delimiter"];
    }


    run_tests
        pass                  => \@pass,
        fail                  => \@fail,
        language              => $lang,
        flavour               => $flavour,
        ghost_name_captures   => 1,
        ghost_num_captures    => 1,
        make_subject          => sub {$open . $_ [0] . $close},
        make_captures         => sub {
            [[comment         => $open . $_ [0] . $close],
             [undef ()        => $open . $_ [0] . $close],
             [open_delimiter  => $open],
             [body            => $_ [0]],
             [close_delimiter => $close]]
        },
    ;

}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
