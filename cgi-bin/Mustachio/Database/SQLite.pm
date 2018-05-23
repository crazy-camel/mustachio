package Mustachio::Database::SQLite;

use DBI;

sub new
{
	my ( $class, $args ) = ( shift, {@_} );
	my $realpath = $args->{'base'}->child( $args->{'path'} )->absolute->stringify;
	return bless {
		db => DBI->connect("dbi:SQLite:dbname=".$realpath, "" ,"" )
	}, $class
}

1;