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
    Dylan            =>  '//',
    Haskell          =>  '--',
    Haskell          =>  '---',
    Haskell          =>  '--------------',
    SLIDE            =>  '#',
);

my $BIG = (join "" => 'a' .. 'z', 'A' .. 'Z', 0 .. 9) x 20;

while (@data) {
    my ($lang, $token) = splice @data, 0, 2;

    my $key      = "comment";

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
        filter_undef  => 1,
        make_subject  => sub {$token . $_ [0] . "\n"},
        make_captures => sub {[[comment         => $token . $_ [0] . "\n"],
                               [open_delimiter  => $token],
                               [body            => $_ [0]],
                               [close_delimiter => "\n"],
                               ]};
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
