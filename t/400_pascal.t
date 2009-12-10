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
    ""               =>  '(*',      '*)',
    ""               =>  '{',       '*)',
    ""               =>  '(*',      '}',
    ""               =>  '{',       '}',
    "Alice"          =>  '{',       '}',
    "Delphi"         =>  '//',      "\n",
    "Delphi"         =>  '{',       '}',
    "Delphi"         =>  '(*',      '*)',
    "Free"           =>  '//',      "\n",
    "Free"           =>  '{',       '}',
    "Free"           =>  '(*',      '*)',
    "GPC"            =>  '//',      "\n",
    "GPC"            =>  '{',       '}',
    "GPC"            =>  '(*',      '*)',
    "ISO"            =>  '(*',      '*)',
    "ISO"            =>  '{',       '*)',
    "ISO"            =>  '(*',      '}',
    "ISO"            =>  '{',       '}',
    "Workshop"       =>  '{',       '}',
    "Workshop"       =>  '(*',      '*)',
    "Workshop"       =>  '/*',      '*/',
    "Workshop"       =>  '"',       '"',
);

while (@data) {
    my ($flavour, $open, $close) = splice @data, 0, 3;

    my $pattern1 = RE Comment => 'Pascal', -flavour => $flavour;
    my $pattern2 = RE Comment => 'Pascal', -flavour => $flavour, -Keep => 1;
    ok $pattern1, "Got a pattern for Pascal (-flavour => $flavour): "      .
                  "qr {$pattern1}";
    ok $pattern2, "Got a keep pattern for Pascal (-flavour => $flavour): " .
                  "qr {$pattern2}";

    my $checker = Test::Regexp -> new -> init (
        pattern      => $pattern1,
        keep_pattern => $pattern2,
        name         => "Comment Pascal (-flavour => $flavour)",
    );

    my @pass;  # Only bodies.
    my @fail;  # Complete subjects.

    push @pass => 
        [""                 =>  "empty body"],
        ["$W $W"            =>  "standard body"],
        ["$W \x{BB} $W"     =>  "Latin-1 in body"],
        ["$W \x{4E00} $W"   =>  "Unicode in body"],
        [$BIG               =>  "Large body"],
        ["--"               =>  "hyphens"],
        ["//"               =>  "slashes"],
        [" "                =>  "body is a space"],
        ["*"                =>  "body is a star"],
        ["****"             =>  "body is stars"],
        ;

    given ($flavour) {
        when (["Alice"]) {
            push @fail => ["\n"     =>  "body is newline"],
            ;
        }
        when (["Delphi", "Free", "GPC",]) {
            # Newlines will be dealt with close delimiter fail tests.
            ;
        }
        default {
            push @pass => ["\n"     =>  "body is newline"],
            ;
        }
    }

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

    my $wack = "!!";
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


    if ($flavour eq "" || $flavour eq "ISO") {
        push @fail => ["$open}$close"       => "extra close delimiter"],
                      ["$open*)$close"      => "extra close delimiter"],
        ;
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
