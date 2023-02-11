# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "SVG icon library manager for server-side rendering"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["examples"]

# Dependencies

requires "nim >= 1.6.10"

task dev, "dev":
  echo "\n✨ Compiling..." & "\n"
  exec "nim c --gc:arc --path:. --out:bin/iconim src/iconim.nim"