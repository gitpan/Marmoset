=pod

=encoding utf-8

=head1 PURPOSE

Can Marmoset classes inherit?

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test::Modern;

{
	package Local::Foo;
	use Marmoset;
	
	has foo => (
		is        => 'ro',
		pack      => 'Z6',
		default   => sub { "Hello" },
	);
}

{
	package Local::Bar;
	use Marmoset;
	
	has bar => (
		is        => 'rw',
		pack      => 'Z6',
		default   => sub { "World" },
	);
}

{
	package Local::FooBar;
	use Marmoset;
	extends qw( Local::Foo Local::Bar );
}

# Test all this twice. Need to test that Local::FooBar->new works both
# *before* and *after* Local::Foo and Local::Bar objects have been
# constructed.
#
for (0 .. 1)
{
	
	object_ok(
		sub { Local::FooBar->new },
		'$foobar',
		isa   => [qw/ Local::FooBar Local::Foo Local::Bar Marmoset::Object /],
		does  => [qw/ Local::FooBar Local::Foo Local::Bar Marmoset::Object /],
		can   => [qw/ new foo bar /],
		more  => sub {
			my $foobar = shift;
			is($foobar->foo, 'Hello', '$foobar->foo');
			is($foobar->bar, 'World', '$foobar->bar');
			is_string($$foobar, "Hello\0World\0", '$$foobar');
		},
	);
	
	object_ok(
		sub { Local::Foo->new },
		'$foo',
		isa   => [qw/ Local::Foo Marmoset::Object /],
		does  => [qw/ Local::Foo Marmoset::Object /],
		can   => [qw/ new foo /],
		more  => sub {
			my $foo = shift;
			is($foo->foo, 'Hello', '$foo->foo');
			is_string($$foo, "Hello\0", '$$foo');
		},
	);
	
	object_ok(
		sub { Local::Bar->new },
		'$bar',
		isa   => [qw/ Local::Bar Marmoset::Object /],
		does  => [qw/ Local::Bar Marmoset::Object /],
		can   => [qw/ new bar /],
		more  => sub {
			my $bar = shift;
			is($bar->bar, 'World', '$bar->bar');
			$bar->bar('There');
			is($bar->bar, 'There', '$bar->bar (write access)');
			is_string($$bar, "There\0", '$$bar');
		},
	);
	
}

done_testing;

