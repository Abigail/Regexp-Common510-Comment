#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';

use strict;
use warnings;
no  warnings 'syntax';

our $r = eval "require Test::NoWarnings; 1";

my $test_sql = Test::Regexp:: -> new -> init (
    pattern      =>  RE (Comment => "SQL"),
    keep_pattern =>  RE (Comment => "SQL", -Keep => 1),
    full_text    =>  1,
    name         => "SQL comment",
);

my $test_mysql = Test::Regexp:: -> new -> init (
    pattern      =>  RE (Comment => "SQL", -flavour => "MySQL"),
    keep_pattern =>  RE (Comment => "SQL", -flavour => "MySQL", -Keep => 1),
    full_text    =>  1,
    name         => "MySQL comment",
);

my $test_plsql = Test::Regexp:: -> new -> init (
    pattern      =>  RE (Comment => "SQL", -flavour => "PL/SQL"),
    keep_pattern =>  RE (Comment => "SQL", -flavour => "PL/SQL", -Keep => 1),
    full_text    =>  1,
    name         => "PL/SQL comment",
);

my @tests = ($test_sql, $test_mysql, $test_plsql);

my @test_data = (
    ["Empty comment"   => ""],
    ["Normal comment"  => "This is a comment"],
    ["Space"           => " "],
    ["Unicode"         => "Pick up the \x{260F}!"],
);

foreach my $entry (@test_data) {
    my ($name, $body) = @$entry;

    my $delimiter = "--";
    my $comment   = "$delimiter$body\n";
    my $test_name = "$name, default delimiter";

    my $captures  = [[comment         => $comment],
                     [open_delimiter  => $delimiter],
                     [body            => $body],
                     [close_delimiter => "\n"]];

    foreach my $test ($test_sql, $test_plsql) {
        $test -> match ($comment,
                        test     => $test_name,
                        captures => $captures);
    }

    #
    # In MySQL, the '--' needs to be followed by a space, and '#' is fine too
    #
    foreach my $delimiter ("-- ", "#") {
        my $comment   = "$delimiter$body\n";
        my $test_name = $delimiter eq "-- " ? "$name, default delimiter"
                                            : "$name, hash delimiter";

        my $captures  = [[comment         => $comment],
                         [open_delimiter  => $delimiter],
                         [body            => $body],
                         [close_delimiter => "\n"]];

        $test_mysql -> match ($comment,
                               test     => $test_name,
                               captures => $captures);

        #
        # We can test duplicated delimiters here, unlike for plain SQL.
        #
        $comment   = "$delimiter$delimiter$body\n";
        $test_name = "$name, doubled delimiter";

        $captures  = [[comment         => $comment],
                      [open_delimiter  => $delimiter],
                      [body            => "$delimiter$body"],
                      [close_delimiter => "\n"]];

        $test_mysql -> match ($comment,
                               test     => $test_name,
                               captures => $captures);
    }

    #
    # Extended delimiter for SQL
    #
    foreach my $delimiter ("---", "----") {
        my $comment   = "$delimiter$body\n";
        my $test_name = "$name, extended delimiter";

        my $captures  = [[comment         => $comment],
                         [open_delimiter  => $delimiter],
                         [body            => $body],
                         [close_delimiter => "\n"]];

        $test_sql -> match ($comment,
                             test     => $test_name,
                             captures => $captures);

        #
        # For PL/SQL, these comments are fine as well, but the delimiter
        # is slightly different.
        #
        $captures  = [[comment         => $comment],
                      [open_delimiter  => "--"],
                      [body            => substr ($delimiter, 2) . $body],
                      [close_delimiter => "\n"]];

        $test_plsql -> match ($comment,
                               test     => $test_name,
                               captures => $captures);
    }

    #
    # PL/SQL also allows C-style comments
    #
    my $open_delimiter  = "/*";
    my $close_delimiter = "*/";
       $comment         = "$open_delimiter$body$close_delimiter";
       $test_name       = "$name, C-style delimiters";

       $captures  = [[comment         => $comment],
                     [open_delimiter  => $open_delimiter],
                     [body            => $body],
                     [close_delimiter => $close_delimiter]];

    $test_plsql -> match ($comment,
                           test     => $test_name,
                           captures => $captures);
}

#
# Test failures
#
foreach my $test (@tests) {
    $test -> no_match ("",
                       reason => "Empty string");
    $test -> no_match ("-- This is a comment",
                        reason => "No trailing newline");
    $test -> no_match ("- This is a comment\n",
                        reason => "Opening delimiter too short");
    $test -> no_match (" -- This is a comment\n",
                        reason => "Space before comment");
    $test -> no_match ("-- This is a comment\n\n",
                        reason => "Double newline");
    $test -> no_match ("-- This is\na comment\n",
                        reason => "Internal newline");
    $test -> no_match ("// This is a comment\n",
                        reason => "Incorrect delimiter");
}

foreach my $test ($test_sql, $test_plsql) {
    $test -> no_match ("# This is a comment\n",
                        reason => "Incorrect delimiter");
}

$test_mysql -> no_match ("--This is a comment\n",
                          reason => "No space in delimiter");

$test_plsql -> no_match ("/* This is a comment\n",
                          reason => "Mismatched delimiters");
$test_plsql -> no_match ("-- This is a comment */",
                          reason => "Mismatched delimiters");


Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
