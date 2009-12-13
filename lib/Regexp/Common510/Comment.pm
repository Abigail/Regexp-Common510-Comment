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

#
# There are many implementations (flavours) of Pascal, with different
# syntaxes comments. We'll default to the ISO standard.
#
pattern  Comment => 'Pascal',
        -config  => {-flavour => undef},
        -pattern => \&pascal,
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
pattern  Comment => 'BASIC',
        -config  => {-flavour => undef},
        -pattern => \&basic,
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


pattern  Comment => 'SQL',
        -config  => {-flavour => undef},
        -pattern => \&sql,
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
pattern Comment  => "INTERCAL",
        -pattern =>
           "(?k<comment>:"                                                   .
               "(?k<open_delimiter>:(?:PLEASE\\s+)?(?:DO\\s*)?(?:NOT|N'T))"  .
               '(?k<body>:[^D\n]*(?:D(?!O)[^D\n]*)*)'                        .
               '(?k<close_delimiter>:\n)'                                    .
           ")"
;

#
# http://westein.arb-phys.uni-dortmund.de/~wb/a68s.txt
# http://www.nunan.fsnet.co.uk/algol68/pame.pdf
# http://www.algol68.org/
#
# Comments are one of the following pairs:
#     COMMENT   COMMENT
#     CO        CO
#     #         #
#     {         }
#
# Case is not clear. http://www.nunan.fsnet.co.uk/algol68/pame.pdf uses
# all capitals, http://westein.arb-phys.uni-dortmund.de/~wb/a68s.txt lower
# case (but is offline). The latter also claims CO and COMMENT should be
# words, and doesn't mention { }.
#
# For now, I will use capitals, and allow { }. This one may have flavours
# in the future.
# 
pattern Comment  => 'Algol 68',
        -pattern => do {
            my @patterns;
            push @patterns => from_to ('#',     '#'),
                              from_to ('{',     '}');
            push @patterns =>
                '(?k<open_delimiter>:\bCO\b)'                     .
                '(?k<body>:[^C]*(?:(?:\BC|C(?!O\b))[^C]*)*)'      .
                '(?k<close_delimiter>:\bCO\b)',

                '(?k<open_delimiter>:\bCOMMENT\b)'                .
                '(?k<body>:[^C]*(?:(?:\BC|C(?!OMMENT\b))[^C]*)*)' .
                '(?k<close_delimiter>:\bCOMMENT\b)',
            ;
            local $" = "|";
            "(?k<comment>:(?|@patterns))";
        }
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

    my $first;
    if ($COM eq '--') {   # Optimize common case
        $first = '[^-]*(?:-[^-]+)*';
    }
    else {
        my $h = quotemeta substr $COM, 0, 1;
        my $t = quotemeta substr $COM, 1;
        $first = "[^$h]*(?:$h(?!$t)[^$h]*)*";
    }

    "(?k<comment>:" .
        "(?k<MDO>:$MDO)" .
            "(?k<body>:(?:(?k<COM>:$COM)(?k<first>:$first)$COM\\s*)*)" .
        "(?k<MDC>:$MDC)" .
    ")";
}

pattern Comment  => 'HTML',
        -pattern => sgml (-MDO => "<!", -MDC => ">", -COM => "--")
;
         

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
