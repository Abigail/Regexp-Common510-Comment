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
    ABC                      =>  '\\',
    Ada                      =>  '--',
    Advisor                  =>  '//',
    Advisor                  =>  '#',
    Advsys                   =>  ';',
    Alan                     =>  '--',
    awk                      =>  '#',
    BASIC                    =>  'REM',
   [BASIC => 'mvEnterprise'] =>  'REM',
   [BASIC => 'mvEnterprise'] =>  '*',
   [BASIC => 'mvEnterprise'] =>  '!',
   'beta-Juliet'             =>  '//',
   'C++'                     =>  '//',
   'C#'                      =>  '//',
    Cg                       =>  '//',
    CLU                      =>  '%',
    CQL                      =>  ';',   
   'Crystal Report'          =>  '//',
    ECMAScript               =>  '//',
    Eiffel                   =>  '--',
    Forth                    =>  '\\',
    Fortran                  =>  '!',
    FPL                      =>  '//',
    fvwm2                    =>  '#',
    ICON                     =>  '#',
    ILLGOL                   =>  'NB',
    J                        =>  'NB.',
    Java                     =>  '//',
    JavaScript               =>  '//',
    LaTeX                    =>  '%', 
    Lisp                     =>  ';',
    LOGO                     =>  ';',
    lua                      =>  '--',
    M                        =>  ';',
    m4                       =>  '#',
    MUMPS                    =>  ';',
    mutt                     =>  '#',
    Nickle                   =>  '#',
    PEARL                    =>  '!',
    Perl                     =>  '#',
    PHP                      =>  '#',
    PHP                      =>  '//',
   'PL/B'                    =>  '.',
   'PL/B'                    =>  ';',
    Portia                   =>  '//',
    Python                   =>  '#',
   'Q-BAL'                   =>  '`',
    QML                      =>  '#',
    R                        =>  '#',
    REBOL                    =>  ';',
    Ruby                     =>  '#',
    Scheme                   =>  ';',
    shell                    =>  '#',
    slrn                     =>  '%',
    SMITH                    =>  ';', 
   [SQL => 'PL/SQL']         =>  '--',
    SQL                      =>  '--',
    SQL                      =>  '---',
    SQL                      =>  '----',
    Tcl                      =>  '#', 
    TeX                      =>  '%',
    troff                    =>  '\\"',
    Ubercode                 =>  '//',
    vi                       =>  '"', 
    zonefile                 =>  ';',
   'ZZT-OOP'                 =>  "'",
);

while (@data) {
    my ($lang, $token) = splice @data, 0, 2;

    my @args;
    my $pat_name = $lang;
    if (ref $lang) {
        $pat_name = $$lang [1] ? "$$lang[0] (-flavour $$lang[1])"
                               : "$$lang[0] (default -flavour)";
        @args = (-flavour => $$lang [1]);
        $lang = $$lang [0];
    }

    my $pattern1 = RE Comment => $lang, @args;
    my $pattern2 = RE Comment => $lang, @args, -Keep => 1;
    ok $pattern1, "Got a pattern for $pat_name ($pattern1)";
    ok $pattern2, "Got a keep pattern for $pat_name ($pattern2)";

    my $checker = Test::Regexp -> new -> init (
        pattern      => $pattern1,
        keep_pattern => $pattern2,
        name         => "Comment $pat_name",
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
    if ($lang ne 'Advisor' && $lang ne 'PHP') {
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
        push @fail => ["$Token\n"       => "garbled opening delimiter"],
                      ["$Token $W $W\n" => "garbled opening delimiter"];
    }

    run_tests
        pass          => \@pass,
        fail          => \@fail,
        checker       => $checker,
        make_subject  => sub {$token . $_ [0] . "\n"},
        make_captures => sub {[[comment         => $token . $_ [0] . "\n"],
                               [open_delimiter  => $token],
                               [body            => $_ [0]],
                               [close_delimiter => "\n"]]};
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
