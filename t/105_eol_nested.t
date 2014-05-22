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

foreach my $lang (@eol_nested) {
    my $pattern      = RE (Comment => $lang);
    my $keep_pattern = RE (Comment => $lang, -Keep => 1);
    my $test = Test::Regexp:: -> new -> init (
        keep_pattern => $pattern,
        full_text    => 1,
        name         => "$lang comment",
    );

    my $keep_test    = Test::Regexp:: -> new -> init (
        keep_pattern => $pattern,
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
            my $comment  = "$token$body\n";
            my $captures = [[comment => $comment],
                            [open_delimiter  => $token],
                            [body            => $body],
                            [close_delimiter => "\n"]];

            $test -> match ($comment,
                             test     => $test_name,
                             captures => $captures);
        }
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;

__END__

    push @pass => 
        [""                  =>  "empty body"],
        ["This is a comment" =>  "standard body"],
        ["$W \x{BB} $W"      =>  "Latin-1 in body"],
        ["$W \x{4E00} $W"    =>  "Unicode in body"],
        [$BIG                =>  "Large body"],
        ["//"                =>  "slashes"],
        [" "                 =>  "body is a space"],
        ["/* $token */"      =>  "C comment with opening delimiter"],
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
