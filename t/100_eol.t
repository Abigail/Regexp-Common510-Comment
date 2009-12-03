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
   'beta-Juliet'     => 'beta_Juliet',
   'Crystal Report'  => 'Crystal_Report',
   'PL/B'            => 'PL_B',
   'Q-BAL'           => 'Q_BAL',
   'ZZT-OOP'         => 'ZZT_OOP',
);

my @data = (
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
        show_line    => 1,
    );

    foreach my $body ("", "$token", "$token$token$token",
                      "foo bar", "//", "--", "/* $token */",
                      "\x{4E00}", "aap noot \xBB mies", $BIG) {
        my $subject = $token . $body . "\n";
        unless ($lang eq 'SQL' && $subject =~ /^$token-/) {
            $checker -> match ($subject, [[$key            => $subject],
                                          [open_delimiter  => $token],
                                          [body            => $body],
                                          [close_delimiter => "\n"]]);
        }

        my @subject_fail = ("$token$body",
                             $body =~ /^$token/ ? () : "$body\n",
                             $body ? "$token\n$body" : (),
                            "$token$body\n$token",
                            "$token$body$token");
        foreach my $subject (@subject_fail) {
            next if $subject eq "//\n"           && $lang eq 'Advisor';
            next if $subject eq "--\n"           && $lang eq 'SQL';
            next if $subject eq qq {\\"\n}       && $lang eq 'troff';
            next if $subject eq qq {\\"\\"\\"\n} && $lang eq 'troff';
            $checker -> no_match ($subject);
        }
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
