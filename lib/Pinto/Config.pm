package Pinto::Config;

# ABSTRACT: Internal configuration for a Pinto repository

use Moose;

use MooseX::Configuration;
use MooseX::Types::Moose qw(Str Bool Int);
use MooseX::Types::Log::Dispatch qw(LogLevel);
use MooseX::Aliases;

use URI;

use Pinto::Types qw(Dir File);
use Pinto::Util qw(current_username );

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------
# Moose attributes

has root       => (
    is         => 'ro',
    isa        => Dir,
    alias      => 'root_dir',
    required   => 1,
    coerce     => 1,
);


has username  => (
    is        => 'ro',
    isa       => Str,
    default   => sub { return current_username },
);


has authors_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('authors') },
    lazy      => 1,
);


has authors_id_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->authors_dir->subdir('id') },
    lazy      => 1,
);


has modules_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('modules') },
    lazy      => 1,
);


has mailrc_file => (
    is        => 'ro',
    isa       => File,
    init_arg  => undef,
    default   => sub { return $_[0]->authors_dir->file('01mailrc.txt.gz') },
    lazy      => 1,
);


has modlist_file => (
    is        => 'ro',
    isa       => File,
    init_arg  => undef,
    default   => sub { return $_[0]->modules_dir->file('03modlist.data.gz') },
    lazy      => 1,
);


has db_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('db') },
    lazy      => 1,
);


has db_file => (
    is        => 'ro',
    isa       => File,
    init_arg  => undef,
    default   => sub { return $_[0]->db_dir->file('pinto.db') },
    lazy      => 1,
);


has sql_dir   => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->db_dir->subdir('sql') },
);


has vcs_dir   => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('vcs') },
);


has pinto_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->root_dir->subdir('.pinto') },
    lazy      => 1,
);


has config_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('config') },
    lazy      => 1,
);


has cache_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('cache') },
    lazy      => 1,
);


has log_dir => (
    is        => 'ro',
    isa       => Dir,
    init_arg  => undef,
    default   => sub { return $_[0]->pinto_dir->subdir('log') },
    lazy      => 1,
);


has log_file => (
    is        => 'ro',
    isa       => File,
    init_arg  => undef,
    default   => sub { return $_[0]->log_dir->file('pinto.log') },
    lazy      => 1,
);


has log_level  => (
    is         => 'ro',
    isa        => Str,
    key        => 'log_level',
    default    => 'notice',
    documentation => 'Minimum logging level for the log file',
);


has devel => (
    is        => 'ro',
    isa       => Bool,
    key       => 'devel',
    default   => 0,
    documentation => 'Include development releases in the index',
);


has sources  => (
    is        => 'ro',
    isa       => Str,
    key       => 'sources',
    default   => 'http://cpan.perl.org',
    documentation => 'URLs of repositories for foreign distributions (space delimited)',
);


has sources_list => (
    isa        => 'ArrayRef[URI]',
    builder    => '_build_sources_list',
    traits     => ['Array'],
    handles    => { sources_list => 'elements' },
    init_arg   => undef,
    lazy       => 1,
);


has basename => (
    is        => 'ro',
    isa       => Str,
    init_arg  => undef,
    default   => 'pinto.ini',
);

#------------------------------------------------------------------------------
# Builders

sub _build_config_file {
    my ($self) = @_;

    my $config_file = $self->config_dir->file( $self->basename() );

    return -e $config_file ? $config_file : ();
}

#------------------------------------------------------------------------------

sub _build_sources_list {
    my ($self) = @_;

    my @sources = split m{ \s+ }mx, $self->sources();
    my @source_urls = map { URI->new($_) } @sources;

    return \@source_urls;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;

__END__

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=cut
