#!/usr/bin/env perl

use Test::More tests => 4;

use bytes;
use MojoX::Run;

my $e = MojoX::Run->new();

my $cb_exit_status = undef;
my $cb_pid = undef;
my $cb_res_len = 0;

my $pid = $e->spawn(
    cmd => "ls",
    exit_cb => sub {
      my ($pid, $res) = @_;
      $cb_pid = $pid;
      $cb_exit_status = $res->{exit_status};
      #print "Got result: ", Dumper($res), "\n";
      #print "\n\nRESULT for pid $pid\n\n";
      
      $cb_res_len = length($res->{stdout});

      # stop ioloop
      $e->ioloop->stop();
    },
);

print "PID: $pid; error: ", $e->error(), "\n";

ok $pid > 0, "Spawn succeeded";

# start loop
$e->ioloop()->start();

ok $pid == $cb_pid, "cb_pid == pid";
ok $cb_exit_status  == 0, "cb_exit_status == 0";
ok $cb_res_len > 0, "result len > 0: $cb_res_len";