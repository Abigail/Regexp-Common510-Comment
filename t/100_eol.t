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
   'beta-Juliet'     => 'beta_Juliet',
   'Crystal Report'  => 'Crystal_Report',
   'PL/B'            => 'PL_B',
   'Q-BAL'           => 'Q_BAL',
   'ZZT-OOP'         => 'ZZT_OOP',
);

my @data = (
    ABC              =>  '\\',
    Ada              =>  '--',
    Advisor          =>  '//',
    Advisor          =>  '#',
    Advsys           =>  ';',
    Alan             =>  '--',
    awk              =>  '#',
   'beta-Juliet'     =>  '//',
    CLU              =>  '%',
    CQL              =>  ';',   
   'Crystal Report'  =>  '//',
    Eiffel           =>  '--',
    Forth            =>  '\\',
    Fortran          =>  '!',
    fvwm2            =>  '#',
    ICON             =>  '#',
    ILLGOL           =>  'NB',
    J                =>  'NB.',
    LaTeX            =>  '%', 
    Lisp             =>  ';',
    LOGO             =>  ';',
    lua              =>  '--',
    M                =>  ';',
    m4               =>  '#',
    MUMPS            =>  ';',
    mutt             =>  '#',
    Perl             =>  '#',
   'PL/B'            =>  '.',
   'PL/B'            =>  ';',
    Portia           =>  '//',
    Python           =>  '#',
   'Q-BAL'           =>  '`',
    QML              =>  '#',
    R                =>  '#',
    REBOL            =>  ';',
    Ruby             =>  '#',
    Scheme           =>  ';',
    shell            =>  '#',
    slrn             =>  '%',
    SMITH            =>  ';', 
    SQL              =>  '--',
    SQL              =>  '---',
    SQL              =>  '----',
    Tcl              =>  '#', 
    TeX              =>  '%',
    troff            =>  '\\"',
    Ubercode         =>  '//',
    vi               =>  '"', 
    zonefile         =>  ';',
   'ZZT-OOP'         =>  "'",
);

my $BIG = (join "" => 'a' .. 'z', 'A' .. 'Z', 0 .. 9) x 20;

while (@data) {
    my ($lang, $token) = splice @data, 0, 2;

    my $key      = "Comment__" . ($name2key {$lang} // $lang);

    my $pattern1 = RE Comment => $lang;
    my $pattern2 = RE Comment => $lang, -Keep => 1;
    ok $pattern1, "Got a pattern ($pattern1)";
    ok $pattern2, "Got a keep pattern ($pattern2)";

    my $checker = Test::Regexp -> new -> init (
        pattern      => $pattern1,
        keep_pattern => $pattern2,
        name         => "Comment $lang",
    );

    my @pass;
    my @fail;

    push @pass => 
        [""                 =>  "empty body"],
        ["$W $W"            =>  "standard body"],
        ["$W \x{BB} $W"     =>  "Latin-1 in body"],
        ["$W \x{4E00} $W"   =>  "Unicode in body"],
        [$BIG               =>  "Large body"],
        ["//"               =>  "slashes"],
        [" "                =>  "body is a space"],
        ["/* $token */"     =>  "C comment with opening delimiter"],
        ;

    if ($lang ne 'SQL') {
        push @pass => 
            ["--"                  =>  "SQL comment"],
            [$token                =>  "repeated opening delimiter"],
            ["$token$token$token"  =>  "repeated opening delimiter"],
            ;
    }

    push @fail => (
        [$token                    => "only opening delimiter"],
        ["$token $W $W"            => "no trailing newline"],
        ["$token $W \n\n"          => "duplicate newline"],
        ["$token $W \n $W \n"      => "internal newline"],
        ["$token $W\n$token $W\n"  => "duplicate comment"],
        ["$token $W\n "            => "trailing space"],
        [" $token $W\n"            => "leading space"],
    );
    if ($lang ne 'Advisor') {
        push @fail => ["//\n"       => "wrong opening delimiter"],
                      ["// foo\n"   => "wrong opening delimiter"]
                      unless $token eq '//';
        push @fail => ["#\n"        => "wrong opening delimiter"],
                      ["# \n"       => "wrong opening delimiter"]
                      unless $token eq '#';

    }
    if (length ($token) > 1) {
        my $Token = $token;
        $Token =~ s/^.\K/ /;
        push @fail => ["$Token\n"         => "garbled opening delimiter"],
                      ["$Token foo bar\n" => "garbled opening delimiter"];
    }

    run_tests
        pass          => \@pass,
        fail          => \@fail,
        checker       => $checker,
        make_subject  => sub {$token . $_ [0] . "\n"},
        make_captures => sub {[[$key            => $token . $_ [0] . "\n"],
                               [open_delimiter  => $token],
                               [body            => $_ [0]],
                               [close_delimiter => "\n"]]};
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
