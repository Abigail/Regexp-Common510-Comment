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

    my @pass;
    my @fail;

    push @pass => "", "foo bar", "\x{4E00}", "aap noot \xBB mies", $BIG,
                  "//", "/* $token */";
    if ($lang ne 'SQL') {
        push @pass => "--", $token, "$token$token$token";
    }

    push @fail => $token, "$token foo bar", "$token foo \n\n",
                 "$token foo \n bar \n", "$token foo\n$token bar\n",
                 "$token foo \n ";
    if ($lang ne 'Advisor') {
        push @fail => "//\n", "// foo\n" unless $token eq '//';
        push @fail => "#\n",  "# \n"     unless $token eq '#';
    }

    foreach my $body (@pass) {
        my $subject = "$token$body\n";
        $checker -> match ($subject, [[$key            => $subject],
                                      [open_delimiter  => $token],
                                      [body            => $body],
                                      [close_delimiter => "\n"]]);
    }

    foreach my $subject (@fail) {
        $checker -> no_match ($subject);
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
