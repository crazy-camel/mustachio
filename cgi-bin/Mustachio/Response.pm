package Mustachio::Response;

use Path::Tiny 'path';
use JSON::Tiny qw(decode_json encode_json);
use List::MoreUtils 'natatime';
use Scalar::Util;

use Data::Dump 'dump';

# ===============================================
# TODO: Clean up this creation of this object
# ===============================================
sub new
{
    my ( $class, $args ) = ( shift, { @_ } );
    
    $args->{'header'} = { -charset => 'UTF-8' };
    $args->{'model'} = decode_json $args->{'model'}->slurp_utf8();

    return bless $args, $class;
}

sub set404
{
    my ( $self, $parameters ) = @_;

    $self->{ 'header' } = { %{ $self->{ 'header' } }, -status => 404 };
    $self->{ 'model' } = { data => $parameters };
    $self->{ 'location' } = '/404.html';

    return $self;
}

sub headers
{
    my ( $self ) = ( @_ );
    return $self->{ 'query' }->header( $self->{ 'header' } );
}

sub redirect
{
    my ( $self, $location ) = ( @_ );
    
    $self->{ 'redirect' } = $location;
    return $self;
}

sub template
{
    require Mustache::Simple;

    my ( $self ) = @_ ;
    
    # check to make sure location is set
    $self->{'location'} //= 'view.html';

    my $base = ( index( $self->{'location'}, '/' ) == 0  )
                    ? path( $ENV{ 'DOCUMENT_ROOT'} )
                    : $self->{'base'};

    return new Mustache::Simple( path => $base->stringify, extension => 'html' );
}

sub filter
{

    my ( $self, $args ) = ( shift, { @_ } );
    
    $self->{ 'filter' } = $args->{ 'filter' };

    $self->{ 'model' } = decode_json( $args->{ 'filter' }->slurp_utf8() );

    $self->{ 'header' } = { %{ $self->{ 'header' } }, -content_type => 'application/json' };

    return $self;
}

sub refine
{
    my ( $self, $args ) = ( shift, { @_ } );

    my $it = natatime 2, @{ $args->{'parameters'} };

    while ( my ( $key, $value ) = $it->() )
    {

        if ( Scalar::Util::looks_like_number( $key ) && $self->{ 'model' }->{ 'meta' }->{ 'pagination' } )
        {
            my @array = @{ $self->{ 'model' }->{ 'data' } };
            my ( $start, $end ) = ( $key, $key + $self->{ 'model' }->{ 'meta' }->{ 'pagination' } );
            $self->{ 'model' }->{ 'data' } = ( $end < scalar( @array ) ) ? [ splice( @array, $start, $end ) ] : [ splice( @array, $start ) ];
            next;
        }

        $self->{ 'model' }->{ 'data' }
            = ( $value ne '*' )
            ? [ grep { index( lc( $_->{ $key } ), $value ) > -1 } @{ $self->{ 'model' }->{ 'data' } } ]
            : [ grep { exists $_->{ $key } } @{ $self->{ 'model' }->{ 'data' } } ];
    }

    return $self;
}

sub generate
{
    my ( $self ) = ( @_ );

    print dump ($self);

    if ( $self->{ 'redirect' } )
    {
        return $self->{ 'query' }->redirect( $self->{ 'redirect' } );
    }

    if ( $self->{ 'filter' } )
    {

        return join( "", 
            $self->headers(),
            encode_json $self->{ 'model' }
            );
    }

    return join( "", 
        $self->headers(),
        $self->template()->render( $self->{ 'location' }, $self->{ 'model' } )
        );
}

1;
