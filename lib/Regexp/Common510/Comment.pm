package Regexp::Common510::Comment;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2009120201';

use Regexp::Common510 -api => 'pattern', 'unique_name';

my $CATEGORY = 'Comment';

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
);


my @nested = (
    Caml             =>  '(*',  '*)',
   'Modula-2'        =>  '(*',  '*)',
   'Modula-3'        =>  '(*',  '*)',
);


my @eol_nested = (
    Dylan            =>  '//',        '/*',  '*/',
    Haskell          =>  '-{2,}',     '{-',  '-}',
    Hugo             =>  '!(?!\\\\)', '!\\', '\\!',
    SLIDE            =>  '#',         '(*',  '*)',
);


#
# Assumes tags are at least 2 characters long.
#
sub nested {
    my ($open, $close, %arg) = @_;

    my $fo  = quotemeta substr $open,  0, 1;
    my $lo  = quotemeta substr $open,  1;
    my $fc  = quotemeta substr $close, 0, 1;
    my $lc  = quotemeta substr $close, 1;

    my $tag = $arg {tag} || unique_name;

    "(?<$tag>" .
        "(?k<open_delimiter>:$fo$lo)"  .
        "(?k<body>:[^$fo$fc]*"           .
            "(?:(?:$fo(?!$lo)|$fc(?!$lc)|(?&$tag))[^$fo$fc]*)*" .
        ")" .
        "(?k<close_delimiter>:$fc$lc)" .
    ")";
}


while (@eol) {
    my ($lang, $token) =   splice @eol, 0, 2;
    my  $pattern       =   eol $token;
    pattern $CATEGORY  => $lang,
            -pattern   => "(?k<comment>:$pattern)",
    ;
}

while (@from_to) {
    my ($lang, $open, $close) =   splice @from_to, 0, 3;
    my  $pattern              =   from_to $open => $close;
    pattern $CATEGORY         => $lang,
            -pattern          => "(?k<comment>:$pattern)",
    ;
}

while (@eol_from_to) {
    my ($lang, $token, $open, $close) = splice @eol_from_to, 0, 4;
    my  $pattern1             =   eol     $token;
    my  $pattern2             =   from_to $open => $close;
    pattern $CATEGORY         => $lang,
            -pattern          => "(?k<comment>:(?|$pattern1|$pattern2))",
    ;
}


while (@nested) {
    my ($lang, $open, $close) = splice @nested, 0, 3;

    my $pattern = nested $open => $close;

    pattern $CATEGORY => $lang,
            -pattern  => "(?k<comment>:$pattern)",
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
    pattern $CATEGORY => $lang,
            -pattern  => "(?k<comment>:(?|$nested_pattern|$eol_pattern))",
    ;
}

#
# There are many implementations (flavours) of Pascal, with different
# syntaxes comments. We'll default to the ISO standard.
#
pattern $CATEGORY => 'Pascal',
        -config   => {-flavour => undef},
        -pattern  => \&pascal,
        ;

sub pascal {
    my %arg = @_;

    my @patterns;
    given ($arg {-flavour} // "") {

        #
        # http://www.pascal-central.com/docs/iso10206.txt
        #
        when (["", "ISO"]) {
            @patterns = "(?k<open_delimiter>:[{]|\Q(*\E)"         .
                        "(?k<body>:[^}*]*(?:[*](?![)])[^}*]*)*)"  .
                        "(?k<close_delimiter>:[}]|\Q*)\E)"
            ;
        }

        #
        # http://www.templetons.com/brad/alice/language/
        #
        when ("Alice") {
            @patterns = "(?k<open_delimiter>:[{])"   .
                        "(?k<body>:[^}\n]*)"         .
                        "(?k<close_delimiter>:[}])"
            ;
        }

        #
        # http://info.borland.com/techpubs/delphi5/oplg/
        # http://www.freepascal.org/docs-html/ref/ref.html
        # http://www.gnu-pascal.de/gpc/
        #
        when (["Delphi", "Free", "GPC"]) {
            push @patterns => eol '//';
            continue;
        }

        #
        # http://docs.sun.com/db/doc/802-5762
        #
        when (["Delphi", "Free", "GPC", "Workshop"]) {
            push @patterns => from_to ('{', '}'),
                              from_to ('(*', '*)')
            ;
            continue;
        }

        when (["Workshop"]) {
            push @patterns => from_to ('"',  '"'),
                              from_to ('/*', '*/'),
            ;
        }

        default {
            # Known flavours may fall through to this, hence the 
            # test for @patterns.
            die "Unknown -flavour '$_'" unless @patterns;
        }
    }

    local $" = "|";
    "(?k<comment>:(?|@patterns))";
}

#
# There are many implementations (flavours) of BASIC, with different
# syntaxes comments.
#
pattern $CATEGORY => 'BASIC',
        -config   => {-flavour => undef},
        -pattern  => \&basic,
        ;

sub basic {
    my %arg = @_;

    my @patterns;

    given ($arg {-flavour} // "") {
        when ([""]) {
            @patterns = eol "REM";
        }

        #
        # http://www.rainingdata.com/products/beta/docs/mve/50/
        #                                          ReferenceManual/Basic.pdf
        #
        when (["mvEnterprise"]) {
            @patterns = eol "[*!]|REM";
        }

        default {
            # Known flavours may fall through to this, hence the 
            # test for @patterns.
            die "Unknown -flavour '$_'" unless @patterns;
        }
    }

    local $" = "|";
    "(?k<comment>:(?|@patterns))";
}


pattern $CATEGORY => 'SQL',
        -config   => {-flavour => undef},
        -pattern  => \&sql,
        ;


sub sql {
    my %arg = @_;

    my @patterns;

    given ($arg {-flavour} // "") {
        when ([""]) {
            @patterns = eol "-{2,}";
        }

        when (["MySQL"]) {
            push @patterns => eol '#|-- ';
            push @patterns =>
                q {(?k<open_delimiter>:/[*])}                       .
                q {(?k<body>:[^"';*]*}          .
                     q {(?:(?:"[^"]*"|'[^']*'|[*](?!/))[^"';*]*)*)} .
                q {(?k<close_delimiter>:[*]/|;)};
        }

        #
        # http://download.oracle.com/docs/cd/B19306_01/server.102/
        #                                    b14200/sql_elements006.htm
        #
        # Note that there may be additional restrictions. Under certain
        # usage, /* */ comments may not contain a blank line. Under
        # other usage, -- comments extend to the end of the block instead
        # the end of the line, as newlines are ignored.
        #
        # These restrictions are ignored.
        #
        when (["PL/SQL"]) {
            push @patterns => eol     '--',
                              from_to '/*' => '*/'
            ;
        }

        default {
            # Known flavours may fall through to this, hence the 
            # test for @patterns.
            die "Unknown -flavour '$_'" unless @patterns;
        }
    }

    local $" = "|";
    "(?k<comment>:(?|@patterns))";
}


#
# http://oops.se/~urban/pit/intercal.ps
#
# Comments start with [PLEASE \s+][DO[\s*]](NOT|N'T), last till the
# end of the line, and cannot contain DO.
#
pattern $CATEGORY => "INTERCAL",
        -pattern  =>
           "(?k<comment>:"                                                   .
               "(?k<open_delimiter>:(?:PLEASE\\s+)?(?:DO\\s*)?(?:NOT|N'T))"  .
               '(?k<body>:[^D\n]*(?:D(?!O)[^D\n]*)*)'                        .
               '(?k<close_delimiter>:\n)'                                    .
           ")"
;

#
# Comments are one of the following pairs:
#     comment   comment
#     co        co
#     #         #
#     \x{A2}    \x{A2}
#
# as defined by "Report on the Algorithm Language ALGOL 68".
# http://www.fh-jena.de/~kleine/history/languages/Algol68-Report.pdf
#
# The a68toc compiler uses different delimiters:
#     COMMENT   COMMENT
#     CO        CO
#     #         #
#     {         }
# as found on http://www.algol68.org/.
# 
sub algol68 {
    my %arg = @_;
    my $flavour = $arg {-flavour} // "";
    my @patterns;
    push @patterns => from_to ('#', '#');

    given ($flavour) {
        when ([""]) {
            push @patterns => from_to ("\x{A2}", "\x{A2}"),

                '(?k<open_delimiter>:\bco\b)'                     .
                '(?k<body>:[^c]*(?:(?:\Bc|c(?!o\b))[^c]*)*)'      .
                '(?k<close_delimiter>:\bco\b)',

                '(?k<open_delimiter>:\bcomment\b)'                .
                '(?k<body>:[^c]*(?:(?:\Bc|c(?!omment\b))[^c]*)*)' .
                '(?k<close_delimiter>:\bcomment\b)',
            ;
        }
        when (["a68toc"]) {
            push @patterns => from_to ("{", "}"),

                '(?k<open_delimiter>:\bCO\b)'                     .
                '(?k<body>:[^C]*(?:(?:\BC|C(?!O\b))[^C]*)*)'      .
                '(?k<close_delimiter>:\bCO\b)',

                '(?k<open_delimiter>:\bCOMMENT\b)'                .
                '(?k<body>:[^C]*(?:(?:\BC|C(?!OMMENT\b))[^C]*)*)' .
                '(?k<close_delimiter>:\bCOMMENT\b)',
            ;
        }

        default {
            die "Unknown -flavour '$_'";
        }
    }

    local $" = "|";
    "(?k<comment>:(?|@patterns))";
}

pattern $CATEGORY => 'Algol 68',
        -config   => {-flavour => undef},
        -pattern  => \&algol68,
;


#
# See rules 91 and 92 of ISO 8879 (SGML).
# Charles F. Goldfarb: "The SGML Handbook".
# Oxford: Oxford University Press. 1990. ISBN 0-19-853737-9.
# Ch. 10.3, pp 390.
#

sub sgml {
    my %arg = @_;

    my $MDO = quotemeta $arg {-MDO};
    my $COM =           $arg {-COM};
    my $MDC = quotemeta $arg {-MDC};

    my $SPACE   = chr 32;   # Space
    my $RS      = chr 10;   # Record separator, aka \r
    my $RE      = chr 13;   # Record end, aka \n
    my $SEPCHAR = chr  9;   # Separator, aka \t

    my $WS      = "[$SPACE$RS$RE$SEPCHAR]";

    my $comment;
    if ($COM eq '--') {   # Optimize common case
        $comment = '[^-]*(?:-[^-]+)*';
    }
    else {
        my $h    = quotemeta substr $COM, 0, 1;
        my $t    = quotemeta substr $COM, 1;
        $comment = "[^$h]*(?:$h(?!$t)[^$h]*)*";
    }

    "(?k<comment>:"                                                        .
        "(?k<MDO>:$MDO)"                                                   .
            "(?k<body>:(?:(?k<COM>:$COM)(?k<comment>:$comment)$COM$WS*)*)" .
        "(?k<MDC>:$MDC)"                                                   .
    ")";
}

pattern $CATEGORY => 'HTML',
        -pattern  => sgml (-MDO => "<!", -MDC => ">", -COM => "--")
;
         

#
# http://www.w3.org/TR/2008/REC-xml-20081126/
#
pattern $CATEGORY => 'XML',
        -pattern  => do {
            my $chars = '\x{09}\x{0A}\x{0D}\x{20}-\x{2C}\x{2E}-\x{D7FF}' .
                        '\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}';
            "(?k<comment>:(?k<open_delimiter>:<!--)" .
            "(?k<body>:[$chars]*(?:-[$chars]+)*)(?k<close_delimiter>:-->))";
        }
;

1;

__END__

=head1 NAME

Regexp::Common510::Comment - Abstract

=head1 SYNOPSIS

 use Regexp::Common510 qw [Comment];

 my $html_comment = RE Comment  => 'HTML';
 /$htm_comment/ and say '$_ contains an HTML comment';

 my $delphi_comment = RE Comment  => 'Pascal'
                         -flavour => 'Delphi';

 my $perl_comment = RE Comment  => 'Perl',
                       -Keep    =>  1;

 /$perl_comment/ and say $+ {body}, " was commented out";

=head1 DESCRIPTION

This module is a C<< Regexp::Common510 >> plugin which will provide 
patterns for the C<< Regexp::Common510 >> framework.

All pattern can be retrieved using the C<< RE >> function -- for details
on C<< RE >>, see C<< Regexp::Common510 >>. For each pattern retrieval,
give C<< Comment >> as the first argument to C<< RE >>, with the actual
language as the second. A few languages have different implementations,
with different syntax for each implementation. In such cases, C<< RE >>
takes an option C<< -flavour >>, with the name of the implementation
as argument.

Unless documented otherwise below, giving C<< -Keep => 1 >> retrieves a
pattern that sets four named captures, in the following order:

=over 2

=item C<< comment >>

The entire comment, including any delimiters.

=item C<< open_delimiter >>

The token that starts the comment, for instance, C<< # >> in the case of
a Perl comment.

=item C<< body >>

The body of the comment; that is, the entire comment without its delimiters.

=item C<< close_delimiter >>

The token that ends the comment. For instance, a newline in the case of 
a Perl comment.

=back

A few things to consider:

=over 4

=item *

The patterns returned are just the patterns matching comments.  They are
B<< not >> suitable to parse languages - the patterns will happily find
comments where a compiler wouldn't (for instance, inside strings).

=item *

Many language formally define a more restrictive character set than
the Unicode, or even the ASCII character set. These restrictions are
generally ignored.

=back

=head2 The Patterns

Below, we will discuss the patterns for each of the languages. Most patterns
will start with a given token, and end with a given token. 

=over 2

=item B<< ABC >>

Comments start with C<< \ >>, and end with a newline.
See L<< http://homepages.cwi.nl/%7Esteven/abc/language.html >>.

=item B<< Ada >>

Comment start with C<< -- >> and end with a newline.
See L<< http://www.adaic.org/standards/05rm/html/RM-TTL.html >>.

=item B<< Advisor >>

I<< Advisor >> is used by the HP product I<< glance >>.

Comment start with either C<< # >> or C<< // >> and end with a newline.

=item B<< Advsys >>

I<< Advsys >> is a language used to write interactive fiction in.

Comments start with C<< ; >> and end with a newline.

=item B<< Alan >>

I<< Advsys >> is a language used to write interactive fiction in.

Comments start with C<< -- >> and end with a newline.

See L<< http://www.alanif.se >>

=item B<< Algol 60 >>

Comments start with C<< comment >> and end with C<< ; >>.

Note that I<< Algol 60 >> also allows to put 'comments' after the keyword
I<< end >>. These comments are not recognized by the pattern.

See L<< http://www.masswerk.at/algol60/report.htm >>.

=item B<< Algol 68 >>

Comments start with C<< # >>, E<0xA2> (a cent sign), C<< co >>
or C<< comment >>, and end with the same symbol. Note that I<< Algol 68 >> 
allows you to use localized keywords, but no option to do so is implemented
in this module.

See L<< http://www.fh-jena.de/~kleine/history/languages/Algol68-Report.pdf >>

=over 2

=item B<< -flavour => 'a68toc' >>

The I<< Algol 68 to C >> compiler recognizes somewhat different comments.
Comments start with C<< # >>, C<< CO >>, or C<< COMMENT >>, and end with
the same symbol, or start with C<< { >> and end with C<< } >>. A pattern
for this can be retrieved using

 my $comment = RE Comment => 'Algol 68', -flavour => 'a68toc';

=back

=item B<< ALPACA >>

I<< ALPACA >> is a language for programming cellular automata.

Comments start with C<< /* >> and end with C<< */ >>.

See L<< http://catseye.tc/projects/alpaca/doc/alpaca.html >>

=back

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
