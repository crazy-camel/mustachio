package Mustachio::Action;

use Path::Tiny 'path';
use Data::Dump 'dump';
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

1;
