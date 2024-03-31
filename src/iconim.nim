# SVG Icon library manager for server-side rendering
# 
# (c) 2023 George Lemon | MIT License
#          Made by Humans from OpenPeep
#          https://github.com/openpeep/iconim

import std/[os, tables, strtabs, xmltree, xmlparser, json]
from std/strutils import indent, join

export XmlAttributes

type
  SVGIcon = ref object
    path, code: string
    attrs*: XmlAttributes

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

var Icon*: IconManager # a singleton of IconManager

proc initSingleton(source, default: string) =
  Icon = IconManager()
  var i = 0
  let src = source
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

proc init*(icon: var IconManager, source: string, default = "", stripAttrs = newSeq[string]()) =
  ## Initialize a singleton of `IconManager`
  initSingleton(source, default)
  Icon.stripAttrs = stripAttrs

proc init*(icon: var IconManager, source: string, default = "", stripAttrs: JsonNode = %*[]) =
  ## Initialize a singleton of `IconManager`. This is a special proc compatible
  ## with [Tim Engine](https://github.com/openpeep/tim)
  initSingleton(source, default)
  for attr in stripAttrs:
    Icon.stripAttrs.add(attr.getStr)

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
  ## Change `width` and `height` attributes
  svg.attrs["width"] = $s
  svg.attrs["height"] = $s
  result = svg

proc strokeWidth*(svg: SVGIcon, i: int): SVGIcon =
  ## Change `stroke-width` attribute value
  svg.attrs["stroke-width"] = $i
  result = svg

proc `$`*(svg: SVGIcon): string =
  if svg != nil:
    result = "<svg" & indent(svg.getAttrs(), 1) & ">" & svg.code & "</svg>"
  else: discard

proc getPath*(svg: SVGIcon): string =
  ## Get the absolute of given SVGIcon
  result = svg.path

iterator items*(icon: var IconManager, libName = ""): SVGIcon =
  ## Iterate given library. This may be useful if you 
  ## want to create a grid view with available icons. 
  var lib = libName
  if lib.len == 0:
    lib = icon.default
  for k, ico in icon.libs[lib].icons.pairs:
    yield ico

# iterator pairs*(icon: var IconManager, libName = ""): Library =
#   ## Iterate for available libraries.
#   var lib = libName
#   if lib.len == 0:
#     lib = icon.default
#   for k, l in icon.libs.pairs:
#     yield l
