package Mustachio::Response::404;

use Path::Tiny 'path';

sub new
{
    my ( $class, $action ) = ( @_ );

    return bless {
    	query => $action->query,
    	header => { -status => 404, -content_type => 'text/html', -charset => 'UTF-8' }
    	base => path( $ENV{'DOCUMENT_ROOT'} ),
    	parameters => $action->parameters,
    	location => '404.html'
    }, $class;
}

sub generate
{

    my ( $self ) = ( shift );

    my ( $model, $base, $location ) = ( $self->{ 'model' }, $self->{ 'base' }, 'view.html' );

    require Mustache::Simple;

    my $response = $self->{ 'query' }->header( $self->{ 'header' } );

    my $template = new Mustache::Simple( path => $base->stringify, extension => 'html' );

    $response .= $template->render( $location, $model );

    return $response;
}

1;
