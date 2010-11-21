package MojoX::Handle;

use strict;
use warnings;

use IO::Handle;

use vars qw(@ISA);
@ISA = qw(IO::Handle);

=head1 NAME

MojoX::Handle - IO::Handle wrapper with some socket-like behaviour.

=head1 SYNOPSIS

 my $h = MojoX::Handle->new();

=head1 OBJECT CONSTRUCTOR

=head2 new ()

Constructor accepts the same arguments as L<IO::Handle> constructor. See L<IO::Handle>
for details.

=head1 METHODS

This class inherits all methods from L<IO::Handle>.

=head2 connected ()

This method is just wrapper around B<opened()> method found in L<IO::Handle>.

=cut
sub connected {
	my ($self) = @_;
	return $self->opened();
}

=head1 SEE ALSO

L<IO::Handle>

=head1 AUTHOR

"Brane F. Gracnar", C<< <"bfg at frost.ath.cx"> >>

=head1 LICENSE AND COPYRIGHT

Copyright 201, Brane F. Gracnar.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
1;