package Mustachio::Action;

use Path::Tiny 'path';
use URI::Query;

my $types = {
    view  => 'view.html',
    sql   => 'data.sql',
    json  => 'data.json',
    guard => '.guard'
};

sub new
{
    my ( $class, $args, $self, @parameters ) = ( shift, { @_ }, {}, () );

    my $base = path( $ENV{ 'DOCUMENT_ROOT' } );

    my @fragments = grep { $_ ne '' } split /\//, $args->{ 'path_info' };

    for ( my $i = $#fragments; $i > -1; $i-- )
    {
        my @dir = @fragments[ 0 .. $i ];

        if ( $base->child( @dir )->is_dir() )
        {
            my $dir = $base->child( @dir );

            foreach my $type ( keys %$types )
            {
                if ( $dir->child( $types->{ $type } )->exists() )
                {
                    $self->{ $type } = $dir->child( $types->{ $type } );
                }
            }

            last;
        }

        push @parameters, $fragments[ $i ];
    }

    # --- Parameters ----
    if ( @parameters )
    {
        @parameters = reverse @parameters;
        push @parameters, '*' if ( @parameters % 2 != 0 );
    }

    if ( $args->{ 'query_string' } )
    {
        my $qq     = URI::Query->new( $args->{ 'query_string' } );
        my %params = $qq->hash;

        @parameters = ( @parameters, %params );
    }
    # --- /Parameters ----

    $self->{ 'parameters' } = [ @parameters ];

    return bless $self, $class;
}

sub has
{
    my ( $self, $type ) = ( @_ );

    if ( $type eq 'view' )
    {
        return ( $self->{ 'view' } ) ? 1 : 0;
    }

    if ( $type eq 'json' )
    {
        return ( $self->{ 'json' } ) ? 1 : 0;
    }

    if ( $type eq 'sql' )
    {
        return ( $self->{ 'sql' } ) ? 1 : 0;
    }

    if ( $type eq 'parameters' )
    {
        return ( keys %{ $self->{ 'parameters' } } ) ? 1 : 0;
    }

    return return 0;
}

sub parameters
{
    my ( $self ) = @_;
    return $self->{'parameters'};
}

sub json
{
    my ( $self ) = @_;
    return $self->{'json'};
}

sub sql
{
    my ( $self ) = @_;
    return $self->{'sql'};
}

sub view
{
    my ( $self ) = @_;
    return $self->{'view'};
}

sub guard
{
    my ( $self ) = @_;
    return $self->{'guard'};
}

1;
