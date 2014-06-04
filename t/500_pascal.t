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

Test::NoWarnings::had_no_warnings () if $r;

my @flavours = ("", "ISO", "Alice", "Delphi", "Free", "GPC", "Workshop",
                "UCSD", "JRT");

my %tokens = (
    ""          => [['{', '}'], ['{', '*)'], ['(*', '}'], ['(*', '*)']],
    "ISO"       => [['{', '}'], ['{', '*)'], ['(*', '}'], ['(*', '*)']],
    "Alice"     => [['{', '}']],
    "Delphi"    => [['{', '}'], ['(*', '*)'], ['//', "\n"]],
    "Free"      => [['{', '}'], ['(*', '*)'], ['//', "\n"]],
    "GPC"       => [['{', '}'], ['(*', '*)'], ['//', "\n"]],
    "Workshop"  => [['{', '}'], ['(*', '*)'], ['"', '"'], ['/*', '*/']],
    "USCD"      => [['{', '}'], ['(*', '*)']],
    "JRT"       => [['{', '}'], ['(*', '*)']],
);

sub make_tester {
    my $flavour = shift;
    my @args    = $flavour ? (-flavour => $flavour) : ();
    my $name    = $flavour ? "Pascal comments ($flavour flavour)"
                           : "Pascal comments";

    Test::Regexp:: -> new -> init (
        pattern      => RE (Comment => "Pascal", @args),
        keep_pattern => RE (Comment => "Pascal", @args, -Keep => 1),
        full_text    => 1,
        name         => $name,
    );
}

my %test;

foreach my $flavour (@flavours) {
    my $test = make_tester $flavour;

    my @fail_data = (
        ["Empty string"    =>  ""],
    );

    my $token_sets = $tokens {$flavour};
    foreach my $token_set (@$token_sets) {
        my ($open, $close) = @$token_set;

        my @pass_data = (
            ["Empty body"        =>  ""],
            ["Space body"        =>  " "],
            ["Normal body"       =>  "This is a comment"],
            ["Unicode"           =>  "Pick up the \x{260F}!"],
        );

        if (length $close > 1) {
            my $partial = $close;
            chop $partial;
            push @pass_data => 
                ["Partial close delimiter" => "This is a ${partial} comment"];
        }

        push @pass_data => ["Opening delimiter" => 
                            "This is ${open} a comment"]
            unless $open eq $close;

        if ($flavour eq "Alice" || $close eq "\n") {
            push @fail_data => ["Internal newline" =>
                                "${open}This is\na comment${close}"];
        }
        else {
            push @pass_data => ["Internal newline" => "This is\na comment"];
        }

        push @fail_data => (
            ["Trailing newline"    => "${open}This is a comment${close}\n"],
            ["Duplicated close delimiter" =>
                                      "${open}A ${close}comment!${close}"],
            ["Leading space"       => " ${open}This is a comment${close}"],
        );

        foreach my $entry (@pass_data) {
            my ($test_name, $body) = @$entry;

            my $comment  = "$open$body$close";
            my $captures = [[comment         =>  $comment],
                            [open_delimiter  =>  $open],
                            [body            =>  $body],
                            [close_delimiter =>  $close]];

            $test -> match ($comment,
                            test     => $test_name,
                            captures => $captures);
        }
    }

    foreach my $entry (@fail_data) {
        my ($reason, $comment) = @$entry;
        $test -> no_match ($comment, reason => $reason);
    }
}


done_testing;


__END__
