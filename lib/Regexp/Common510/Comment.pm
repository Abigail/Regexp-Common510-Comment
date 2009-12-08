package Regexp::Common510::Comment;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2009120201';

use Regexp::Common510 -api => 'pattern', 'name2key';

my $NO_NL = $] >= 5.011001 ? '\N' : '[^\n]';

#
# Return a pattern which starts with a specific token, and lasts
# up till the first following newline.
#
sub eol ($$) {
    my $lang  = shift;
    my $token = shift;

    my $key   = "Comment__" . name2key $lang;

    "(?k<$key>:"  .
         "(?k<open_delimiter>:$token)"  .
         "(?k<body>:$NO_NL*)"           .
         "(?k<close_delimiter>:\n)"     .
    ")";
}

#
# Return a pattern that starts and ends with specific tokens.
#
sub from_to ($$$) {
    my ($lang, $open, $close) = @_;

    my $key   = "Comment__" . name2key $lang;

    my $body;
    if (length ($close) == 1) {
        $body = "[^$close]*";
    }
    else {
        my $f = quotemeta substr $close, 0, 1;
        my $l = quotemeta substr $close, 1;
        $body = "[^$f]*(?:$f(?!$l)[^$f]*)*";
    }

    return "(?k<$key>:"  .
                "(?k<open_delimiter>:\Q$open\E)"   .
                "(?k<body>:$body)"                 .
                "(?k<close_delimiter>:\Q$close\E)" .
           ")";
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


while (@eol) {
    my ($lang, $token) =   splice @eol, 0, 2;
    pattern Comment    => $lang,
            -pattern   =>  eol $lang => $token,
}

while (@from_to) {
    my ($lang, $open, $close) =   splice @from_to, 0, 3;
    pattern Comment           => $lang,
            -pattern          =>  from_to $lang => $open, $close;
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
