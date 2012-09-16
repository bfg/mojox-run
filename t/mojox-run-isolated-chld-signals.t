#!/usr/bin/env perl
use common::sense;
use lib qw(./lib);

use MojoX::Run;
use Test::More tests => 2;

my $run = MojoX::Run->new;
            
my $exit_logpath   = 't/exitcb.log';
my $cmd_logpath    = 't/cmd.log';
my $parent_logpath = 't/parent.log';
foreach ($exit_logpath, $cmd_logpath, $parent_logpath) {
    unlink $_ if -e $_;
}

use Mojo::Log;
$| = 1;

my @elements = qw(aa bb cc);

my $parentlog = Mojo::Log->new(path => $parent_logpath, level => 'debug');
$parentlog->debug("[parent] has pid $$");

my $i = 0;
for my $elem (@elements) {
    my $pid = $run->spawn(
        cmd => sub {
            sleep 1;
            my $cmdlog = Mojo::Log->new(path => $cmd_logpath, level => 'debug');
            $cmdlog->debug("[child] $$, elem $elem");
            exit 0;
        },
        exit_cb => sub {
            my ($pid, $res) = @_;
            my $exitlog = Mojo::Log->new(path => $exit_logpath, level => 'debug');
            $exitlog->debug("[whoknows] me $$, pid $pid, on $elem");
        },
    );
    $parentlog->debug("[parent] child has $pid for elem $elem");
}
$run->ioloop->start;

use Mojo::Util qw/slurp/;
my @exits= split "\n", slurp($exit_logpath);
my @cmds = split "\n", slurp($cmd_logpath);

is(scalar @cmds, 3, 'cmd called thrice in child processes.');
is(scalar @exits, 3, 'exit_cb called thrice in parent process.');
