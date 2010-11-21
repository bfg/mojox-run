#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;

use bytes;
use MojoX::Run;
use Data::Dumper;

my $e = MojoX::Run->new();

my $cb_exit_status = undef;
my $cb_pid = undef;
my $cb_res = undef;

my $data_sent = 'abcdefgh';

my $pid = $e->spawn(
	cmd => sub {
		print $data_sent;
		exit 12;
	},
	exit_cb => sub {
		my ($pid, $res) = @_;
		$cb_pid         = $pid;
		$cb_exit_status = $res->{exit_status};

		#print "Got result: ", Dumper($res), "\n";
		#print "\n\nRESULT for pid $pid\n\n";

		$cb_res = $res->{stdout};

		# stop ioloop
		$e->ioloop->stop();
	},
);

print "PID: $pid; error: ", $e->error(), "\n";

ok $pid > 0, "Spawn succeeded";

# start loop
$e->ioloop()->start();

ok $pid == $cb_pid, "cb_pid == pid";
ok $cb_exit_status == 12, "cb_exit_status == 12";
ok length($cb_res) > 0, "result len > 0: length(cb_res)";
ok length($data_sent) == length($cb_res), "sent len == received_len";
ok $data_sent eq $cb_res, "data_sent eq cb_res";

