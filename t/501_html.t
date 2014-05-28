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

my $pattern      = RE Comment => 'HTML';
my $keep_pattern = RE Comment => 'HTML', -Keep => 1;

my $test = Test::Regexp -> new -> init (
    pattern      => $pattern,
    keep_pattern => $keep_pattern,
    full_text    =>  1,
    name         => "HTML Comment",
);

my @pass_data = (
    ["Empty comment"            => ""],
    ["Space comment"            => " "],
    ["Newline comment"          => "\n"],
    ["Normal comment"           => "This is a comment"],
    ["Comment with Unicode"     => "Pick up the \x{260F}!"],
    ["Dash in comment"          => " - "],
    ["Dashes in comment"        => "This - is - a - comment"],
    ["Comment starts with dash" => "-This is a comment"],
    ["Fake close"               => "This is > a comment"],
    ["Fake open"                => "<!"],
    ["Fake open 2"              => "\n<! This is a comment"],
);


foreach my $entry (@pass_data) {
    my ($test_name, $body) = @$entry;
    my  $comment  = "<!--$body-->";
    my  $captures = [
        [comment          =>  $comment],
        [open_delimiter   =>  "<!--"],
        [body             =>  $body],
        [close_delimiter  =>  "-->"],
    ];

    $test -> match ($comment,
                    test     => $test_name,
                    captures => $captures);
}


my @fail_data = (
    ["Empty string"                  =>  ""],
    ["No open delimiter"             =>  "This is a comment-->"],
    ["Incomplete open delimiter"     =>  "<!-This is a comment-->"],
    ["Incomplete open delimiter"     =>  "<!This is a comment-->"],
    ["Incomplete open delimiter"     =>  "<This is a comment-->"],
    ["No close delimiter"            =>  "<!--This is a comment"],
    ["Incomplete close delimiter"    =>  "<!--This is a comment--"],
    ["Incomplete close delimiter"    =>  "<!--This is a comment-"],
    ["Incomplete close delimiter"    =>  "<!--This is a comment->"],
    ["Comment starts with hook"      =>  "<!-->This is a comment-->"],
    ["Comment starts with dash-hook" =>  "<!--->This is a comment-->"],
    ["Comment contains dash-dash"    =>  "<!--This is--a comment-->"],
    ["Comment ends with dash"        =>  "<!--This is a comment--->"],
    ["Old school multi-comment"      =>  "<!--This is a comment--" .
                                           "--This is also a comment-->"],
    ["Space after closing dahses"    =>  "<!--This is a comment-- >"],
    ["Too many dashes"               =>  "<!" . ("----" x 40) . ">"],
    ["Trailing newline"              =>  "<!--This is a comment-->\n"],
    ["Leading space"                 =>  " <!--This is a comment-->"],
);


foreach my $entry (@fail_data) {
    my ($reason, $subject) = @$entry;

    $test -> no_match ($subject, reason => $reason);
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;

__END__
