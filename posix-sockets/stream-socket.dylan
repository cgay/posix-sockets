Module: posix-sockets
Synopsis: Auto-generated bindings for the POSIX sockets API.
Author: Bruce Mitchener, Jr.
Copyright: See LICENSE file in this distribution.

define class <unbound-socket> (<socket>)
end;

define method print-object
    (s :: <unbound-socket>, stream :: <stream>)
 => ()
  write-element(stream, '{');
  write(stream, s.object-class.debug-name);
  write-element(stream, '}');
end method print-object;

define sealed domain make(singleton(<unbound-socket>));
define sealed domain initialize(<unbound-socket>);

define class <bound-socket> (<socket>)
  constant slot socket-address :: <socket-address>,
    required-init-keyword: socket-address:;
end;

define sealed domain make(singleton(<bound-socket>));
define sealed domain initialize(<bound-socket>);

define method print-object
    (s :: <bound-socket>, stream :: <stream>)
 => ()
  write-element(stream, '{');
  write(stream, s.object-class.debug-name);
  write(stream, as(<string>, s.socket-address));
  write-element(stream, '}');
end method print-object;

define class <server-socket> (<socket>)
  constant slot socket-address :: <socket-address>,
    required-init-keyword: socket-address:;
  keyword linger? = #f;
end;

define sealed domain initialize(<server-socket>);

define method make
    (class == <server-socket>,
     #rest init-keywords,
     #key linger? :: false-or(<integer>) = #f,
     #all-keys)
 => (socket :: <socket>)
  let s = apply(next-method, class, init-keywords);
  set-socket-option/linger(s, linger?);
  s
end method make;

define method print-object
    (s :: <server-socket>, stream :: <stream>)
 => ()
  write-element(stream, '{');
  write(stream, s.object-class.debug-name);
  write(stream, as(<string>, s.socket-address));
  write-element(stream, '}');
end method print-object;

define class <ready-socket> (<socket>)
  constant slot local-socket-address :: <socket-address>,
    required-init-keyword: local-socket-address:;
  constant slot peer-socket-address :: <socket-address>,
    required-init-keyword: peer-socket-address:;
end;

define sealed domain make(singleton(<ready-socket>));
define sealed domain initialize(<ready-socket>);

define method print-object
    (s :: <ready-socket>, stream :: <stream>)
 => ()
  write-element(stream, '{');
  write(stream, s.object-class.debug-name);
  write(stream, " local: ");
  write(stream, as(<string>, s.local-socket-address));
  write(stream, " peer: ");
  write(stream, as(<string>, s.peer-socket-address));
  write-element(stream, '}');
end method print-object;
