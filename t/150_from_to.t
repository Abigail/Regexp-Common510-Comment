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


foreach my $lang_flavour (@from_to) {
    my ($lang, $flavour) = split /,/ => $lang_flavour;
    my  $tokens = $from_to_tokens {$lang_flavour};
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
        my ($open, $close) = @$token;

        my @pass_data = (
            ["Empty comment"    =>  ""],
            ["Normal comment"   =>  "This is the body"],
            ["Space"            =>  " "],
            ["Unicode"          =>  "Pick up the \x{260F}! "],
        );

        my @fail_data = (
            ["Empty string"        => ""],
            ["No close delimiter"  => "${open}This is the body"],
            ["No open delimiter"   => "This is the body$close"],
            ["Trailing newline"    => "${open}This is the body${close}\n"],
            ["Leading space"       => " ${open}This is the body${close}"],
            ["Internal close delimiter"
                                   => "${open}This is${close}the body${close}"],
        );

        if ($open ne $close && $lang ne 'XML') {
            push @pass_data => ["Duplicate open"  => $open];
        }

        if ($lang eq 'C#' && $open eq '//') {
            push @fail_data => ["Internal newline" =>
                                "${open}This is\nthe body${close}"];
        }
        else {
            push @pass_data => ["Internal newline" =>  "This is\nthe body"];
        }

        if ($lang eq 'XML') {
            push @fail_data =>
                ["Double --"         => "${open}This is--the body${close}"],
                ["Dash before close" => "${open}This is the body-$close"],
                ["Form feed"         => "${open} \x{0C} ${close}"],
            ;
        }

        foreach my $pass_entry (@pass_data) {
            my ($test_name, $body) = @$pass_entry;

            my $comment = "$open$body$close";

            $test -> match ($comment,
                             test     => $test_name,
                             captures => [[comment         => $comment],
                                          [open_delimiter  => $open],
                                          [body            => $body],
                                          [close_delimiter => $close]]);
        }

        foreach my $fail_entry (@fail_data) {
            my ($reason, $comment) = @$fail_entry;
            $test -> no_match ($comment, reason => $reason);
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
