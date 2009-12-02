#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 'Comment';

my @languages = (
    [Perl   =>  "#"],
);

foreach my $language (@languages) {
    my ($lang, $token) = @$language;

    my $pattern1 = RE Comment => $lang;
    my $pattern2 = RE Comment => $lang, -Keep => 1;
    ok $pattern1, "Got a pattern";
    ok $pattern2, "Got a keep pattern";

    my $checker = Test::Regexp -> new -> init (
        pattern      => $pattern1,
        keep_pattern => $pattern2,
        name         => "$lang comment",
    );

    foreach my $body ("", "$token", "$token$token$token",
                      "foo bar", "//", "--", "/* $token */",
                      "\x{4E00}", "aap noot \xBB mies") {
        my $subject = $token . $body . "\n";
        $checker -> match ($subject, [[open_delimiter  => "#"],
                                      [body            => $body],
                                      [close_delimiter => "\n"]]);

        my @subject_fail = ("$token$body",
                             $body =~ /^#/ ? () : "$body\n",
                             $body ? "$token\n$body" : (),
                            "$token$body\n$token",
                            "$token$body$token");
        $checker -> no_match ($_) for @subject_fail;
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
