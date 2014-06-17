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

Test::NoWarnings::had_no_warnings () if $r;

done_testing;


__END__
