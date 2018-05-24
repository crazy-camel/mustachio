package Mustachio::Response::Base;

use JSON::Tiny 'encode_json';

sub generate
{
    my ( $self ) = ( @_ );

    my $response = $self->{ 'query' }->header( $self->{ 'header' } );

    if ( __PACKAGE__ eq 'Mustachio::Response::View' )
    {
    	$response .= $self->template()->render( $self->{ 'location' }, $self->{ 'model' } )
    }

    if (  __PACKAGE__ eq 'Mustachio::Response::Filter' )
    {
    	$response .= encode_json $self->{ 'model' };
    }

    return $response;
}

1;