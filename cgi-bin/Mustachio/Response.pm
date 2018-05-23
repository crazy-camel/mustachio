package Mustachio::Response;

use Path::Tiny 'path';
use Data::Dump 'dump';

sub new
{
    my ( $class, $args ) = ( shift, { @_ } );
    return bless {
        query  => $args->{ 'query' },
        base   => path( $ENV{ 'DOCUMENT_ROOT' } ),
        header => { -charset => 'UTF-8' },
    }, $class;
}

sub set404
{
    my ( $self, $parameters ) = ( @_ );

    $self->{ 'header' } = { %{ $self->{ 'header' } }, -status => 404 };
    $self->{ 'model' } = { data => $parameters };
    $self->{ 'location' } = '404.html';

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

    return new Mustache::Simple( path => $ENV{ 'DOCUMENT_ROOT' }, extension => 'html' );
}

sub generate
{
    my ( $self ) = ( @_ );

    if ( $self->{ 'redirect' } )
    {
        return $self->{ 'query' }->redirect( $self->{ 'redirect' } );
    }

    return join( "",
    	$self->headers(),
    	$self->template()->render( $self->{ 'location' }, $self->{ 'model' } )
    );
}

1;
