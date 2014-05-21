#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';

use strict;
use warnings;
no  warnings 'syntax';

our $r = eval "require Test::NoWarnings; 1";

my $test = Test::Regexp:: -> new -> init (
    pattern      =>  RE (Comment => "INTERCAL"),
    keep_pattern =>  RE (Comment => "INTERCAL", -Keep => 1),
    full_text    =>  1,
    name         => "INTERCAL comment",
);

my @delims = ("DO NOT", "DON'T", "PLEASE NOT", "PLEASE DONOT", "PLEASE DON'T");

foreach my $delim (@delims) {
    my $body    = "";
    my $comment = "$delim\n";
    $test -> match ($comment,
                     test     => "Empty comment",
                     captures => [[comment         => $comment],
                                  [open_delimiter  => $delim],
                                  [body            => $body],
                                  [close_delimiter => "\n"]]);

    $body    = "This is a comment";
    $comment = "${delim}${body}\n";
    $test -> match ($comment,
                     test     => "Normal comment",
                     captures => [[comment         => $comment],
                                  [open_delimiter  => $delim],
                                  [body            => $body],
                                  [close_delimiter => "\n"]]);


    $body    = " ";
    $comment = "${delim}${body}\n";
    $test -> match ($comment,
                     test     => "Space comment",
                     captures => [[comment         => $comment],
                                  [open_delimiter  => $delim],
                                  [body            => $body],
                                  [close_delimiter => "\n"]]);

    unless ($delim =~ /DO/) {
        my $comment = "${delim}${delim}\n";
        $test -> match ($comment,
                         test     => "Doubled opening delimiter",
                         captures => [[comment         => $comment],
                                      [open_delimiter  => $delim],
                                      [body            => $delim],
                                      [close_delimiter => "\n"]]);
    }

    $body    = "Pick up the \x{260F}!";
    $comment = "${delim}${body}\n";
    $test -> match ($comment,
                     test     => "Unicode comment",
                     captures => [[comment         => $comment],
                                  [open_delimiter  => $delim],
                                  [body            => $body],
                                  [close_delimiter => "\n"]]);

    $body    = "Do be do be do";
    $comment = "${delim}${body}\n";
    $test -> match ($comment,
                     test     => "Do and do are allowed",
                     captures => [[comment         => $comment],
                                  [open_delimiter  => $delim],
                                  [body            => $body],
                                  [close_delimiter => "\n"]]);

    $test -> no_match ("${delim}This is a comment",
                        reason => "No closing delimiter");

    $test -> no_match ("${delim} \n\n",
                        reason => "Double closing delimiter");

    $test -> no_match ("${delim} A Comment to DO something\n",
                        reason => "Comment may not contain DO");

    $test -> no_match ("\L${delim}\E This is a comment\n",
                        reason => "Delimiter in lower case");
}

foreach my $delim ("PLEASE DO", "DO", "PLEASE") {
    $test -> no_match ("${delim}This is a comment\n",
                        reason => "Incorrect delimiter");
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
