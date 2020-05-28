+++
date = 2020-05-28T13:00:00Z
lastmod = 2020-05-28T13:00:00Z
title = "My Perfect VS Code Setup"
+++

The role of the traditional Systems Administrator is slowly but surely dying. Clicking on buttons in GUI's is making way for configuration as code. As such, you text editor is more important than ever. I've had several discussions about various setups, so here is mine.

For conxtext on my choices, my day to day activities in a text editor are mainly:

- Terraform
- Python
- Puppet
- Go
- Configuration file editing (yaml, json etc)

## Preamble

There are a few things that need to be installed before VS Code is functional for me. Firstly, you obviously need [VS Code](https://code.visualstudio.com/). I also need the following:

- [tfenv](https://github.com/tfutils/tfenv)
- [Python 3](https://www.python.org/downloads/)
  - [black](https://black.readthedocs.io/en/stable/) (`pip3 install black`)
- [Puppet Development Kit](https://puppet.com/try-puppet/puppet-development-kit/)
  - [puppet-lint](http://puppet-lint.com/) (`gem install puppet-lint`)
- [Go](https://golang.org/dl/) (Make sure you set up your path correctly if you're running Linux or Windows)

## Theme and font

Whilst this shouldn't matter to you at all, nerds sure do like to talk about unimportant things like font and color theme. I use [One Monokai](https://marketplace.visualstudio.com/items?itemName=azemoh.one-monokai) and [Hack](https://sourcefoundry.org/hack/).

## Extensions

On to the important stuff. Extensions are what make VS Code so customizable. Most of these are formatters or extensions that offer autocompletes (or InteliSense as VS Code refers to it).

- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Go](https://marketplace.visualstudio.com/items?itemName=ms-vscode.Go)
- [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
- [Puppet](https://marketplace.visualstudio.com/items?itemName=puppet.puppet-vscode)
- [PropertyList](https://marketplace.visualstudio.com/items?itemName=zhouronghui.propertylist)
- [Binary Plist](https://marketplace.visualstudio.com/items?itemName=dnicolson.binary-plist)
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=davidanson.vscode-markdownlint)
- [Better TOML](https://marketplace.visualstudio.com/items?itemName=dnicolson.binary-plist)
- [Jenkinsfile Support](https://marketplace.visualstudio.com/items?itemName=secanis.jenkinsfile-support)
- [Advanced New File](https://marketplace.visualstudio.com/items?itemName=patbenatar.advanced-new-file)
- [Prettier+](https://marketplace.visualstudio.com/items?itemName=svipas.prettier-plus)
- [Ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.ruby)
- [VSCode Ruby](https://marketplace.visualstudio.com/items?itemName=wingrunr21.vscode-ruby)
- [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)

Probably the most important one is [Settings Sync](https://marketplace.visualstudio.com/items?itemName=shan.code-settings-sync). This syncs your settings to a GitHub Gist, allowing you to have exactly the same configuration across all of your devices. If like me, you switch between macOS, Windows and Linux pretty regularly, this is absolutely invaluable.

## Settings

Most of the default settings are sensible, but there are a few tweaks I would recommend making. First off, set `black` to be your default formatter and set the path to it (usually as below, but `which black` will give you what you need)

![](/images/posts/2020-05-28/python-settings.png)

The default formatter will handle any file format you don't specify one for. Set it to Prettier+.

![](/images/posts/2020-05-28/default-formatter.png)

Now for some Go and Puppet settings. These are easier to copy and paste, so open the command palette (cmd-shift-p on macOS, ctrol-shift-p on Linux and Windows) and type in `Open Settings (JSON)`, and add in the following.

```json
  "go.lintOnSave": "file",
  "go.lintTool": "golangci-lint",
  "go.lintFlags": ["--fast"],
  "go.formatTool": "goimports",
  "go.alternateTools": {
    " goreturns": "gofumports"
  },
  "editor.formatOnSave": true,
  "[puppet]": {
    "editor.formatOnSave": false
  },
```

These settings will set up linting and formatting for Go - you will be prompted to install any missing Go dependencies. We then are turning on the most important setting - enabling formatting when you save a file. This means you never need to think about formatting when you save a file. I did however, find an issue with formatting on save with Puppet files, so that is disabled here.

## Conclusion

There are many other settings that make up the perfect coding environment, but this covers most of what I consider essential. My settings are on a [public Gist](https://gist.github.com/grahamgilbert/62c24f025f70349e15ccc046c2588686) if you are interested in seeing what else I have configured.

![](/images/posts/2020-05-28/vscode.png)
