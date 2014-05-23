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

foreach my $lang_flavour (@nested, @eol_nested) {
    my ($lang, $flavour) = split /,/ => $lang_flavour;
    my  $tokens = $from_to_tokens {$lang_flavour};
    my  @args;
    push @args => -flavour => $flavour if $flavour;

    my $pattern      = RE (Comment => $lang, @args);
    my $keep_pattern = RE (Comment => $lang, @args, -Keep => 1);

    my ($tag)      = $pattern      =~ /<(__RC_Comment_[^>]+)>/;
    my ($keep_tag) = $keep_pattern =~ /<(__RC_Comment_[^>]+)>/;

    my $test = Test::Regexp:: -> new -> init (
        keep_pattern    => $pattern,
        full_text       => 1,
        no_keep_message => 1,
        name            => $flavour ? sprintf "%s (%s flavour) comment" =>
                                               $lang, $flavour
                                    : "$lang comment",
    );

    my $keep_test = Test::Regexp:: -> new -> init (
        keep_pattern    => $keep_pattern,
        full_text       => 1,
        name            => $flavour ? sprintf "%s (%s flavour) comment" =>
                                               $lang, $flavour
                                    : "$lang comment",
    );

    foreach my $entry (@$tokens) {
        my ($open, $close) = @$entry;

        my @pass_data = (
            ["Empty comment"         => ""],
            ["Space comment"         => " "],
            ["Newline comment"       => "\n"],
            ["Normal comment"        => "This is a comment"],
            ["Comment with Unicode"  => "Pick up the \x{260F}"],
            ["Nested comment"        => "This is ${open} a ${close} comment"],
            ["Double nested comment" => "This ${open} is ${open} a " .
                                        "${close} comment ${close}"],
            ["Multi nested comment"  => "${open} This ${close} ${open} is " .
                                        "${open} a ${close}${close} comment"],
        );

        my @fail_data = (
            ["Empty string"              => ""],
            ["No close delimiter"        => "${open} This is a comment"],
            ["No open delimiter"         => "This is a comment${close}"],
            ["Unbalanced delimiters"     => "${open} This is ${open} a " .
                                            "comment${close}"],
            ["Delimiters in wrong order" => "${open} This is ${close} a " .
                                            "${open} comment${close}"],
            ["Trailing new line"         => "${open} Comment here! ${close}\n"],
            ["Leading space"             => " ${open} Comment here! ${close}"],
        );

        foreach my $pass (@pass_data) {
            my ($test_name, $body) = @$pass;
            my  $comment           = "$open$body$close";
            my  $captures          = [
                [$keep_tag         => $comment],
            ];
            my  $keep_captures     = [
                [comment           => $comment],
                [$keep_tag         => $comment],
                [open_delimiter    => $open],
                [body              => $body],
                [close_delimiter   => $close]
            ];

            $test       -> match ($comment,
                                  test     => $test_name,
                                  captures => $captures);
            $keep_test -> match ($comment,
                                  test     => $test_name,
                                  captures => $keep_captures);
        }

        foreach my $fail (@fail_data) {
            my ($reason, $comment) = @$fail;
            $test      -> no_match ($comment, reason => $reason);
            $keep_test -> no_match ($comment, reason => $reason);
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;

__END__
