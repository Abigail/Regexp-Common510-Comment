#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';
use t::Common;

use strict;
use warnings;
no  warnings 'syntax';

our $r = eval "require Test::NoWarnings; 1";

foreach my $eol_entry (@eol_tokens) {
    my ($lang, $token) = @$eol_entry;

    my @args;
    if (ref $lang) {
        push @args => -flavour => $$lang [1];
        $lang = $$lang [0];
    }

    my $test = Test::Regexp:: -> new -> init (
        pattern      => RE (Comment => $lang, @args),
        keep_pattern => RE (Comment => $lang, @args, -Keep => 1),
        full_text    => 1,
        name         => @args ? sprintf "%s lang (%s flavour) comment" =>
                                         $lang, $args [1]
                              : "$lang comment",
    );

    my @test_data = (
        ["Empty comment"   =>  ""],
        ["Normal comment"  =>  "This is a comment"],
        ["Space"           =>  " "],
        ["Unicode"         => "Pick up the \x{260F}!"],
        ["Duplicate open"  => $token],
    );

    foreach my $test_entry (@test_data) {
        my ($test_name, $body) = @$test_entry;

        my $comment = "$token$body\n";

        $test -> match ($comment,
                         test     => $test_name,
                         captures => [[comment         => $comment],
                                      [open_delimiter  => $token],
                                      [body            => $body],
                                      [close_delimiter => "\n"]]);
    }


    my $body = "This is a comment";
    my @fail_data = (
        ["Only an opening delimiter"   =>  $token],
        ["No trailing newline"         => "$token $body"],
        ["Duplicate newline"           => "$token $body\n\n"],
        ["Internal newline"            => "$token Hello\nworld\n\n"],
        ["Duplicated comment"          => "$token $body\n" x 2],
        ["Trailing space"              => "$token $body\n "],
        ["Leading space"               => " $token $body\n"],
    );
    my $wrong_delim = $token eq '//'                        ? '/*'
                    : $lang  eq 'PHP' || $lang eq 'Advisor' ? '--'
                    :                                         '//';
    push @fail_data => 
        ["Wrong delimiter"             => "${wrong_delim} $body\n"];

    foreach my $entry (@fail_data) {
        my ($reason, $comment) = @$entry;
        $test -> no_match ($comment, reason => $reason);
    }

    if (length $token > 1) {
        my $token = $token;  # Copy
        chop $token;

        $test -> no_match ("$token This is a comment ",
                            reason => "Incomplete opening delimiter");
    }

}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
