package HowdyPlack::Base;

use Moose;
use namespace::autoclean;
use List::MoreUtils qw/any/;
use Scalar::Util qw/refaddr/;

our %ATTRIBUTES;
our @allowed = qw/Action Private/;

sub MODIFY_CODE_ATTRIBUTES {
	my ( $package, $code, @attributes ) = @_;
	my @bad;

	foreach my $attr (@attributes) {
		if ( any { $attr eq $_ } @allowed ) {
			$ATTRIBUTES{ refaddr $code} = \@attributes;
		}
		else {
			push @bad, $attr;
		}
	}

	return @bad;
}

sub FETCH_CODE_ATTRIBUTES {
	my ( $package, $code ) = @_;

	my $attrs = $ATTRIBUTES{ refaddr $code};
	return defined $attrs ? @$attrs : ();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
