# Icon library manager for server-side rendering
# 
# (c) 2023 George Lemon | MIT License
#          Made by Humans from OpenPeep
#          https://github.com/openpeep/iconim

import std/[os, tables, strtabs, xmltree, xmlparser]
from std/strutils import indent, join

type
  SVGIcon = ref object
    path, head, code: string
    attrs: XmlAttributes

  Library = ref object
    name: string
    icons: iconsTable
    attrs: XmlAttributes

  libsTable = TableRef[string, Library]
  iconsTable = TableRef[string, SVGIcon]

  IconManager {.acyclic.} = ref object
    source: string
      ## Path on disk to look for .svg icons
    default: string
      ## Default library name
    libs: libsTable
      ## A Table containing scanned libraries
    stripTags: seq[string]
      ## Optionally, pass tag names that need to be removed (e.g. `class`)

var Icon* = IconManager() # a singleton of IconManager

proc init*(source: string, default = "", stripTags = newSeq[string]()) =
  var i = 0
  let src = absolutePath(normalizedPath(source))
  Icon.source = src
  Icon.libs = libsTable()
  for libDir in walkDir(src):
    let (dir, libName, ext) = libDir.path.splitFile()
    var lib = Library(name: libName, icons: iconsTable())
    if default.len != 0 and libName == default or i == 0:
      Icon.default = libName
    inc i
    for iconPath in walkFiles(libDir.path / "*.svg"):
      let iconName = extractFileName(iconPath)[0 .. ^5]
      lib.icons[iconName] = SVGIcon(path: iconPath)
    Icon.libs[libName] = lib
    Icon.stripTags = stripTags

proc readSvgCode(svg: SVGIcon, stripTags: seq[string]) =
  var xml = parseXml readFile(svg.path)
  xml.attrs.del("xmlns") # useless tag
  for tag in stripTags:
    xml.attrs.del(tag)
  svg.attrs = xml.attrs
  for xNode in xml:
    add svg.code, xNode

proc getAttrs(svg: SVGIcon): string =
  var attrs: seq[string]
  for k, v in svg.attrs:
    attrs.add(k & "=\"" & v & "\"")
  result = attrs.join(" ")

proc icon*(key: string, libName = ""): SVGIcon =
  if libName.len == 0:
    let d = Icon.default
    if Icon.libs[d].icons.hasKey(key):
      result = Icon.libs[d].icons[key]
      if result.code.len == 0:
        result.readSvgCode(Icon.stripTags)
  else:
    if Icon.libs.hasKey(libName):
      if Icon.libs[libName].icons.hasKey(key):
        result = Icon.libs[libName].icons[key]

proc size*(svg: SVGIcon, s: int): SVGIcon =
  svg.attrs["width"] = $s
  svg.attrs["height"] = $s
  result = svg

proc `$`*(svg: SVGIcon): string =
  result = "<svg" & indent(svg.getAttrs(), 1) & ">" & svg.code & "</svg>"

when isMainModule:
  init("../examples", "feather", stripTags = @["class"])
  echo icon("alert-triangle")
  echo icon("activity")
  echo icon("alert-triangle")