#!/usr/bin/env perl
use common::sense;
use lib qw(./lib);

use MojoX::Run;
use Test::More tests => 1;

my $run = MojoX::Run->new;

my $arr = [qw(aa bb cc dd ee ff gg)];

my ($ex_stats, $i);
for my $elem (@$arr) {
    my $pid = $run->spawn(
        cmd => sub {
            print $elem;
            exit 0;
        },
        exit_cb => sub {
            my ($pid, $res) = @_;

            $ex_stats .= $res->{exit_signal};
            $run->ioloop->stop if ++$i == scalar @$arr;
        },
    );
}
$run->ioloop->start;

is( $ex_stats, "0000000", "exit childs with code_ref" );
