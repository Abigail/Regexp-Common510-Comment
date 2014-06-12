#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';

use strict;
use warnings;
no  warnings 'syntax';

our $r = eval "require Test::NoWarnings; 1";

my $tester_algol58 =   Test::Regexp:: -> new -> init (
    pattern        =>  RE (Comment => 'ALGOL', -flavour => 58),
    keep_pattern   =>  RE (Comment => 'ALGOL', -flavour => 58, -Keep => 1),
    name           => "ALGOL 58 comment",
    full_text      =>  1,
);

my $tester_algol60 =   Test::Regexp:: -> new -> init (
    pattern        =>  RE (Comment => 'ALGOL', -flavour => 60),
    keep_pattern   =>  RE (Comment => 'ALGOL', -flavour => 60, -Keep => 1),
    name           => "ALGOL 60 comment",
    full_text      =>  1,
);

my $tester_algol68 =   Test::Regexp:: -> new -> init (
    pattern        =>  RE (Comment => 'ALGOL', -flavour => 68),
    keep_pattern   =>  RE (Comment => 'ALGOL', -flavour => 68, -Keep => 1),
    name           => "ALGOL 68 comment",
    full_text      =>  1,
);

my $tester_a68toc  =   Test::Regexp:: -> new -> init (
    pattern        =>  RE (Comment => 'ALGOL', -flavour => 'a68toc'),
    keep_pattern   =>  RE (Comment => 'ALGOL', -flavour => 'a68toc',
                                               -Keep    => 1),
    name           => "ALGOL 68 (a68toc compiler) comment",
    full_text      =>  1,
);

my $tester_W       =   Test::Regexp:: -> new -> init (
    pattern        =>  RE (Comment => 'ALGOL', -flavour => 'W'),
    keep_pattern   =>  RE (Comment => 'ALGOL', -flavour => 'W',
                                               -Keep    => 1),
    name           => "ALGOL-W comment",
    full_text      =>  1,
);

my $ALGOL_58 = 0x01;
my $ALGOL_60 = 0x02;
my $ALGOL_68 = 0x04;
my $A68_TOC  = 0x08;
my $ALGOL_W  = 0x10;

my %tests = (
    $ALGOL_58 => $tester_algol58,
    $ALGOL_60 => $tester_algol60,
    $ALGOL_68 => $tester_algol68,
    $A68_TOC  => $tester_a68toc,
    $ALGOL_W  => $tester_W,
);
my @tags = sort {$a <=> $b} keys %tests;

my @token_pairs = (
    [$ALGOL_58 | $ALGOL_60 | $ALGOL_W => "comment"  => ";"],
    [$ALGOL_68 | $A68_TOC             => "#"        => "#"],
    [$ALGOL_68                        => "comment"  => "comment"],
    [$ALGOL_68                        => "co"       => "co"],
    [$ALGOL_68                        => "\x{A2}"   => "\x{A2}"],
    [$A68_TOC                         => "COMMENT"  => "COMMENT"],
    [$A68_TOC                         => "CO"       => "CO"],
    [$A68_TOC                         => "{"        => "}"],
    [$ALGOL_W                         => "%"        => "%"],
    [$ALGOL_W                         => "%"        => ";"],
);
   

my @pass_data = (
    ["Empty comment"   => ""],
    ["Normal comment"  => "This is the body"],
    ["Space"           => " "],
    ["Unicode"         => "Pick up the \x{260F}!"],
    ["Has newline"     => "This is\nthe body"],
);


foreach my $token_pair (@token_pairs) {
    my ($mask, $open, $close) = @$token_pair;

    foreach my $tag (@tags) {
        next unless $mask & $tag;
        my $test = $tests {$tag};
        foreach my $pass_entry (@pass_data) {
            my ($test_name, $body) = @$pass_entry;
            next if $body eq "" && $open =~ /\w$/ && $close =~ /^\w/;
            my  $wsl = my $wsr = "";
            if ($open  =~ /\w$/ && $body && $body =~ /^\w/) {$wsl = " "}
            if ($close =~ /^\w/ && $body && $body =~ /\w$/) {$wsr = " "}
            my $comment  = "${open}${wsl}${body}${wsr}${close}";
            my $captures = [
                [comment         => $comment],
                [open_delimiter  => $open],
                [body            => "${wsl}${body}${wsr}"],
                [close_delimiter => $close],
            ];
            $test -> match ($comment,
                            captures => $captures,
                            test     => $test_name);
        }
    }
}





Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
