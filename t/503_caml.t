#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2009121001;
use t::Common;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my $pattern1 = RE Comment => 'Caml'; 
my $pattern2 = RE Comment => 'Caml', -Keep => 1;
ok $pattern1, no_nl "Got a pattern for Caml: qr {$pattern1}";
ok $pattern2, no_nl "Got a keep pattern for Caml: qr {$pattern2}";

my $checker = Test::Regexp -> new -> init (
    pattern      => $pattern1,
    keep_pattern => $pattern2,
    name         => "Comment Caml",
);

my $open  = '(*';
my $close = '*)';

my $nest = $W;
   $nest = "$open$nest$close" for 1 .. 100;

my $nest7 = $W;
my $nest9 = $W;
   $nest7 = "$open$nest7$close" for 1 .. 7;
   $nest9 = "$open$nest9$close" for 1 .. 9;

my @pass = (
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

    [qq {" "}                =>  "string inside"],
    [qq {"(*"}               =>  "open delimiter inside string"],
    [qq {"*)"}               =>  "close delimiter inside string"],
    [qq {"\\""}              =>  "escaped string delimiter inside string"],
    [qq {'}                  =>  "lone single quote"],
    [qq {' '}                =>  "single quotes"],
);


my @fail = (
    #
    # "Standard" fail tests.
    #
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

    #
    # Special 'Caml' failures
    #
    [qq {$open " $close}     =>  "lone double quote"],
    [qq {$open "'" $close}   =>  "single quotes inside double quotes"],
    [qq {$open "\\q" $close} =>  "not a proper escape"],
    [qq {$open "\\12" $close}  =>  "incomplete decimal escape"],
    [qq {$open "\\F " $close}  =>  "incomplete hex escape"],
);

run_tests
    pass                 => \@pass,
    fail                 => \@fail,
    checker              => $checker,
    ghost_name_captures  => 1,
    ghost_num_captures   => 1,
    make_subject         => sub {'(*' . $_ [0] . '*)'},
    make_captures        => sub {[
        [undef ()        => $open . $_ [0] . $close],
        [open_delimiter  => $open],
        [body            => $_ [0]],
        [close_delimiter => $close],
    ]}
;

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
