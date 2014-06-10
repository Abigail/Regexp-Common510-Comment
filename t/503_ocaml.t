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

my $pattern      = RE Comment => 'OCaml'; 
my $keep_pattern = RE Comment => 'OCaml', -Keep => 1;

my $test = Test::Regexp -> new -> init (
    keep_pattern    => $pattern,
    no_keep_message => 1,
    name            => "OCaml Comment",
);

my $keep_test = Test::Regexp -> new -> init (
    keep_pattern    => $keep_pattern,
    name            => "OCaml Comment",
);

my ($tag)      = $pattern      =~ /(__RC_Comment_[^>]+)>/;
my ($keep_tag) = $keep_pattern =~ /(__RC_Comment_[^>]+)>/;

my $open  = '(*';
my $close = '*)';


my @pass_data = (
    ["Empty body"         =>   ""],
    ["Space body"         =>   " "],
    ["Newline as comment" =>  "\n"],
    ["Regular comment"    =>  "This is a comment"],
    ["Unicode"            =>  "Pick up the \x{260F}!"],
    ["Single quote"       =>  "This is ' a comment"],
    ["Single quotes"      =>  "This is ' a ' comment"],
    #
    # A couple of 'nested' cases
    #
    ["Nested comment"        => "This is ${open} a ${close} comment"],
    ["Double nested comment" => "This ${open} is ${open} a " .
                                "${close} comment ${close}"],
    ["Multi nested comment"  => "${open} This ${close} ${open} is " .
                                "${open} a ${close}${close} comment"],
    #
    # With string literals
    #
    ["String inside"                   => 'This is "a comment"'],
    ["Open delimiter inside string"    => 'This "${open}" is a comment'],
    ["Close delimiter inside string"   => 'This "${close}" is a comment'],
    ["Escape inside string"            => 'This "is \" a ${close} " comment'],
    ["Escaped single quote in literal" => q {This is "\'"a comment}],
    ["Numeric constant in literal"     => q {This is "\123"a comment}],
    ["Hex constant in literal"         => q {This is "\x23"a comment}],

    #
    # Quotes
    #
    ["Single quote"           => "This is 'a comment"],
    ["Single quote"           => "This is 'a' comment"],
    ["Escaping"               => 'This is \a comment'],
);

my @fail_data = (
    ["Empty string"           => ""],
    ["No open delimiter"      => "This is a comment $close"],
    ["No close delimiter"     => "$open This is a comment"],
    ["Leading whitespace"     => " $open This is a comment $close"],
    ["Trailing newline"       => "$open This is a comment $close\n"],
    ["Incomplete delimiter"   => "(This is a comment $close"],
    ["Incomplete delimiter"   => "*This is a comment $close"],
    ["Incomplete delimiter"   => "$open This is a comment *"],
    ["Incomplete delimiter"   => "$open This is a comment )"],

    #
    # Incorrect nesting
    #
    ["Incorrect nesting"      => "$open This is $open a comment $close"],
    ["Incorrect nesting"      => "$open This is $close a comment $close"],
    ["Incorrect nesting"      => "$open This is $close $open a comment $close"],

    #
    # Quotes
    #
    ["Unclosed double quote"      => qq {$open This is "a comment $close}],
    ["Single quote in literal"    => qq {$open This is "'"a comment $close}],
    ["Numeric constant too short" => qq {$open This is "\\12"a comment $close}],
    ["Hex constant too short"     => qq {$open This is "\\x2"a comment $close}],

);

foreach my $entry (@pass_data) {
    my ($test_name, $body) = @$entry;
    my $comment = "$open$body$close";
    my $captures      = [[$tag            => $comment]],
    my $keep_captures = [[$keep_tag       => $comment],
                         [comment         => $comment],
                         [open_delimiter  => $open],
                         [body            => $body],
                         [close_delimiter => $close]];

    $test -> match ($comment,
                     test     => $test_name,
                     captures => $captures);
    $keep_test -> match ($comment,
                          test     => $test_name,
                          captures => $keep_captures);
}

foreach my $entry (@fail_data) {
    my ($reason, $subject) = @$entry;

    $test      -> no_match ($subject, reason => $reason);
    $keep_test -> no_match ($subject, reason => $reason);
}
     

Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
