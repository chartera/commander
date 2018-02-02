srcDir        = "src"
binDir        = "bin"
bin           = @["commander"]

# Package

version       = "0.1.0"
author        = "Nael Tasmim"
description   = "Execute commandline scripts"
license       = "BSD"

# Dependencies

requires "nim >= 0.17.2", "tcp_server", "clientstore", "protocol"

