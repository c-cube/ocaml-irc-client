
module type PARAMS = sig
  val config : Tls.Config.client
end

module Io(P : PARAMS) = struct
  type 'a t = 'a Lwt.t
  let (>>=) = Lwt.bind
  let return = Lwt.return

  type file_descr = Tls_lwt.Unix.t

  type inet_addr = string

  let open_socket addr port =
    Tls_lwt.Unix.connect P.config (addr, port)

  let close_socket = Tls_lwt.Unix.close

  let read = Tls_lwt.Unix.read_bytes
  let write = Tls_lwt.Unix.write_bytes

  let gethostbyname name =
    Lwt.catch
      (fun () ->
         Lwt_unix.gethostbyname name >>= fun entry ->
         let addrs = Array.to_list entry.Unix.h_addr_list in
         Lwt.return addrs
      ) (function
      | Not_found -> Lwt.return_nil
      | e -> Lwt.fail e
    )

  let iter = Lwt_list.iter_s
end

module Make(P : PARAMS) = struct
  module Io = Io(P)

  include Irc_client.Make(Io)
end
