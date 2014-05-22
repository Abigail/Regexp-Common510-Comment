package t::Common;

use 5.010;

use Test::More 0.88;
use Exporter ();

use strict;
use warnings;
no  warnings 'syntax';

our @ISA      = qw [Exporter];
our @EXPORT   = qw [@eol_tokens];

our @eol_tokens = (
  ['2Iota'                   =>  '//'],
   [ABC                      =>  '\\'],
   [Ada                      =>  '--'],
   [Advisor                  =>  '//'],
   [Advisor                  =>  '#'],
   [Advsys                   =>  ';'],
   [Alan                     =>  '--'],
   [awk                      =>  '#'],
   [BASIC                    =>  'REM'],
  [[BASIC => 'mvEnterprise'] =>  'REM'],
  [[BASIC => 'mvEnterprise'] =>  '*'],
  [[BASIC => 'mvEnterprise'] =>  '!'],
   [BCPL                     =>  '//'],
  ['beta-Juliet'             =>  '//'],
  ['C++'                     =>  '//'],
   [Cg                       =>  '//'],
   [CLU                      =>  '%'],
   [CQL                      =>  ';'],   
  ['Crystal Report'          =>  '//'],
   [ECMAScript               =>  '//'],
   [Eiffel                   =>  '--'],
   [Forth                    =>  '\\'],
   [Fortran                  =>  '!'],
   [FPL                      =>  '//'],
   [fvwm2                    =>  '#'],
   [ICON                     =>  '#'],
   [ILLGOL                   =>  'NB'],
   [J                        =>  'NB.'],
   [Java                     =>  '//'],
   [JavaScript               =>  '//'],
   [LaTeX                    =>  '%'], 
   [Lisp                     =>  ';'],
   [LOGO                     =>  ';'],
   [lua                      =>  '--'],
   [M                        =>  ';'],
   [m4                       =>  '#'],
   [MUMPS                    =>  ';'],
   [mutt                     =>  '#'],
   [Nickle                   =>  '#'],
   [PEARL                    =>  '!'],
   [Perl                     =>  '#'],
   [PHP                      =>  '#'],
   [PHP                      =>  '//'],
  ['PL/B'                    =>  '.'],
  ['PL/B'                    =>  ';'],
   [Portia                   =>  '//'],
   [Python                   =>  '#'],
  ['Q-BAL'                   =>  '`'],
   [QML                      =>  '#'],
   [R                        =>  '#'],
   [REBOL                    =>  ';'],
   [Ruby                     =>  '#'],
   [Scheme                   =>  ';'],
   [shell                    =>  '#'],
   [slrn                     =>  '%'],
   [SMITH                    =>  ';'],
   [Tcl                      =>  '#'], 
   [TeX                      =>  '%'],
   [troff                    =>  '\\"'],
   [Ubercode                 =>  '//'],
   [vi                       =>  '"'], 
   [zonefile                 =>  ';'],
  ['ZZT-OOP'                 =>  "'"],
);


__END__
