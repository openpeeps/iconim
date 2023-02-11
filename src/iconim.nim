# SVG Icon library manager for server-side rendering
# 
# (c) 2023 George Lemon | MIT License
#          Made by Humans from OpenPeep
#          https://github.com/openpeep/iconim

import std/[os, tables, strtabs, xmltree, xmlparser]
from std/strutils import indent, join

type
  SVGIcon = ref object
    path, code: string
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
    stripAttrs: seq[string]
      ## Optionally, pass attr names that need to be removed (e.g. `class`)

var Icon* = IconManager() # a singleton of IconManager

proc init*(source: string, default = "", stripAttrs = newSeq[string]()) =
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
    Icon.stripAttrs = stripAttrs

proc readSvgCode(svg: SVGIcon, stripAttrs: seq[string]) =
  var xml = parseXml readFile(svg.path)
  xml.attrs.del("xmlns") # useless tag
  for attr in stripAttrs:
    xml.attrs.del(attr)
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
        result.readSvgCode(Icon.stripAttrs)
  else:
    if Icon.libs.hasKey(libName):
      if Icon.libs[libName].icons.hasKey(key):
        result = Icon.libs[libName].icons[key]
        if result.code.len == 0:
          result.readSvgCode(Icon.stripAttrs)

proc size*(svg: SVGIcon, s: int): SVGIcon =
  svg.attrs["width"] = $s
  svg.attrs["height"] = $s
  result = svg

proc `$`*(svg: SVGIcon): string =
  if svg != nil:
    result = "<svg" & indent(svg.getAttrs(), 1) & ">" & svg.code & "</svg>"
  else: discard