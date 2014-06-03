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
    ["String inside"                 => 'This is "a comment"'],
    ["Open delimiter inside string"  => 'This "${open}" is a comment'],
    ["Close delimiter inside string" => 'This "${close}" is a comment'],

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
    ["Unclosed double quote"   => qq {$open This is "a comment $close}],
    ["Single quote in literal" => qq {$open This is "'"a comment $close}],
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

my $nest = $W;
   $nest = "$open$nest$close" for 1 .. 100;

my $nest7 = $W;
my $nest9 = $W;
   $nest7 = "$open$nest7$close" for 1 .. 7;
   $nest9 = "$open$nest9$close" for 1 .. 9;

my @pass = (
    [""                      =>  "empty body"],
    ["$W $W"                 =>  "standard body"],
    ["\n"                    =>  "body is newline"],
    ["$W \x{BB} $W"          =>  "Latin-1 in body"],
    ["$W \x{4E00} $W"        =>  "Unicode in body"],
    [$BIG                    =>  "Large body"],
    ["--"                    =>  "hyphens"],
    [" // "                  =>  "slashes"],
    [" "                     =>  "body is a space"],
    ["*"                     =>  "body is a star"],
    ["$open$close"           =>  "simple nested"],
    ["$W $open $W $close $W" =>  "nested"],
    [$nest                   =>  "deeply nested"],
    ["$nest7 $W $nest9"      =>  "double nested"],

    [qq {" "}                =>  "string inside"],
    [qq {"(*"}               =>  "open delimiter inside string"],
    [qq {"*)"}               =>  "close delimiter inside string"],
    [qq {"\\""}              =>  "escaped string delimiter inside string"],
    [qq {'}                  =>  "lone single quote"],
    [qq {' '}                =>  "single quotes"],
);


my @fail = (
    #
    # "Standard" fail tests.
    #
    ["$open"                 =>  "no close delimiters"],
    ["$open $open $close"    =>  "not enough close delimiters"],
    ["$open $close $close $open"
                             =>  "unbalanced delimiters"],
    ["$open $close//"        =>  "trailing garbage"],
    ["$open $close "         =>  "trailing space"],
    ["$open $open $close $close\n"
                             =>  "trailing newline"],
    ["$open $W $W $open"     =>  "open instead of close delimiter"],
    ["$open \n $open"        =>  "open instead of close delimiter"],
    ["$open $close$open $close"
                             =>  "unbalanced delimiters"],
    ["$close$open"           =>  "reversed delimiters"],
    ["$close $W $open"       =>  "reversed delimiters"],
    ["$open$close$close"     =>  "extra close delimiter"],
    ["$open $W $W"           =>  "no close delimiter"],
    ["$open ??"              =>  "no close delimiter"],
    [" $open $W $close"      =>  "leading space"],
    ["\n$open $open $close $close"
                             =>  "leading newline"],
    ["$open $open $close $close $BIG"
                             =>  "body after close delimiter"],

    #
    # Special 'OCaml' failures
    #
    [qq {$open " $close}     =>  "lone double quote"],
    [qq {$open "'" $close}   =>  "single quotes inside double quotes"],
    [qq {$open "\\q" $close} =>  "not a proper escape"],
    [qq {$open "\\12" $close}  =>  "incomplete decimal escape"],
    [qq {$open "\\F " $close}  =>  "incomplete hex escape"],
);

run_tests
    pass                 => \@pass,
    fail                 => \@fail,
    checker              => $checker,
    ghost_name_captures  => 1,
    ghost_num_captures   => 1,
    make_subject         => sub {'(*' . $_ [0] . '*)'},
    make_captures        => sub {[
        [undef ()        => $open . $_ [0] . $close],
        [open_delimiter  => $open],
        [body            => $_ [0]],
        [close_delimiter => $close],
    ]}
;
