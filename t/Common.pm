package t::Common;

use 5.010;

use Test::More 0.88;
use Exporter ();

use strict;
use warnings;
no  warnings 'syntax';

our @ISA      = qw [Exporter];
our @EXPORT   = qw [%eol_tokens %from_to_tokens
                    @eol_nested @eol];


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
   'C++'                     =>  ['//'],
    Cg                       =>  ['//'],
    CLU                      =>  ['%'],
    CQL                      =>  [';'],   
   'Crystal Report'          =>  ['//'],
    Dylan                    =>  ['//'],
    ECMAScript               =>  ['//'],
    Eiffel                   =>  ['--'],
    Forth                    =>  ['\\'],
    Fortran                  =>  ['!'],
    FPL                      =>  ['//'],
    fvwm2                    =>  ['#'],
    Haskell                  =>  ['--', '---', '--------------'],
    Hugo                     =>  ['!'],
    ICON                     =>  ['#'],
    ILLGOL                   =>  ['NB'],
    J                        =>  ['NB.'],
    Java                     =>  ['//'],
    JavaScript               =>  ['//'],
    LaTeX                    =>  ['%'], 
    Lisp                     =>  [';'],
    LOGO                     =>  [';'],
    lua                      =>  ['--'],
    M                        =>  [';'],
    m4                       =>  ['#'],
    MUMPS                    =>  [';'],
    mutt                     =>  ['#'],
    Nickle                   =>  ['#'],
    PEARL                    =>  ['!'],
    Perl                     =>  ['#'],
    PHP                      =>  ['#', '//'],
   'PL/B'                    =>  ['.', ';'],
    Portia                   =>  ['//'],
    Python                   =>  ['#'],
   'Q-BAL'                   =>  ['`'],
    QML                      =>  ['#'],
    R                        =>  ['#'],
    REBOL                    =>  [';'],
    Ruby                     =>  ['#'],
    Scheme                   =>  [';'],
    shell                    =>  ['#'],
    SLIDE                    =>  ['#'],
    slrn                     =>  ['%'],
    SMITH                    =>  [';'],
    Tcl                      =>  ['#'], 
    TeX                      =>  ['%'],
    troff                    =>  ['\\"'],
    Ubercode                 =>  ['//'],
    vi                       =>  ['"'], 
    zonefile                 =>  [';'],
   'ZZT-OOP'                 =>  ["'"],
);

our %from_to_tokens = (
    Dylan                    => [['/*',  '*/']],
    Haskell                  => [['{-',  '-}']],
    Hugo                     => [['!\\', '\\!']],
    SLIDE                    => [['(*',  '*)']],
);



our @eol_nested = (qw [Dylan Haskell Hugo SLIDE]);
our @eol = do {
    my %filter = map {$_ => 1} @eol_nested;
    grep {!$filter {$_}} keys %eol_tokens;
};


__END__
