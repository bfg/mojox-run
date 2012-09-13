#!/usr/bin/env perl
use common::sense;
use lib qw(./lib);

use MojoX::Run;
use Test::More tests => 2;

my $run = MojoX::Run->new;
            
my $logpath = 't/exitcb.log';
unlink $logpath if -e $logpath;
my $cmd_logpath = 't/cmd.log';
unlink $cmd_logpath if -e $cmd_logpath;
use Mojo::Log;



my @elements = qw(aa bb cc);

my $i = 0;
for my $elem (@elements) {
    my $pid = $run->spawn(
        cmd => sub {
            my $cmdlog = Mojo::Log->new(path => $cmd_logpath, level => 'info');
            $cmdlog->info("$$, elem $elem");
            exit 0;
        },
        exit_cb => sub {
            my ($pid, $res) = @_;
            my $exitlog = Mojo::Log->new(path => $logpath, level => 'info');
            $exitlog->info("pid $$, on $elem");
            
            #why?
            #$run->ioloop->stop if ++$i == scalar @elements;
        },
    );
}
$run->ioloop->start;

use Mojo::Util qw/slurp/;
my @exits= split "\n", slurp($logpath);
my @cmds = split "\n", slurp($cmd_logpath);

is(3, @cmds, 'cmd called thrice in child processes.');
is(3, @exits, 'exit_cb called thrice in parent process.');





