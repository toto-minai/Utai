<div align="center">
<h1>Utai</h1>
<p>Mini-Functional, Offensive, MP3 Tagger for Philharmoniques<br />
<b><a href="https://github.com/toto-minai/Utai/releases/download/v0.1_3/Utai.app.zip">Download Beta</a> 🙋</b> / 
<b><a href="https://t.me/utai_app">Telegram Group</a> 🧸</b></p>
<p>Utai uses some new features (like <code>AsyncImage</code> and <code>Task</code>) from WWDC21, so it requires 
<b>macOS 12 Monterey</b> to run.</p>
</div>

## About

Utai (ウタイ) is a SwiftUI app that retrieves metadata from [Discogs](https://discogs.com) and puts ID3 tags into your MP3 files. 
It will recognise songs by their titles and lengths, and make some simple comparison with the data from Discogs.

<p align="center">
<img src="https://github.com/toto-minai/chunghwa.asia/raw/main/utai/img/screenshot-for-github.png" width="540px" />
</p>

## Getting Started

Your contributions are highly welcome. Before diving into this project, you might follow the steps below.

1. Download the required font, Yanone Kaffeesatz ([Google Fonts](https://fonts.google.com/specimen/Yanone+Kaffeesatz)), and
either install or [add it into the project](https://stackoverflow.com/a/57412354/7337835).

2. Go to [Discogs Developers Settings](https://www.discogs.com/settings/developers) and create a new app. Copy 
`Consumer Key` and `Consumer Secret` to a new file and name them `discogs_key` and `discogs_secret`. It'll be something like:

```swift
// Secrets.swift

let discogs_key = "YOUR_CONSUMER_KEY"
let discogs_secret = "YOUR_CONSUMER_SECRET"

```

## License

Distributed under the GNU General Public License v3.0. See `LICENSE` for more details.

## Contact

Toto Minai – [@toto_minai](https://twitter.com/toto_minai) 🍒 / [toto_minai@outlook.com](mailto:toto_minai@outlook.com) ✉️

Website – <https://chunghwa.asia/utai>

Telegram Group – <https://t.me/utai_app>

## Frameworks

- [ID3TagEditor](https://github.com/chicio/ID3TagEditor)
