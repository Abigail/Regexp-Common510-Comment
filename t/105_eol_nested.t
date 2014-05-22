#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';
use t::Common;

use strict;
use warnings;
no  warnings 'syntax';

#
# This file only tests the "EOL" part of patterns. The nested option
# is tested in 170_nested.t, along with comments that are nested only.
#
# Failure tests are tested in 100_eol.t.
#

our $r = eval "require Test::NoWarnings; 1";

foreach my $lang (@eol_nested) {
    my $pattern      = RE (Comment => $lang);
    my $keep_pattern = RE (Comment => $lang, -Keep => 1);

    my ($tag)        = $pattern      =~ /<(__RC_Comment__[^>]+)>/;
    my ($keep_tag)   = $keep_pattern =~ /<(__RC_Comment__[^>]+)>/;

    my $test = Test::Regexp:: -> new -> init (
        keep_pattern => $pattern,
        full_text    => 1,
        name         => "$lang comment",
    );

    my $keep_test    = Test::Regexp:: -> new -> init (
        keep_pattern => $keep_pattern,
        full_text    => 1,
        name         => "$lang comment",
    );

    my $eol_tokens = $eol_tokens {$lang};

    foreach my $token (@$eol_tokens) {
        my @test_data = (
            ["Empty comment"   =>  ""],
            ["Normal comment"  =>  "This is a comment"],
            ["Space"           =>  " "],
            ["Unicode"         => "Pick up the \x{260F}!"],
            ["Duplicate open"  => $token],
            ["Slashes"         => "//"],
        );

        foreach my $entry (@test_data) {
            my ($test_name, $body) = @$entry;
            my $comment       = "$token$body\n";
            my $captures      = [[$tag            => undef]];
            my $keep_captures = [[comment         => $comment],
                                 [$tag            => undef],
                                 [open_delimiter  => $token],
                                 [body            => $body],
                                 [close_delimiter => "\n"]];

            $test      -> match ($comment,
                                  test     => $test_name,
                                  captures => $captures);

            $keep_test -> match ($comment,
                                  test     => $test_name,
                                  captures => $keep_captures);
        }
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;

__END__
