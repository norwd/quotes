<!--
SPDX-FileCopyrightText: 2017 Damjan Pavlica <mudroljub@gmail.com>
SPDX-FileCopyrightText: 2026 Y. Meyer-Norwood <norwd@noreply.codeberg.org>
SPDX-License-Identifier: ISC 
-->

# Programming Quotes API

**Programming Quotes API for open source projects.**

This is a *read-only mirror*, PRs must be created on [CodeBerg](https://codeberg.org/norwd/quotes).
Feel free to get involved, suggest or implement new features.

## API Documentation

The original implementation was written in JavaScript and hosted in Azure.
As of 2025/10/16, the site is unreachable, and the project seems otherwise abandoned.
My goal here is to instead host the *same exact*[^1] quotes statically using CodeBerg Pages.
Due to how CodeBerg Pages work, the JavaScript cannot be executed server side,
and as such I've removed it, instead the quotes will be accessible statically,
with some automation to allow pseudo-querying.

[^1]: That is to say, the source dataset of quotes is the same,
      although I have [removed some quotes][fd851fb] that are in violation of the [Code of Conduct] and good taste.

[Code of Conduct]: https://norwd.codeberg.page/quotes/code-of-conduct
[fd851fb]: https://codeberg.org/norwd/quotes/commit/fd851fbfeee4a26cd7d5f5a10f19601e177f86a8

For obvious reasons, the api paths will be different, so this is *not* a drop in replacement for the original,
however, I hope it will at least be a longer lived alternative.

<!--
SPDX-SnippetBegin
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-SnippetCopyrightText: Software Freedom Conservancy <info@sfconservancy.org>
-->

# Give Up GitHub

This project has given up GitHub.
([See Software Freedom Conservancy's *Give Up  GitHub* site for details](https://GiveUpGitHub.org).)

You can now find this project here instead:
* API: [norwd.codeberg.page/quotes](https://norwd.codeberg.page/quotes)
* Repo: [codeberg.org/norwd/quotes](https://codeberg.org/norwd/quotes) (forked from [github.com/mudroljub/programming-quotes-api](https://github.com/mudroljub/programming-quotes-api))

Any use of this project's code by GitHub Copilot, past or present, is done without our permission.
We do not consent to GitHub's use of this project's code in Copilot.

Join us; you can [give up GitHub](https://GiveUpGitHub.org) too!

![Logo of the GiveUpGitHub campaign](https://sfconservancy.org/static/img/GiveUpGitHub.png)

<!--
SPDX-SnippetEnd
-->
