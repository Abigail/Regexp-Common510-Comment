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
    Dylan            =>  '//',
    Haskell          =>  '--',
    Haskell          =>  '---',
    Haskell          =>  '--------------',
    Hugo             =>  '!',
    SLIDE            =>  '#',
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

    if ($lang ne 'Haskell') {
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

    push @fail => ["//\n"       => "wrong opening delimiter"],
                  ["// foo\n"   => "wrong opening delimiter"]
                  unless $token eq '//';
    push @fail => ["#\n"        => "wrong opening delimiter"],
                  ["# \n"       => "wrong opening delimiter"]
                  unless $token eq '#';

    if ($lang eq 'Hugo') {
        push @fail => ["!\\ \n"   => "backslash follows !"],
                      ["!\\ $W\n" => "backslash follows !"],
        ;
    }

    if (length ($token) > 1) {
        my $Token = $token;
        $Token =~ s/^.\K/ /;
        push @fail => ["$Token\n"       => "garbled opening delimiter"],
                      ["$Token $W $W\n" => "garbled opening delimiter"];
    }

    run_tests
        pass                  => \@pass,
        fail                  => \@fail,
        language              =>  $lang,
        flavour               =>  $flavour,
        ghost_name_captures   =>  1,
        ghost_num_captures    =>  1,
        make_subject          => sub {$token . $_ [0] . "\n"},
        make_captures         => sub {
            [[comment         => $token . $_ [0] . "\n"],
             [undef ()        => undef],
             [open_delimiter  => $token],
             [body            => $_ [0]],
             [close_delimiter => "\n"],
            ]
        },
        ;
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
