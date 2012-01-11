use strict;
use warnings;
use lib qw(t/lib);
use MyModel;
use Test::Most;
use DateTime;

my $model   = MyModel->testing;
my $twitter = $model->index('twitter')->type('user');
ok( $twitter->put(
        {   nickname => $_,
            name     => 'mo',
        }
    ),
    'Put mo ok'
) for ( 1 .. 10 );

ok( $twitter->put(
        {   name     => 'plu',
            nickname => $_,
        }
    ),
    'Put plu ok'
) for ( 11 .. 15 );

$twitter->index->refresh;

is( $twitter->count, 15, '15 created' );

ok( $twitter->filter( { term => { name => 'mo' } } )->delete, 'run delete' );

is( $twitter->count, 0, 'none remain' );

is( $twitter->index->type('user')->count, 5, '5 remain' );

done_testing;