#!perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use lib 't/lib';
use Pinto::Tester;
use Pinto::Tester::Util qw(make_dist_archive);

#------------------------------------------------------------------------------
{

    my $t       = Pinto::Tester->new;
    my $archive = make_dist_archive('Dist-1=PkgA~1');

    # Put archive on the master stack.
    $t->run_ok( Add => { archives => $archive, author => 'JOHN', no_recurse => 1 } );
    $t->registration_ok('JOHN/Dist-1/PkgA~1/master');

    # Rename the master stack.
    $t->run_ok( Rename => { from_stack => 'master', to_stack => 'dev' } );
    $t->registration_ok('JOHN/Dist-1/PkgA~1/dev');

    # Can't use old stack name any more
    throws_ok { $t->pinto->repo->get_stack('master') } qr/does not exist/;

    # Renamed stack should still be the default
    $t->stack_is_default_ok( 'dev', 'after renaming stack' );

    # Check the filesystem
    $t->path_not_exists_ok( [qw(stacks master)] );
    $t->path_exists_ok(     [qw(stacks dev modules 02packages.details.txt.gz)] );
    $t->path_exists_ok(     [qw(stacks dev modules 03modlist.data.gz)] );
    $t->path_exists_ok(     [qw(stacks dev authors 01mailrc.txt.gz)] );

}

#------------------------------------------------------------------------------

{

    my $t = Pinto::Tester->new;
    $t->run_throws_ok(
        Rename => { from_stack => 'bogus', to_stack => 'whatever' },
        qr/does not exist/, 'Cannot rename non-existant stack'
    );

    $t->run_ok( New => { stack => 'existing' } );

    $t->run_throws_ok(
        Rename => { from_stack => 'master', to_stack => 'existing' },
        qr/already exists/, 'Cannot rename to stack that already exists'
    );

    $t->run_throws_ok(
        Rename => { from_stack => 'existing', to_stack => 'existing' },
        qr/already exists/, 'Cannot rename to stack to itself'
    );

}

#------------------------------------------------------------------------------

done_testing;
