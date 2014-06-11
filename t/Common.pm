package t::Common;

use 5.010;

use Test::More 0.88;
use Exporter ();

use strict;
use warnings;
no  warnings 'syntax';

our @ISA      = qw [Exporter];
our @EXPORT   = qw [%eol_tokens %from_to_tokens
                    @eol_nested @eol @nested @from_to];


our %eol_tokens =  (
   '2Iota'                   =>  ['//'],
    ABC                      =>  ['\\'],
    Ada                      =>  ['--'],
    Advisor                  =>  ['//', '#'],
    Advsys                   =>  [';'],
    Alan                     =>  ['--'],
    awk                      =>  ['#'],
    BASIC                    =>  ['REM'],
   'BASIC,mvEnterprise'      =>  ['REM', '*', '!'],
    BCPL                     =>  ['//'],
   'beta-Juliet'             =>  ['//'],
    Blue                     =>  ['--', '=='],
   'C++'                     =>  ['//'],
    Cg                       =>  ['//'],
    CLU                      =>  ['%'],
    CQL                      =>  [';'],   
   'Crystal Report'          =>  ['//'],
    Dylan                    =>  ['//'],
    ECMAScript               =>  ['//'],
    Eiffel                   =>  ['--'],
    Erlang                   =>  ['%'],
    Forth                    =>  ['\\'],
    Fortran                  =>  ['!'],
    FPL                      =>  ['//'],
    fvwm2                    =>  ['#'],
    Go                       =>  ['//'],
    Hack                     =>  ['#', '//'],
    Haskell                  =>  ['--', '---', '--------------'],
    Hugo                     =>  ['!'],
    ICON                     =>  ['#'],
    ILLGOL                   =>  ['NB'],
    J                        =>  ['NB.'],
    Java                     =>  ['//'],
    JavaScript               =>  ['//'],
    LaTeX                    =>  ['%'], 
    Lisp                     =>  [';'],
    LLVM                     =>  [';'],   
    LOGO                     =>  [';'],
    lua                      =>  ['--'],
    M                        =>  [';'],
    m4                       =>  ['#'],
    make                     =>  ['#'],
    Miranda                  =>  ['!!'],
    MUMPS                    =>  [';'],
    mutt                     =>  ['#'],
   '.Net'                    =>  ["REM", "'", "\x{2018}", "\x{2019}"],
    Nickle                   =>  ['#'],
    PEARL                    =>  ['!'],
    Perl                     =>  ['#'],
    PHP                      =>  ['#', '//'],
   'PL/B'                    =>  ['.', ';'],
    Portia                   =>  ['//'],
    Pure                     =>  ['#!', '//'],
    Python                   =>  ['#'],
   'Q-BAL'                   =>  ['`'],
    QML                      =>  ['#'],
    R                        =>  ['#'],
    REBOL                    =>  [';'],
    Ruby                     =>  ['#'],
    Scala                    =>  ['//'],
    Scheme                   =>  [';'],
    shell                    =>  ['#'],
    SLIDE                    =>  ['#'],
    slrn                     =>  ['%'],
    SMITH                    =>  [';'],
    Swift                    =>  ['//'],
    Tcl                      =>  ['#'], 
    Tea                      =>  ['#'],
    TeX                      =>  ['%'],
    troff                    =>  ['\\"'],
    Ubercode                 =>  ['//'],
    vi                       =>  ['"'], 
    Zeno                     =>  ['%'], 
    zonefile                 =>  [';'],
   'ZZT-OOP'                 =>  ["'"],
);

our %from_to_tokens = (
    ALPACA                   => [['/*',      '*/']],
    B                        => [['/*',      '*/']],
   'Befunge-98'              => [[';',       ';']],
    BML                      => [['<?_c',    '_c?>']],
    Boomerang                => [['(*',      '*)']],
    C                        => [['/*',      '*/']],
   'C--'                     => [['/*',      '*/']],
   'C++'                     => [['/*',      '*/']],
   'C#'                      => [['/*',      '*/'],
                                 ['//',      "\x{000A}"],
                                 ['//',      "\x{000D}"],
                                 ['//',      "\x{0085}"],
                                 ['//',      "\x{2028}"],
                                 ['//',      "\x{2029}"]],
    Cg                       => [['/*',      '*/']],
    Dylan                    => [['/*',      '*/']],
    ECMAScript               => [['/*',      '*/']],
    False                    => [['!{',      '}!']],
    FPL                      => [['/*',      '*/']],
   'Funge-98'                => [[';',       ';']],
    Go                       => [['/*',      '*/']],
    Hack                     => [['/*',      '*/']],
    Haifu                    => [[',',       ',']],
    Haskell                  => [['{-',      '-}']],
    Hugo                     => [['!\\',     '\\!']],
    Java                     => [['/*',      '*/']],
    JavaScript               => [['/*',      '*/']],
    Karel                    => [['{',       '}']],
    LPC                      => [['/*',      '*/']],
   'Modula-2'                => [['(*',      '*)']],
   'Modula-3'                => [['(*',      '*)']],
    Nickle                   => [['/*',      '*/']],
    Oberon                   => [['(*',      '*)']],
    PEARL                    => [['/*',      '*/']],
    PHP                      => [['/*',      '*/']],
   'PL/I'                    => [['/*',      '*/']],
    PostScript               => [['%',       "\n"],
                                 ['%',       "\x0C"]],
    Pure                     => [['/*',      '*/']],
    Rexx                     => [['/*',      '*/']],
    Scala                    => [['/*',      '*/']],
    Shelta                   => [[';',       ';']],
    Smalltalk                => [['"',       '"']],
    SLIDE                    => [['(*',      '*)']],
    Swift                    => [['/*',      '*/']],
   '*W'                      => [['||',      '!!']],
    Wolfram                  => [['(*',      '*)']],
    XML                      => [['<!--',    '-->']],
);



our @eol_nested = (qw [Dylan Haskell Hugo Scala SLIDE Swift]);
our @nested     =  qw [Boomerang Modula-2 Modula-3 Rexx];
our @eol = do {
    my %filter = map {$_ => 1} @eol_nested;
    grep {!$filter {$_}} keys %eol_tokens;
};
our @from_to = do {
    my %filter = map {$_ => 1} @eol_nested, @nested;
    grep {!$filter {$_}} keys %from_to_tokens;
};


__END__
