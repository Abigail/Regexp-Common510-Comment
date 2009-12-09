package Regexp::Common510::Comment;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2009120201';

use Regexp::Common510 -api => 'pattern', 'unique_name';

my $NO_NL = $] >= 5.011001 ? '\N' : '[^\n]';

#
# Return a pattern which starts with a specific token, and lasts
# up till the first following newline.
#
sub eol ($) {
    my $open = shift;

    "(?k<open_delimiter>:$open)" .
    "(?k<body>:$NO_NL*)"         .
    "(?k<close_delimiter>:\n)";
}

#
# Return a pattern that starts and ends with specific tokens.
#
sub from_to ($$) {
    my ($open, $close) = @_;

    my $body;
    if (length ($close) == 1) {
        $body = "[^$close]*";
    }
    else {
        my $f = quotemeta substr $close, 0, 1;
        my $l = quotemeta substr $close, 1;
        $body = "[^$f]*(?:$f(?!$l)[^$f]*)*";
    }

    "(?k<open_delimiter>:\Q$open\E)"   .
    "(?k<body>:$body)"                 .
    "(?k<close_delimiter>:\Q$close\E)";
}


my @eol = (
    ABC              =>  '\\\\',  # That's a *single* backslash.
    Ada              =>  '--',
    Advisor          =>  '#|//',
    Advsys           =>  ';',
    Alan             =>  '--',
    awk              =>  '#',
   'beta-Juliet'     =>  '//',
    CLU              =>  '%',
    CQL              =>  ';',
   'Crystal Report'  =>  '//',
    Eiffel           =>  '--',
    Forth            =>  '\\\\',
    Fortran          =>  '!',
    fvwm2            =>  '#',
    ICON             =>  '#',
    ILLGOL           =>  'NB',
    J                =>  'NB[.]',
    LaTeX            =>  '%',
    Lisp             =>  ';',
    LOGO             =>  ';',
    lua              =>  '--',
    M                =>  ';',
    m4               =>  '#',
    MUMPS            =>  ';',
    mutt             =>  '#',
    Perl             =>  '#',
   'PL/B'            =>  '[.;]',
    Portia           =>  '//',
    Python           =>  '#',
   'Q-BAL'           =>  '`',
    QML              =>  '#',
    R                =>  '#',
    REBOL            =>  ';',
    Ruby             =>  '#',
    Scheme           =>  ';',
    shell            =>  '#',
    slrn             =>  '%',
    SMITH            =>  ';',
    SQL              =>  '-{2,}',
    Tcl              =>  '#',
    TeX              =>  '%',
    troff            =>  '\\\"',
    Ubercode         =>  '//',
    vi               =>  '"',
    zonefile         =>  ';',
   'ZZT-OOP'         =>  "'",
);

my @from_to = (
   'Algol 60'        =>  'comment', ';',
    ALPACA           =>  '/*',      '*/',
    B                =>  '/*',      '*/',
    BML              =>  '<?_c',    '_c?>',
    C                =>  '/*',      '*/',
   'C--'             =>  '/*',      '*/',
   'Befunge-98'      =>  ';',       ';',
    False            =>  '!{',      '}!',
   'Funge-98'        =>  ';',       ';',
    Haifu            =>  ',',       ',',
    LPC              =>  '/*',      '*/',
    Oberon           =>  '(*',      '*)',
   'PL/I'            =>  '/*',      '*/',
    Shelta           =>  ';',       ';',
    Smalltalk        =>  '"',       '"',
   '*W'              =>  '||',      '!!',
);

my @eol_from_to = (
   'C++'             =>  '//',      '/*',  '*/',
   'C#'              =>  '//',      '/*',  '*/',
    Cg               =>  '//',      '/*',  '*/',
    ECMAScript       =>  '//',      '/*',  '*/',
    FPL              =>  '//',      '/*',  '*/',
    Java             =>  '//',      '/*',  '*/',
    JavaScript       =>  '//',      '/*',  '*/',
    Nickle           =>  '#',       '/*',  '*/',
    PEARL            =>  '!',       '/*',  '*/',
    PHP              =>  '#|//',    '/*',  '*/',
   'PL/SQL'          =>  '--',      '/*',  '*/',
);


my @nested = (
    Caml             =>  '(*',  '*)',
   'Modula-2'        =>  '(*',  '*)',
   'Modula-3'        =>  '(*',  '*)',
);


my @eol_nested = (
    Dylan            =>  '//',       '/*',  '*/',
#   Hugo             =>  '!(?!\\\\', '!\\', '\\!',
    Haskell          =>  '-{2,}',    '{-',  '-}',
    SLIDE            =>  '#',        '(*',  '*)',
);


#
# Assumes tags are at least 2 characters long.
#
sub nested {
    my ($open, $close, %arg) = @_;

    my $fo  =           substr $open,  0, 1;
    my $lo  = quotemeta substr $open,  1;
    my $fc  =           substr $close, 0, 1;
    my $lc  = quotemeta substr $close, 1;

    my $tag = $arg {tag} || unique_name;

    "(?<$tag>" .
        "(?k<open_delimiter>:[$fo]$lo)"  .
        "(?k<body>:[^$fo$fc]*"           .
            "(?:(?:[$fo](?!$lo)|[$fc](?!$lc)|(?&$tag))[^$fo$fc]*)*" .
        ")" .
        "(?k<close_delimiter>:[$fc]$lc)" .
    ")";
}


while (@eol) {
    my ($lang, $token) =   splice @eol, 0, 2;
    my  $pattern       =   eol $token;
    pattern Comment    => $lang,
            -pattern   => "(?k<comment>:$pattern)",
    ;
}

while (@from_to) {
    my ($lang, $open, $close) =   splice @from_to, 0, 3;
    my  $pattern              =   from_to $open => $close;
    pattern Comment           => $lang,
            -pattern          => "(?k<comment>:$pattern)",
    ;
}

while (@eol_from_to) {
    my ($lang, $token, $open, $close) = splice @eol_from_to, 0, 4;
    my  $pattern1             =   eol     $token;
    my  $pattern2             =   from_to $open => $close;
    pattern Comment           => $lang,
            -pattern          => "(?k<comment>:(?|$pattern1|$pattern2))",
    ;
}


while (@nested) {
    my ($lang, $open, $close) = splice @nested, 0, 3;

    my $pattern = nested $open => $close;

    pattern Comment  => $lang,
            -pattern => "(?k<comment>:$pattern)",
    ;
}

while (@eol_nested) {
    my ($lang, $token, $open, $close) = splice @eol_nested, 0, 4;

    my $tag      = unique_name;

    my $eol_pattern    = eol    $token;
    my $nested_pattern = nested $open => $close, tag => $tag;

    #
    # There will be an additional (?<$tag>) in the 'eol' alternation
    # as a work around [See bug #71136].
    # There's some trickery to make the capture be undef in %- when taking 
    # this alternative.
    #
    $eol_pattern = "(?<$tag>(*FAIL))?$eol_pattern";

    #
    # Because we repeat a tag name, and there's recursion on this name in
    # $nested_pattern, it's vital $nested_pattern is to the left of
    # $eol_pattern.
    #
    pattern Comment  => $lang,
            -pattern => "(?k<comment>:(?|$nested_pattern|$eol_pattern))",
    ;
}

1;

__END__

=head1 NAME

Regexp::Common510::Comment - Abstract

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp--Common510--Comment.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.be >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2009 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),   
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 INSTALLATION

To install this module, run, after unpacking the tar-ball, the 
following commands:

   perl Makefile.PL
   make
   make test
   make install

=cut
