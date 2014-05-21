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
    );

    push @test_data => ["Duplicate open" => $token]
          unless $lang eq 'SQL' && $token =~ /^-+$/;
    

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

    foreach my $entry (@fail_data) {
        my ($reason, $comment) = @$entry;
        $test -> no_match ($comment, reason => $reason);
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__


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
        ;

    push @pass =>
            ["--"               =>  "SQL comment"],
         unless $lang eq 'SQL' && !$flavour;

    if ($lang eq 'SQL' && !$flavour) {
        push @pass =>
            ["/* $token */"        =>  "C comment with opening delimiter"],
        ;
    }
    else {
        push @pass => 
            [$token                =>  "repeated opening delimiter"],
            ["$token$token$token"  =>  "repeated opening delimiter"],
            ["/* $token */"        =>  "C comment with opening delimiter"],
        ;
    }


    if ($lang eq 'SQL' && $flavour eq 'MySQL') {
        push @fail =>
            ["--\n"              =>  "Missing space after --"],
            ["--$W\n"            =>  "Missing space after --"],
        ;
    }

    if ($lang ne 'Advisor' && $lang ne 'PHP') {
        push @fail => ["//\n"       => "wrong opening delimiter"],
                      ["// foo\n"   => "wrong opening delimiter"]
                      unless $token eq '//';
        push @fail => ["#\n"        => "wrong opening delimiter"],
                      ["# \n"       => "wrong opening delimiter"]
                      unless $token eq '#' || $flavour eq 'MySQL';

    }
    if (length ($token) > 1) {
        my $Token = $token;
        $Token =~ s/^.\K/ /;
        push @fail => ["$Token\n"       => "garbled opening delimiter"],
                      ["$Token $W $W\n" => "garbled opening delimiter"];
    }

    run_tests
        pass          => \@pass,
        fail          => \@fail,
        language      => $lang,
        flavour       => $flavour,
        make_subject  => sub {$token . $_ [0] . "\n"},
        make_captures => sub {[[comment         => $token . $_ [0] . "\n"],
                               [open_delimiter  => $token],
                               [body            => $_ [0]],
                               [close_delimiter => "\n"]]};
}
