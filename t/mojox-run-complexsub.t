#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

if ($^O =~ m/(?:linux|freebsd|netbsd|aix|macos|darwin)/i) {
	plan tests => 5;
} else {
	plan skip_all => 'This test requires supported UNIX platform.';
}

use bytes;
use MojoX::Run;

my $e = MojoX::Run->new();
$e->log_level('info');

my $res_ok = 0;
my $res_ex = undef;
my $a = 0;

sub exit_cb {
	my ($pid, $res, $ex) = @_;
	
	if (defined $res && ref($res) eq 'ARRAY') {
		$res_ok = 1;
		$res_ex = undef;
		$a = $res->[0]->{a};
	} else {
		$res_ok = 0;
		$res_ex = $ex;
	}
	
	# stop the loop...
	$e->ioloop()->stop();
}

my $pid = $e->spawn_sub(
	sub {
		sleep(1 + int(rand(2)));
		return {
			a => rand(5) + 1,
			b => rand(10) + 1,
		}
	},
	exit_cb => \&exit_cb,
);

ok $pid > 0, "Spawn succeeded";

# start loop
$e->ioloop()->start();

ok $a > 1 && $a < 6, 'Complex sub data ok';
ok ! defined $res_ex, 'Exception is undefined.';
diag "\$a: $a\n\n Exception: $res_ex\n\n" if defined $res_ex;

$pid = $e->spawn_sub(
	sub {
		die "Exception simulation.";
	},
	exit_cb => \&exit_cb,
);

ok $pid > 0, "Spawn2 succeeded";

# start loop
$e->ioloop()->start();

ok defined $res_ex, 'Exception cought.';
