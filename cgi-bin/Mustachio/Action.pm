package Mustachio::Action;

use Path::Tiny 'path';
use Data::Dump 'dump';
use URI::Query;
use Switch;

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
            my $directory = $self->{ 'base' } = $base->child( @dir );

            foreach my $type ( keys %$types )
            {
                if ( $directory->child( $types->{ $type } )->exists() )
                {
                    $self->{ $type } = $directory->child( $types->{ $type } );
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

        # lets see if the are looking to filter a JSON file
        if ( $parameters[ 0 ] =~ m/\.json/ )
        {
            my $file = shift( @parameters );

            my $filter = $self->{ 'base' }->child( $file );

            # lets remove the view since this is a filter command
            $self->{ 'view' } = undef;

            if ( $filter->is_file() )
            {
                $self->{ 'filter' } = $filter;
            }

        }
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

sub resolve
{
    my ( $self, $query ) = @_;

    my ( $base, $path, $filter, @parameters ) = ( path( $ENV{ 'DOCUMENT_ROOT' } ), undef, undef, () );

    my @fragments = grep { $_ ne '' } split /\//, $query->path_info;

    for ( my $i = $#fragments; $i > -1; $i-- )
    {
        my @dir = @fragments[ 0 .. $i ];

        if ( $base->child( @dir )->is_dir() )
        {
            $path = $base->child( @dir );

            # Lets check to  see if this a filter or not
            $filter = $self->filter( $path, reverse @parameters );

            last;
        }

        push @parameters, $fragments[ $i ];
    }
    
    # lets reverse the order to ensure it makes sense for parsing later
    @parameters = reverse @parameters if ( @parameters );

    return { path => $path, filter => $filter, parameters => [ @parameters ] }
}


sub filter
{
    my ( $self, $path, @parameters ) = @_;

    if ( @parameters && substr($parameters[0], -5) eq '.json' )
    {
        if ( $path->child( $parameters[0] )->is_file() )
        {
            return $path->child( $parameters[0] )
        }
    }
}


sub parameters
{
    my ( $self, $path, $filters ) = @_;


}

sub is
{
    my ( $self, $type ) = @_;

    switch ( $type )
    {
        case 'view'   { return ( $self->{ 'view' }  && !$self->{ 'filter' } ) ? 1 : 0 }
        case 'filter' { return ( $self->{ 'filter' } )   ? 1 : 0 }
        case 'redirect' { return ( $self->{ 'redirect' } ) ? 1 : 0 }
        else { return 0 }
    }
}

sub parameters
{
    my ( $self ) = @_;
    return $self->{ 'parameters' };
}

sub json
{
    my ( $self ) = @_;
    return $self->{ 'json' };
}

sub sql
{
    my ( $self ) = @_;
    return $self->{ 'sql' };
}

sub view
{
    my ( $self ) = @_;
    return $self->{ 'view' };
}

sub base
{
    my ( $self ) = @_;
    return $self->{ 'base' };
}

sub filter
{
    my ( $self ) = @_;
    return $self->{ 'filter' };
}

sub guard
{
    my ( $self ) = @_;
    return $self->{ 'guard' };
}

sub query
{
    my ( $self ) = @_;
    return $self->{ 'query' };
}

1;
