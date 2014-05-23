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

my @data = (
    Dylan            =>  '/*',      '*/',
    Caml             =>  '(*',      '*)',
    Haskell          =>  '{-',      '-}',
    Hugo             =>  '!\\',     '\\!',
   'Modula-2'        =>  '(*',      '*)',
   'Modula-3'        =>  '(*',      '*)',
    SLIDE            =>  '(*',      '*)',
);

while (@data) {
    my ($lang, $flavour) = parse_lang shift @data;
    my  $open            =            shift @data;
    my  $close           =            shift @data;

    my @pass;  # Only bodies.
    my @fail;  # Complete subjects.

    my $nest = $W;
       $nest = "$open$nest$close" for 1 .. 100;

    my $nest7 = $W;
    my $nest9 = $W;
       $nest7 = "$open$nest7$close" for 1 .. 7;
       $nest9 = "$open$nest9$close" for 1 .. 9;

    push @pass => 
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
        ;


    push @fail => 
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
    ;

    if (length ($open) > 1) {
        my $Open = $open;
        $Open =~ s/^.\K/ /;
        push @fail =>
            ["$Open$close"               => "garbled open delimiter"],
            ["$Open $W $W $close"        => "garbled open delimiter"],
            ["$Open $open $close $close" => "garbled open delimiter"];
    }
    if (length ($close) > 1) {
        my $Close = $close;
        $Close =~ s/(.)$/ $1/;
        push @fail =>
            ["$open$Close"               => "garbled close delimiter"],
            ["$open $W $W $Close"        => "garbled close delimiter"],
            ["$open $open $close $Close" => "garbled close delimiter"];
    }


    run_tests
        pass                  => \@pass,
        fail                  => \@fail,
        language              => $lang,
        flavour               => $flavour,
        ghost_name_captures   => 1,
        ghost_num_captures    => 1,
        make_subject          => sub {$open . $_ [0] . $close},
        make_captures         => sub {
            [[comment         => $open . $_ [0] . $close],
             [undef ()        => $open . $_ [0] . $close],
             [open_delimiter  => $open],
             [body            => $_ [0]],
             [close_delimiter => $close]]
        },
    ;

}
