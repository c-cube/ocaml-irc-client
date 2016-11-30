
module type PARAMS = sig
  val config : Tls.Config.client
end

module Make(P : PARAMS) : sig
  module Io : Irc_transport.IO
    with type 'a t = 'a Lwt.t
     and type inet_addr = string
     and type file_descr = Tls_lwt.Unix.t

  include module type of Irc_client.Make(Io)
end

