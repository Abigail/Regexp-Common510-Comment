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
    SQL                      =>  '--',
    SQL                      =>  '---',
    SQL                      =>  '----',
   [SQL => 'MySQL']          =>  '#',
   [SQL => 'MySQL']          =>  '-- ',
   [SQL => 'PL/SQL']         =>  '--',
    Tcl                      =>  '#', 
    TeX                      =>  '%',
    troff                    =>  '\\"',
    Ubercode                 =>  '//',
    vi                       =>  '"', 
    zonefile                 =>  ';',
   'ZZT-OOP'                 =>  "'",
);

while (@data) {
    my ($lang, $flavour) = parse_lang shift @data;
    my  $token           =            shift @data;

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

    if ($lang ne 'SQL' || $flavour) {
        push @pass => 
            ["--"                  =>  "SQL comment"],
            [$token                =>  "repeated opening delimiter"],
            ["$token$token$token"  =>  "repeated opening delimiter"],
            ;
    }

    push @fail =>
        [$token                    => "only opening delimiter"],
        ["$token $W $W"            => "no trailing newline"],
        ["$token $W \n\n"          => "duplicate newline"],
        ["$token $W \n $W \n"      => "internal newline"],
        ["$token $W\n$token $W\n"  => "duplicate comment"],
        ["$token $W\n "            => "trailing space"],
        [" $token $W\n"            => "leading space"],
    ;

    if ($lang eq 'SQL' && $flavour eq 'MySQL') {
        push @fail =>
            ["--\n"              =>  "Missing space after --"],
            ["--$W\n"            =>  "Missing space after --"],
        ;
    }

    if ($lang ne 'Advisor' && $lang ne 'PHP') {
        push @fail => ["//\n"       => "wrong opening delimiter"],
                      ["// foo\n"   => "wrong opening delimiter"]
                      unless $token eq '//';
        push @fail => ["#\n"        => "wrong opening delimiter"],
                      ["# \n"       => "wrong opening delimiter"]
                      unless $token eq '#' || $flavour eq 'MySQL';

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
        language      => $lang,
        flavour       => $flavour,
        make_subject  => sub {$token . $_ [0] . "\n"},
        make_captures => sub {[[comment         => $token . $_ [0] . "\n"],
                               [open_delimiter  => $token],
                               [body            => $_ [0]],
                               [close_delimiter => "\n"]]};
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
