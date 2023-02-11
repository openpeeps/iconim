<p align="center">
  <img src="https://github.com/openpeep/iconim/blob/main/.github/logo.png" width="64px"><br>
  🎁 SVG icon library manager for server-side rendering.<br>👑 Written in Nim language
</p>

<p align="center">
  <code>nimble install iconim</code>
</p>

<p align="center">
  <a href="https://openpeep.github.io/iconim">API reference</a><br>
  <img src="https://github.com/openpeep/iconim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeep/iconim/workflows/docs/badge.svg" alt="Github Actions">
</p>

## 😍 Key Features
- [x] Manage multiple SVG libraries
- [x] Auto-discover libraries
- [x] Change `XMLAttributes` on the fly
- [x] Open Source | `MIT` License
- [x] Written in 👑 Nim language

## Examples
In this example we'll use [Feather Icons](https://feathericons.com/)

```nim
# initialize
init("../examples", default = "feather", stripTags = @["class"])

# render icons
echo icon("activity")
# once rendered, we'll be stored in a hash table.

# change size on the fly
echo icon("calendar").size(48)
```

`TODO` handle custom `XMLAttributes`

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeep/iconim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeep/iconim/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)
- 🥰 [Donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C)

### 🎩 License
Iconim | MIT license. [Made by Humans from OpenPeep](https://github.com/openpeep).<br>
Copyright &copy; 2023 OpenPeep & Contributors &mdash; All rights reserved.
