package Mustachio::Response::View;

use base 'Mustachio::Response::Base';

sub new 
{
	my ( $class, $action ) = ( @_ );
    
    return bless {

    	
    	}, $class;
}

1;