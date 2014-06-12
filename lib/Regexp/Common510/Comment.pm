package Regexp::Common510::Comment;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2009120201';

use Regexp::Common510;

my $CATEGORY = 'Comment';

my $NO_NL = $] >= 5.011001 ? '\N' : '[^\n]';

sub unique_name {
    state $counter = "aaaaaa";

    "__RC_Comment__" . $counter ++;
}

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
   '2Iota'           =>  '//',
    ABC              =>  '\\\\',  # That's a *single* backslash.
    Ada              =>  '--',
    Advisor          =>  '#|//',
    Advsys           =>  ';',
    Alan             =>  '--',
    awk              =>  '#',
    BCPL             =>  '//',
   'beta-Juliet'     =>  '//',
    Blue             =>  '--|==', # http://www.cs.kent.ac.uk/people/staff/
                                  # mik/blue/doc/spec-102.pdf
    CLU              =>  '%',
    CQL              =>  ';',
   'Crystal Report'  =>  '//',
    Eiffel           =>  '--',
    Erlang           =>  '%',
    Forth            =>  '\\\\',
    Fortran          =>  '!',
    fvwm2            =>  '#',
    ICON             =>  '#',
    ILLGOL           =>  'NB',
    J                =>  'NB[.]',
    LaTeX            =>  '%',
    Lisp             =>  ';',
    LLVM             =>  ';',   # http://llvm.org/docs/LangRef.html
    LOGO             =>  ';',
    lua              =>  '--',
    M                =>  ';',
    m4               =>  '#',
    make             =>  '#',
    Miranda          =>  '!!',  # http://miranda.org.uk/
    MUMPS            =>  ';',
    mutt             =>  '#',
   '.Net'            =>  "REM|['\x{2018}\x{2019}]",
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
    Tea              =>  '#',  # http://www.pdmfc.com/tea/doc/Presentations/
                               # Tutorial/html/01-Syntax005.html
    TeX              =>  '%',
    troff            =>  '\\\"',
    Ubercode         =>  '//',
    vi               =>  '"',
    Zeno             =>  '%',  # http://mysite.verizon.net/res148h4j/zenoguide/
                               # zeno_guide-004.html
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
    Karel            =>  '{',       '}',  # http://karel.sourceforge.net/doc
                                          # html_mono/karel.html
    LPC              =>  '/*',      '*/',
    Oberon           =>  '(*',      '*)',
   'PL/I'            =>  '/*',      '*/',
    Shelta           =>  ';',       ';',
    Smalltalk        =>  '"',       '"',
   '*W'              =>  '||',      '!!',
    Wolfram          =>  '(*',      '*)', # http://reference.wolfram.com/
                                          # language/guide/Syntax.html
);

my @eol_from_to = (
   'C++'             =>  '//',      '/*',  '*/',
    Cg               =>  '//',      '/*',  '*/',
    Chuck            =>  '//',      '/*',  '*/', # http://chuck.cs.princeton.
                                                 # edu/doc/language/
                                                 # overview.html
    ECMAScript       =>  '//',      '/*',  '*/',
    FPL              =>  '//',      '/*',  '*/',
    Go               =>  '//',      '/*',  '*/',
    Hack             =>  '#|//',    '/*',  '*/', # http://docs.hhvm.com/manual/
                                                 # en/hacklangref.php
    Java             =>  '//',      '/*',  '*/',
    JavaScript       =>  '//',      '/*',  '*/',
    Nickle           =>  '#',       '/*',  '*/',
    PEARL            =>  '!',       '/*',  '*/', # http://www.irt.uni-hannover.
                                                 # de/pearl/pub/report.pdf
    PHP              =>  '#|//',    '/*',  '*/',
    Pure             =>  '#!|//',   '/*',  '*/', # http://puredocs.bitbucket.org
                                                 # /pure.html
);


my @nested = (
    Boomerang        =>  '(*',  '*)',  # http://www.seas.upenn.edu/~harmony/
                                       # manual.pdf
   'Modula-2'        =>  '(*',  '*)',
   'Modula-3'        =>  '(*',  '*)',
    Rexx             =>  '/*',  '*/',  # http://www.kilowattsoftware.com/
                                       # tutorial/rexx
);


my @eol_nested = (
    Dylan            =>  '//',        '/*',  '*/',
    Haskell          =>  '-{2,}',     '{-',  '-}',
    Hugo             =>  '!(?!\\\\)', '!\\', '\\!',
    Scala            =>  '//',        '/*',  '*/', # http://www.scala-lang.org/
                                                   # files/archive/nightly/
                                                   # pdfs/ScalaReference.pdf
    SLIDE            =>  '#',         '(*',  '*)',
    Swift            =>  '//',        '/*',  '*/',
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
# Inline comments in C# end with a newline, carriage return, next line,
# paragraph separator or a line separator.
#
pattern $CATEGORY => 'C#',
        -pattern  => do {
            my   $newlines = '\x{000A}\x{000D}\x{0085}\x{2028}\x{2029}';
            my   @patterns;
            push @patterns => from_to '/*', '*/';
            push @patterns => "(?k<open_delimiter>://)" .
                              "(?k<body>:[^$newlines]*)" .
                              "(?k<close_delimiter>:[$newlines])";
            local $" = "|";
            "(?k<comment>:(?|@patterns))";
        },
;

#
# There are many implementations (flavours) of Pascal, with different
# syntaxes comments. We'll default to the ISO standard.
#
pattern $CATEGORY => 'Pascal',
        -config   => {-flavour => undef},
        -pattern  => \&pascal,
        ;

sub pascal {
    my %args = @_;

    my @patterns;
    my $flavour = $args {-flavour} // "";

    if ($flavour eq "" || $flavour eq "ISO") {
        #
        # http://www.pascal-central.com/docs/iso10206.txt
        #
        @patterns = "(?k<open_delimiter>:[{]|\Q(*\E)"         .
                    "(?k<body>:[^}*]*(?:[*](?![)])[^}*]*)*)"  .
                    "(?k<close_delimiter>:[}]|\Q*)\E)"
        ;
    }
    elsif ($flavour eq 'Alice') {
        #
        # http://www.templetons.com/brad/alice/language/
        #
        @patterns = "(?k<open_delimiter>:[{])"   .
                    "(?k<body>:[^}\n]*)"         .
                    "(?k<close_delimiter>:[}])"
        ;
    }
    elsif ($flavour eq "Delphi" ||
           $flavour eq "Free"   ||
           $flavour eq "GPC"    ||
           $flavour eq "Workshop") {
        #
        # http://info.borland.com/techpubs/delphi5/oplg/
        # http://www.freepascal.org/docs-html/ref/ref.html
        # http://docs.sun.com/db/doc/802-5762
        # http://www.gnu-pascal.de/gpc/
        #
        push @patterns => from_to ('{', '}'),
                          from_to ('(*', '*)');
        if ($flavour eq "Workshop") {
            push @patterns => from_to ('"',  '"'),
                              from_to ('/*', '*/');
        }
        else {
            push @patterns => eol '//';
        }
    }
    #
    # http://miller.emu.id.au/pmiller/ucsd-psystem-um/
    #                                 ucsd-pascal-ii.0-user-manual-facsimile.pdf
    # http://www.znode51.de/pcwworld/l103/user_0/jrtman.002
    # http://www.cpm.z80.de/manuals/mtplus.zip
    #
    elsif ($flavour eq "UCSD" ||
           $flavour eq "JRT"  ||
           $flavour eq "MT+") {   
        push @patterns => from_to ('{',  '}'),
                          from_to ('(*', '*)');
    }
    else {
        die "Unknown -flavour '$_'";
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
    my %args = @_;

    my @patterns;
    my $flavour = $args {-flavour} // "";

    if ($flavour eq "") {
        @patterns = eol "REM";
    }
    elsif ($flavour eq "mvEnterprise") {
        #
        # http://www.rainingdata.com/products/beta/docs/mve/50/
        #                                          ReferenceManual/Basic.pdf
        #
        @patterns = eol "[*!]|REM";
    }
    else {
        die "Unknown -flavour '$_'";
    }

    local $" = "|";
    "(?k<comment>:(?|@patterns))";
}


pattern $CATEGORY => 'SQL',
        -config   => {-flavour => undef},
        -pattern  => \&sql,
        ;


sub sql {
    my %args = @_;

    my @patterns;

    my $flavour = $args {-flavour} // "";

    if ($flavour eq "") {
        @patterns = eol "-{2,}";
    }
    elsif ($flavour eq "MySQL") {
        push @patterns => eol '#|-- ';
        push @patterns =>
            q {(?k<open_delimiter>:/[*])}                       .
            q {(?k<body>:[^"';*]*}          .
                 q {(?:(?:"[^"]*"|'[^']*'|[*](?!/))[^"';*]*)*)} .
            q {(?k<close_delimiter>:[*]/|;)};
    }
    elsif ($flavour eq "PL/SQL") {
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
        push @patterns => eol     '--',
                          from_to '/*' => '*/'
        ;
    }
    else {
        die "Unknown -flavour '$_'";
    }

    local $" = "|";
    "(?k<comment>:(?|@patterns))";
}


#
# http://www.cs.caltech.edu/courses/cs134/cs134b/book.pdf
#
# In OCaml, comments start with (* and end with *). They can be nested,
# and delimiters that appear as string literals are ignored.
#
pattern $CATEGORY => "OCaml",
        -pattern  => do {
            my $tag = unique_name;
            my $esc = '\\\\';
            my $str = # String literal
                qq {"[^'"$esc]*} .
                qq {(?:$esc(?:[nrtb $esc'"]|[0-9]{3}|x[0-9a-fA-F]{2})} .
                qq {[^'"$esc]*)*"};
            "(?<$tag>" .
                "(?k<comment>:"                                        .
                   "(?k<open_delimiter>:\Q(*\E)"                       .
                       qq {(?k<body>:[^(*"]*(?:(?:(?:$str)|}           .
                       qq {[(](?![*])|[*](?![)])|(?&$tag))[^(*"]*)*)}  .
                   "(?k<close_delimiter>:\Q*)\E)"                      .
            "))"
        };


#
# http://oops.se/~urban/pit/intercal.ps
#
# Comments start with [PLEASE \s+][DO[\s*]](NOT|N'T), last till the
# end of the line, and cannot contain DO.
#
my $AWS = "[\t\f\r ]";  # ASCII Whitespace; no newline.
pattern $CATEGORY => "INTERCAL",
        -pattern  =>
           "(?k<comment>:"                                                    .
               "(?k<open_delimiter>:(?:PLEASE$AWS+)?(?:DO$AWS*)?(?:NOT|N'T))" .
               '(?k<body>:[^D\n]*(?:D(?!O)[^D\n]*)*)'                         .
               '(?k<close_delimiter>:\n)'                                     .
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
    my %args = @_;
    my $flavour = $args {-flavour} // "";
    my @patterns;
    push @patterns => from_to ('#', '#');

    if ($flavour eq "") {
        push @patterns => from_to ("\x{A2}", "\x{A2}"),

            '(?k<open_delimiter>:\bco\b)'                     .
            '(?k<body>:[^c]*(?:(?:\Bc|c(?!o\b))[^c]*)*)'      .
            '(?k<close_delimiter>:\bco\b)',

            '(?k<open_delimiter>:\bcomment\b)'                .
            '(?k<body>:[^c]*(?:(?:\Bc|c(?!omment\b))[^c]*)*)' .
            '(?k<close_delimiter>:\bcomment\b)',
        ;
    }
    elsif ($flavour eq "a68toc") {
       push @patterns => from_to ("{", "}"),

           '(?k<open_delimiter>:\bCO\b)'                     .
           '(?k<body>:[^C]*(?:(?:\BC|C(?!O\b))[^C]*)*)'      .
           '(?k<close_delimiter>:\bCO\b)',

           '(?k<open_delimiter>:\bCOMMENT\b)'                .
           '(?k<body>:[^C]*(?:(?:\BC|C(?!OMMENT\b))[^C]*)*)' .
           '(?k<close_delimiter>:\bCOMMENT\b)',
       ;
    }
    else {
        die "Unknown -flavour '$_'";
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

    "(?k<comment>:"                                                       .
        "(?k<MDO>:$MDO)"                                                  .
            "(?k<bodies>:(?:(?k<COM>:$COM)(?k<body>:$comment)$COM$WS*)+)" .
        "(?k<MDC>:$MDC)"                                                  .
    ")";
}

pattern $CATEGORY => 'HTML',
        -config   => {-flavour => undef},
        -pattern  => sub {
            my %args    = @_;
            my $flavour = $args {-flavour} // "";

            if ($flavour eq "") {
                #
                # http://www.w3.org/html/wg/drafts/html/master/syntax.html
                #                                                    #comments
                #
                # Comments must start with the four character sequence
                # U+003C LESS-THAN SIGN, U+0021 EXCLAMATION MARK,
                # U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS (<!--). Following
                # this sequence, the comment may have text, with the additional
                # restriction that the text must not start with a single ">"
                # (U+003E) character, nor start with a U+002D HYPHEN-MINUS
                # character (-) followed by a ">" (U+003E) character, nor
                # contain two consecutive U+002D HYPHEN-MINUS characters (--),
                # nor end with a U+002D HYPHEN-MINUS character (-). Finally,
                # the comment must be ended by the three character sequence
                # U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS,
                # U+003E GREATER-THAN SIGN (-->).
                #
                return
                  "(?k<comment>:"                               .
                      "(?k<open_delimiter>:<!--)"               .
                          "(?k<body>:(?!-?>)[^-]*(?:-[^-]+)*)"  .
                      "(?k<close_delimiter>:-->)"               .
                  ")";
            }
            elsif (lc $flavour eq 'sgml') {
                return sgml (-MDO => "<!", -MDC => ">", -COM => "--")
            }
            else {
                die "Unknown -flavour '$flavour'\n";
            }
        }
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

#
# Brainfuck only as 8 commands, each written as a single character:
#    < > [ ] . , + -
# anything else is considered a comment.
#
# http://esolangs.org/wiki/Brainfuck
#
pattern $CATEGORY => 'Brainfuck',
        -pattern  => '(?k<comment>:(?k<body>:[^][<>.,+-]+))',
;


#
# D has three types of comments:
#     -  // till end of line, where end of line is LINE-FEED, CARRIAGE-RETURN,
#           CARRIAGE-RETURN LINE-FEED, LINE-SEPARATOR, or PARAGRAPH-SEPARATOR.
#     -  C-style, non nesting /* */ comment.
#     -  Nested /+ +/ comments.
#
# http://dlang.org/lex.html#Comment
#
pattern $CATEGORY => 'D',
        -pattern  => do {
            my @patterns;
            push @patterns => "(?k<open_delimiter>//)"                 .
                              "(?k<body>[^\x0A\x0D\x{2028}\x{2029}]*)" .
                              "(?k<close_delimiter>" .
                                  "(?>\x0A\x0D)|[\x0A\x0D\x{2028}\x{2029}])";
            push @patterns => from_to '/*', '*/';
            push @patterns => nested  '/+', '+/';
            local $" = "|";
            "(?k<comment>:(?|@patterns))";
        };


#
# http://partners.adobe.com/public/developer/en/ps/PLRM.pdf
#
# Comments start with a '%', and last till the first newline or formfeed
# character.
#
pattern $CATEGORY => 'PostScript',
        -pattern  => "(?k<comment>:(?k<open_delimiter>:%)" .
                     "(?k<body>:[^\n\x0C]*)" .
                     "(?k<close_delimiter>:[\n\x0C]))"
;

1;

__END__

=head1 NAME

Regexp::Common510::Comment - Abstract

=head1 SYNOPSIS

 use Regexp::Common510;

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

=item B<< 2Iota >>

I<< 2Iota >> is an esoteric event-based language;
a successor to I<< beta-Juliet >> and I<< Portia >>.

Comments start with C<< // >> and end with a newline.

See L<< http://catseye.tc/projects/2iota/ >>.

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

=item B<< awk >>

The standard text processing language found on Unix systems, part of 
I<< IEEE Std 1003.1-2004 >> (aka I<< POSIX >>) standard.

Comments start with C<< # >> and end with a newline. 

See L<< http://www.opengroup.org/onlinepubs/000095399/utilities/awk.html >>

=item B<< B >>

A general purpose language developed at Bell Labs as a stripped down version
of I<< BCPL >>. It was quickly replaced by I<< C >>.

Comments start with C<< /* >> and end with C<< */ >>.

See L<< http://cm.bell-labs.com/cm/cs/who/dmr/bintro.html >>

=item B<< BASIC >>

A well-known language, for many people the first language they programmed
in, which first appeared in the early 1960s. There are many implementations.

In the default implementation, comments start with C<< REM >> and end
with a newline.

=over 2 

=item B<< -flavour => 'mvEnterprise' >>

In this implementation, comments start with C<< REM >>, C<< * >> or C<< ! >>,
and end with a newline.

=back

=item B<< BCPL >>

I<< BCPL >> was the first "braces" language. Developed in the 1960s, it was
a predecessor of I<< B >>, and hence indirectly of I<< C >>.

Comments start with C<< // >> and end with a newline.

See L<< http://www.fh-jena.de/~kleine/history/languages/Richards-BCPL-ReferenceManual.pdf >>.

=item B<< beta-Juliet >>

I<< beta-Juliet >> is an esoteric event-based language.

Comments start with C<< // >> and end with a newline.

See L<< http://catseye.tc/projects/b_juliet/ >>.

=item B<< Befunge-98 >>

An esoteric language from the I<< Funge-98 >> family.

Comments start with C<< ; >> and end with C<< ; >>

See L<< http://catseye.tc/projects/fbbi/ >>

=item B<< BML >>

I<< BML >> or I<< Better Markup Language >> is an HTML templating language.

Comments start with C<< <?c_ >> and end with C<< c_?> >>.

See L<< http://www.livejournal.com/doc/server/bml.index.html >>

=item B<< Brainfuck >>

An esoteric, minimal language with just 8 characters.

Any character that isn't C<E<lt>>, C<E<gt>>, C<[>, C<]>, C<+>, C<->, C<.> 
or C<,> is considered a comment.

See L<< http://esolangs.org/wiki/Brainfuck >>.

If the C<< -Keep >> option is given, there will be only two captures:
C<< comment >> and C<< body >>, which will both match the entire comment.

=item B<< C >>

Comments start with C<< /* >> and end with C<< */ >>.

See: Brian W. Kernighan and Dennis M. Ritchie:
I<< The C Programming Language >>, B<< 1978 >>,
ISBN: 0-13-110163-3 (L<< http://www.worldcat.org/search?q=isbn%3A0131101633 >>.

=item B<< C++ >>

Comments either start with C<< /* >> and end with C<< */ >>, or start
with C<< // >> and end with a newline.

See: Bjarne Stroustrup: I<< The C++ Programming Language >>, B<< 1986 >>,
ISBN: 0-20-112078-X (L<< http://www.worldcat.org/search?q=isbn%3A020112078X >>.

=item B<< C# >>

I<< C# >> is a general purpose object oriented language designed by Microsoft.

Comments either start with C<< /* >> and end with C<< */ >>, or start
with C<< // >> and end with one of the following characters: a newline,
a carriage return, a next line (C<< U+0085 >>),
a line separator (C<< U+2028 >>), or a paragraph separator (C<< U+2029 >>).

See: ECMA Standard 334 (L<<
http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-334.pdf >>).

=item B<< Caml >>

Comments start with C<< (* >>, end with C<< *) >> and can be nested.
However, delimiters that appear as a string or character literal are
ignored.

See L<< http://www.cs.caltech.edu/courses/cs134/cs134b/book.pdf >>

=back

=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Common510-Comment.git >>.

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
