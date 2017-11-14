use v6.c;
unit class Timer::Breakable:ver<0.0.1>:auth<Simon Proctor "simon.proctor@gmail.com">;

=begin pod

=head1 NAME

Timer::Breakable - blah blah blah

=head1 SYNOPSIS

use Timer::Breakable;

=head1 DESCRIPTION

Timer::Breakable is ...

=end pod

has Promise $.flag = Promise.new();
has atomicint $!lock = 0;

method start( $time where * > 0, &block ) {
    Promise.in($time).then(
        {
            try {
                self!kill( block => &block );
                CATCH {
                    when X::Promise::Vowed { say "Should not happen in timer" }
                }
            }
        }
    );
    return self;
}

method !kill( :$keep = True, :&block = sub{} ) {
    return if atomic-fetch-inc( $!lock ) > 0;
    $keep ?? $!flag.keep( &block() ) !! $!flag.break();
}

method stop() {
    self!kill( keep => False );
}


method result() {
    return $.flag.result;
}

method status() {
    return $.flag.status;
}

=begin pod

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
