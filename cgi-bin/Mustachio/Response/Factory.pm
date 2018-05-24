package Mustachio::Response::Factory;

use Mustachio::Response::404;
use Mustachio::Response::Fitler;
use Mustachio::Response::View;
use Mustachio::Response::Redirect;

sub create 
{
	my ( $class, $args ) = ( shift, { @_ } );

	if ( $args->{'action'}->is( 'view' ) )
	{
		return Mustachio::Response::View->new( $args );
	}

	if ( $args->{'action'}->is( 'filter' ) )
	{
		return Mustachio::Response::Filter->new( $args );
	}

	if ( $args->{'action'}->is( 'redirect') )
	{
		return Mustachio::Response::Redirect->new( $args );
	}
    
    return Mustachio::Response::404->new( $args );

}

1;