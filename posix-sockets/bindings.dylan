Module: posix-sockets
Synopsis: Bindings for the raw functions.
Author: Bruce Mitchener, Jr.
Copyright: See LICENSE file in this distribution.

define method get-address-info
    (hostname :: <string>,
     servname :: <string>,
     #key family-hint :: <integer> = $PF-UNSPEC,
          socktype-hint :: <integer> = 0,
          protocol-hint :: <integer> = 0,
          flags-hint :: <integer> = 0)
 => (addresses :: limited(<vector>, of: <address-info>))
  with-stack-structure(hints :: <addrinfo*>)
    clear-memory!(hints, size-of(<addrinfo>));
    addrinfo$ai-family(hints) := family-hint;
    addrinfo$ai-socktype(hints) := socktype-hint;
    addrinfo$ai-protocol(hints) := protocol-hint;
    addrinfo$ai-flags(hints) := flags-hint;
    with-stack-structure(addr-list :: <addrinfo**>)
      let res = %getaddrinfo(hostname, servname, hints, addr-list);
      let addresses = make(<stretchy-vector>);
      let addr :: <addrinfo*> = addr-list[0];
      while (~null-pointer?(addr))
        let family = addrinfo$ai-family(addr);
        let raw-sockaddr = addrinfo$ai-addr(addr);
        let addrlen = addrinfo$ai-addrlen(addr);
        let sockaddr = make(<socket-address>,
                            family: family,
                            sockaddr: raw-sockaddr,
                            sockaddr-length: addrlen);
        add!(addresses, make(<address-info>,
                             family: family,
                             socket-type: addrinfo$ai-socktype(addr),
                             protocol: addrinfo$ai-protocol(addr),
                             socket-address: sockaddr,
                             canonical-name: addrinfo$ai-canonname(addr)));
        addr := addrinfo$ai-next(addr);
      end while;
      %freeaddrinfo(addr-list[0]);
      as(limited(<vector>, of: <address-info>), addresses)
    end with-stack-structure
  end with-stack-structure
end method get-address-info;

define inline method socket
    (address-family :: <integer>, socket-type :: <integer>,
     protocol :: <integer>)
 => (socket :: <socket>)
  let fd = %socket(address-family, socket-type, protocol);
  make(<socket>, file-descriptor: fd)
end method socket;

define inline method bind
    (socket :: <socket>, sockaddr :: <socket-address>)
 => (socket :: <bound-socket>, res)
  let fd = socket.socket-file-descriptor;
  let res = %bind(fd,
                  sockaddr.socket-address-sockaddr,
                  sockaddr.socket-address-sockaddr-length);
  let socket = make(<bound-socket>, file-descriptor: fd);
  values(socket, res)
end method bind;

define inline method listen
    (socket :: <bound-socket>, backlog :: <integer>)
 => (socket :: <server-socket>, res)
  let fd = socket.socket-file-descriptor;
  let res = %listen(fd, backlog);
  let socket = make(<server-socket>, file-descriptor: fd);
  values(socket, res)
end method listen;

define inline method accept
    (server-socket :: <server-socket>)
 => (socket :: <socket>)
  with-stack-structure(their-address :: <sockaddr-storage*>)
    clear-memory!(their-address, size-of(<sockaddr-storage>));
    with-stack-structure(address-size :: <C-int*>)
      pointer-value(address-size) := size-of(<sockaddr-storage>);
      let fd = %accept(server-socket.socket-file-descriptor,
                       their-address,
                       address-size);
      make(<socket>, file-descriptor: fd)
    end with-stack-structure
  end with-stack-structure
end method accept;

define inline method connect
    (socket :: <socket>, address-info :: <address-info>)
 => (res)
  let sockaddr = address-info.address-info-socket-address;
  %connect(socket.socket-file-descriptor,
           sockaddr.socket-address-sockaddr,
           sockaddr.socket-address-sockaddr-length)
end method connect;

define inline method close-socket (socket :: <socket>) => ()
  %close(socket.socket-file-descriptor);
end method close-socket;

define inline method shutdown-socket
    (socket :: <socket>, how :: <integer>)
 => ()
  %shutdown(socket.socket-file-descriptor, how);
end method shutdown-socket;

