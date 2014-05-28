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

my $SPACE   = " ";        # Space
my $SEPCHAR = "\t";       # Tab
my $RS      = "\x{0A}";   # \r, Carriage Return
my $RE      = "\x{0D}";   # \n, New Line
my $MDO     = "<!";
my $MDC     = ">";
my $COM     = "--";

my $pattern      = RE Comment => 'HTML'; 
my $keep_pattern = RE Comment => 'HTML', -Keep => 1;

my $test = Test::Regexp -> new -> init (
    pattern      => $pattern,
    keep_pattern => $keep_pattern,
    full_text    =>  1,
    name         => "HTML Comment",
);

my @pass_data = (
    ["Empty comment"         => ""],
    ["Space comment"         => " "],
    ["Newline comment"       => "\n"],
    ["Normal comment"        => "This is a comment"],
    ["Comment with Unicode"  => "Pick up the \x{260F}!"],
    ["Dash as comment"       => "- "],
    ["Dashes in comment"     => "This - is - a - comment"],
    ["Fake close"            => ">"],
    ["Fake close 2"          => "This is > a comment"],
    ["Fake open"             => "<!"],
    ["Fake open 2"           => "\n<! This is a comment"],
);

my @spaces =  ("", $SPACE, "$RE$SEPCHAR$SPACE$RS");

foreach my $entry (@pass_data) {
    my ($test_name, $body) = @$entry;
    foreach my $space (@spaces) {
        my  $comment = "$MDO$COM$body$COM$space$MDC";
        my  $captures = [
            [comment          =>  $comment],
            [MDO              =>  $MDO],
            [bodies           => "$COM$body$COM$space"],
            [COM              =>  $COM],
            [body             =>  $body],
            [MDC              =>  $MDC],
        ];

        $test -> match ($comment,
                        test     => $test_name,
                        captures => $captures);
    }
}

for (my $i = 0; $i < @pass_data; $i ++) {
    my $j = 1 * $i ** 2;
    my $space1   =  $spaces [$i % @spaces];
    my $space2   =  $spaces [$j % @spaces];
    my $body1    =  $pass_data [$i] [1];
    my $body2    =  $pass_data [$j % @pass_data] [1];
    my $comment  = "$MDO$COM$body1$COM$space1$COM$body2$COM$space2$MDC";
    my $captures = [
        [comment          =>  $comment],
        [MDO              =>  $MDO],
        [bodies           => "$COM$body1$COM$space1$COM$body2$COM$space2"],
        [COM              =>  $COM],
        [body             =>  $body2],
        [MDC              =>  $MDC],
    ];

    $test -> match ($comment,
                     test     => "Multiple comments",
                     captures => $captures);
}

my $bodies   = join $SPACE => map {"$COM$_$COM"} map {$$_ [1]} @pass_data;
my $comment  = "$MDO$bodies$MDC";
my $captures = [
    [comment          =>  $comment],
    [MDO              =>  $MDO],
    [bodies           =>  $bodies],
    [COM              =>  $COM],
    [body             =>  $pass_data [-1] [1]],
    [MDC              =>  $MDC],
];

$test -> match ($comment,
                 test     => "Many comments",
                 captures => $captures);

$bodies   = "$COM$COM" x 40;
$comment  = "$MDO$bodies$MDC";
$captures = [
    [comment          =>  $comment],
    [MDO              =>  $MDO],
    [bodies           =>  $bodies],
    [COM              =>  $COM],
    [body             =>   ""],
    [MDC              =>  $MDC],
];

$test -> match ($comment,
                 test     => "Many empty comments",
                 captures => $captures);

my @fail_data = (
    ["Empty string"       =>  ""],
    ["No MDO"             =>  "--This is not a comment-->"],
    ["No MDC"             =>  "<!--This is not a comment>"],
    ["No COM"             =>  "<!This is not a comment-->"],
    ["No COM"             =>  "<!--This is not a comment>"],
    ["Incorrect COM"      =>  "<!-This is not a comment-->"],
    ["Incorrect COM"      =>  "<!--This is not a comment->"],
    ["Trailing newline"   =>  "<!--This is not a comment-->\n"],
    ["Leading space"      =>  " <!--This is not a comment-->"],
    ["Space after MDO"    =>  "<! --This is not a comment-->"],
    ["COM too long"       =>  "<!--This is not a comment--->"],
    ["Odd number of COMs" =>  "<!--This is--not a comment-->"],
    ["Too many dashes"    =>  "<!" . ("--" x 40) . "->"],
    ["Too many dashes"    =>  "<!" . ("--" x 40) . "-->"],
    ["Too many dashes"    =>  "<!" . ("--" x 40) . "--->"],
    ["No COM"             =>  "<!>"],
    ["Incomplete COMs"    =>  "<!->"],
    ["Incomplete COMs"    =>  "<!-->"],
    ["Incomplete COMs"    =>  "<!--->"],
    ["Non whitespace between COMs" =>
                              "<!--This is not a comment--, " .
                                "--This is not a comment-->"],
);

foreach my $ws ("\x{0b}", "\x{85}", "\x{A0}", "\x{2029}", "\x{2002}") {
    push @fail_data => 
        ["Bad whitespace between comments" => 
             "<!--This is not a comment-- $ws --This is not a comment-->"];
}

foreach my $entry (@fail_data) {
    my ($reason, $subject) = @$entry;

    $test -> no_match ($subject, reason => $reason);
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;

__END__
