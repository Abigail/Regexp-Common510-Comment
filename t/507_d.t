#!/usr/bin/perl

use 5.010;

use Test::More 0.88;
use Test::Regexp;
use Regexp::Common510 'Comment';

use strict;
use warnings;
no  warnings 'syntax';

our $r = eval "require Test::NoWarnings; 1";

my $pattern      = RE (Comment => 'D');
my $keep_pattern = RE (Comment => 'D', -Keep => 1);

my ($tag)      = $pattern      =~ /<(__RC_Comment_[^>]+)>/;
my ($keep_tag) = $keep_pattern =~ /<(__RC_Comment_[^>]+)>/;

my $test = Test::Regexp:: -> new -> init (
    keep_pattern    => $pattern,
    no_keep_message => 1,
    full_text       => 1,
    name            => "D comment",
);

my $keep_test = Test::Regexp:: -> new -> init (
    keep_pattern    => $keep_pattern,
    full_text       => 1,
    name            => "D comment",
);

my @eols = ("\x0A", "\x0D", "\x0A\x0D", "\x{2028}", "\x{2029}");

my @pass_data = (
    ["Empty body"    =>  ""],
);


foreach my $pass_data (@pass_data) {
    my ($test_name, $body) = @$pass_data;

    foreach my $eol (@eols) {
        my $comment   = "//$body$eol";
        my $captures1 = [[$tag  =>  undef]];
        my $captures2 = [[comment         =>  $comment],
                         [open_delimiter  =>  "//"],
                         [body            =>  $body],
                         [close_delimiter =>  $eol],
                         [$keep_tag       =>  undef]];

        $test -> match ($comment,
                         test     =>  $test_name,
                         captures =>  $captures1);
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
