import asyncnet, os, tcp_server, protocol, clientstore, crpl,
       asyncdispatch, strutils

var modi: string

proc authentication(client: Client, msg: Message): void =
  let login = clientstore.compare_password(msg.cip, msg.session)
  var return_msg: string
  if login:
    let (status, action) =
      clientstore.set_netAddr(msg.cip, msg.session, client.netAddr)
    echo("Status ", status & ", Action " & action)
      # TODO: session cookie
    return_msg = create_message("authorization", client.netAddr, "xyz")
    discard client.socket.send(return_msg)
    case action 
    of "do update":
      echo("Update client", client.netAddr)
  else:
      echo("Authentication fail, close client socket ")
      if asyncnet.isClosed(client.socket) == false:
        return_msg = create_message("error", client.netAddr, "-")
        discard client.socket.send(return_msg)
#        asyncnet.close(client.socket)
      

proc check_user(params: varargs[string]): string =
  let cp = clientstore.compare_password(params[0], params[1])
  if cp:
    result = "Password is right"
  else:
    result = "Password ist false"

proc add_user(params: varargs[string]): string =
  echo(clientstore.set_netAddr(params[0], params[1], "test"))
    
proc init_connection(params: varargs[string]): string =
  echo("init server on port ", params[0])
  subscribe("authentication", authentication)
  tcp_server.start_server(parseInt(params[0]))
  echo "init_connection"
    
proc defaults(): void =
  clientstore.init("dev.db")
  param_to_callback("--c", "(Bind) --c port=4004", init_connection)
  param_to_callback("--l", "(Login) --l user=admin password=test", check_user)
  param_to_callback("--a", "(Add user) --a user=admin password=test", add_user)
  
proc start*(params: string): void =
  modi = "cmd"
  echo("Mod ", modi)
  defaults()
  start_cmd(params)
  runForever()
  
proc start*(): void =
  modi = "repl"
  echo("Mod ", modi)
  defaults()  
  start_repl()
    
var cmd_params: string
if paramCount() > 0:
  var params: seq[TaintedString]
  params = commandLineParams()
  cmd_params = strutils.join(params, " ")
  start(cmd_params)
else:
  start()
