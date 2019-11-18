#!/usr/bin/perl
# $Id: env.pl,v 1.5 2013/04/08 03:23:52 michelc Exp $

if (! -e '/usr/local/share/perl5/cPanelUserConfig.pm') {
  use lib '/home/iggy/GITrepo/site/lib';
}  else {
  use cPanelUserConfig;
  binmode(STDOUT);
}

our $dbug = 1 if (exists $ENV{QUERY_STRING} && $ENV{QUERY_STRING} =~ /\&dbug=1/);
printf "\r\n<pre>" if $dbug;

use strict;

my $query = {};
# QUERY_STRING: fmt...
if (exists $ENV{QUERY_STRING}) {
   my @params = split /\&/,$ENV{QUERY_STRING};
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
      $query->{$p} = $v;
   }
}

my $tic= time;
# ---------------------------------------------------------
# CORS header
if (exists $ENV{HTTP_ORIGIN}) {
  printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
} else {
  print "Access-Control-Allow-Origin: *\n";
}
# ---------------------------------------------------------
if ($query->{fmt} eq 'json' || exists $query->{json}) {
#  print "Content-Type: text/json\r\n\r\n";
  print "Content-Type: application/json\r\n\r\n";
  use JSON qw(encode_json);
  my $env = encode_json( \%ENV ); 
  printf qq'{"tic":"%s","env":%s}',$tic,$env;

} elsif ($query->{fmt} eq 'yaml' || exists $query->{yaml}) {
  print "Content-Type: text/yaml\r\n\r\n";
  printf qq'--- # environment\ndate: "%s"\n',&hdate($tic);
  foreach (sort keys %ENV) {
    printf "%s: %s\n",$_,$ENV{$_};
  }
  print qq'...\n';

} else {
#print "Content-Type: text/plain\r\n\r\n";
print "Content-Type: text/html\r\n\r\n";
print '<meta http-equiv="refresh" content="127">';

print "<h3>Env:</h3>\n";
print '<pre>';
   printf " %s: %s\n",'tic',$tic;
foreach (sort keys %ENV) {
   printf " %s: %s\n",$_,$ENV{$_};
}
print '</pre>';


if ($dbug) {
print "<!--\n";
print " -->\n";
print "<h3>POST:</h3>\n";
local $/ = undef;
my $buf = <STDIN>;
printf "<pre>%s.</pre>\n",$buf;

print "<h3>Config:</h3>\n";
print '<pre>';
foreach (sort keys %::cPanelUserConfig) {
   printf " %s\n",$_;
}
print '</pre>';

print "<h3>System:</h3>\n";
print '<pre>';
#system "/home/micou/bin/ipfs id";
#system "ls -l /home/micou/bin/ipfs";
system "ping -c 4 -W 5 iphs.duckdns.org";
system "/home/micou/bin/ipfs diag sys";
print '</pre>';

}

}

exit $?;

# ---------------------------------------------------------
sub hdate { # return HTTP date (RFC-1123, RFC-2822) 
  my $DoW = [qw( Sun Mon Tue Wed Thu Fri Sat )];
  my $MoY = [qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )];
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($_[0]))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  # Mon, 01 Jan 2010 00:00:00 GMT

  my $date = sprintf '%3s, %02d %3s %04u %02u:%02u:%02u GMT',
             $DoW->[$wday],$mday,$MoY->[$mon],$yr4, $hour,$min,$sec;
  return $date;
}
# --------------------------------------------------------- 
1;
