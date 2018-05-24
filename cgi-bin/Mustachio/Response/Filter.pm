package Mustachio::Response::Filter;

use base 'Mustachio::Response::Base';

sub new 
{
	my ( $class, $action ) = ( @_ );
    
    $self->{ 'filter' } = $args->{ 'filter' };

    $self->{ 'model' } = decode_json( $args->{ 'filter' }->slurp_utf8() );

    $self->{ 'header' } = { %{ $self->{ 'header' } }, -content_type => 'application/json' };

    return $self;
}

1;