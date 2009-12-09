#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2009120802;
use t::Common;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 'Comment';

my @data = (
    Dylan            =>  '/*',      '*/',
    Haskell          =>  '{-',      '-}',
#   Hugo             =>  '!\\',     '\\!',
    SLIDE            =>  '(*',      '*)',
);

my $BIG = (join "" => 'a' .. 'z', 'A' .. 'Z', 0 .. 9) x 20;

while (@data) {
    my ($lang, $open, $close) = splice @data, 0, 3;

    my $key      = "comment";

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
        checker               => $checker,
        ghost_name_captures   => 1,
        filter_undef          => 1,
        make_subject          => sub {$open . $_ [0] . $close},
        make_captures         => sub {
            [[undef ()        => $open . $_ [0] . $close],
              undef,
              undef,
              undef,
             [$key            => $open . $_ [0] . $close],
             [open_delimiter  => $open],
             [body            => $_ [0]],
             [close_delimiter => $close]]
        },
    ;

}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
