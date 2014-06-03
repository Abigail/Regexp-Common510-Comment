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

my %nested = map {$_ => 1} @eol_nested;

foreach my $lang_flavour (@eol, @eol_nested) {
    my ($lang, $flavour) = split /,/ => $lang_flavour;
    my  $tokens = $eol_tokens {$lang_flavour};
    my  @args;
    push @args => -flavour => $flavour if $flavour;

    my $test = Test::Regexp:: -> new -> init (
        pattern      => RE (Comment => $lang, @args),
        keep_pattern => RE (Comment => $lang, @args, -Keep => 1),
        full_text    => 1,
        name         => $flavour ? sprintf "%s (%s flavour) comment" =>
                                           $lang, $flavour
                                 : "$lang comment",
    );

    foreach my $token (@$tokens) {
        goto FAIL if $nested {$lang};

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

      FAIL:
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
                        : $lang  eq 'PHP' || $lang eq 'Advisor' ||
                          $lang  eq 'Hack'                      ? '--'
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
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
