# Programming Quotes API

**Programming Quotes API for open source projects.**

Visit: [norwd.github.io/quotes](https://norwd.github.io/quotes)

Github repo: [github.com/norwd/quotes](https://github.com/norwd/quotes) (forked from [github.com/mudroljub/programming-quotes-api](https://github.com/mudroljub/programming-quotes-api))

Feel free to get involved, suggest or implement new features.

## API Documentation

The original implementation was writen in JavaScript and hosted in Azure.
As of 2025/10/16, the site is unreachable, and the project seems otherwise abandonded.
My goal here is to instead host the *same exact*[^1] quotes statically using GitHub Pages.
Due to how GitHub Pages work, the JavaScript cannot be executed server side,
and as such I've removed it,
instead the quotes will be accessable statically,
with some automation to allow psuedo-querying.

[^1]: That is to say, the source dataset of quotes is the same,
      although I have [removed some quotes][fd851fb] that are inviolation of the [Code of Conduct] and good taste.

[Code of Conduct]: https://norwd.github.io/quotes/code-of-conduct
[fd851fb]: https://github.com/norwd/quotes/commit/fd851fbfeee4a26cd7d5f5a10f19601e177f86a8

For obvious reasons, the api paths will be different, so this is *not* a drop in replacement for the original,
however, I hope it will at least be a longer lived alternative.

### Public Routes

#### GET [`/quotes/qotd`](https://norwd.github.io/quotes/qotd)
#### GET [`/quotes/qotd.json`](https://norwd.github.io/quotes/qotd.json)
- **Description**: Fetches programming quote of the day.
- **Example**: `/quotes/qotd.json`
  ```
  {
    "text": "If you think your users are idiots, only idiots will use it.",
    "author": "Linus Torvalds"
  }
  ```

#### GET [`/quotes/random`](https://norwd.github.io/quotes/random)
#### GET [`/quotes/random.json`](https://norwd.github.io/quotes/random.json)
- **Description**: ~~Fetches a random programming quote~~. This is currently an alias of `/quotes/qotd`.
- **Example**: `/quotes/random.json`
  ```
  {
    "text": "Mathematicians stand on each others' shoulders and computer scientists stand on each others' toes.",
    "author": "Richard Hamming"
  }
  ```

#### GET [`/quotes/{lang}`](https://norwd.github.io/quotes/en)
#### GET [`/quotes/{lang}.json`](https://norwd.github.io/quotes/en.json)
- **Description**: Retrieves quotes by language (defaults to English if not yet translated).
- **Example**: `/quotes/en.json`
  ```
  [
    {
      "text": "When in doubt, use brute force.",
      "author": "Ken Thompson"
    },
    {
      "text": "One accurate measurement is worth more than a thousand expert opinions.",
      "author": "Grace Hopper"
    },
    {
      "text": "When there is no type hierarchy you don’t have to manage the type hierarchy.",
      "author": "Rob Pike"
    }
    ...
  ]
  ```

#### GET [`/quotes/{id}`](https://norwd.github.io/quotes/5a6ce86e2af929789500e7d7)
#### GET [`/quotes/{id}.json`](https://norwd.github.io/quotes/5a6ce86e2af929789500e7d7.json)
- **Description**: Retrieves a single quote by its unique ID.
- **Example**: `/quotes/5a6ce86e2af929789500e7d7.json`
  ```
  {
    "text": "Simplicity is prerequisite for reliability.",
    "author": "Edsger W. Dijkstra"
  }
  ```

#### GET [`/quotes/authors`](https://norwd.github.io/quotes/authors)
#### GET [`/quotes/authors.json`](https://norwd.github.io/quotes/authors.json)
- **Description**: Retrieves authors.
- **Example**: `/quotes/authors.json`
  ```
  [
    "Edsger W. Dijkstra",
    "Ken Thompson",
    "Donald Knuth",
    ...
  ]
  ```

#### GET [`/quotes/{author}`](https://norwd.github.io/quotes/Edsger_W_Dijkstra)
#### GET [`/quotes/{author}.json`](https://norwd.github.io/quotes/Edsger_W_Dijkstra.json)
- **Description**: Retrieves quotes by author.
- **Example**: `/quotes/Edsger_W_Dijkstra.json`
  ```
  [
    {
      "text": "Computer Science is no more about computers than astronomy is about telescopes.",
      "author": "Edsger W. Dijkstra"
    },
    {
      "text": "Simplicity is prerequisite for reliability.",
      "author": "Edsger W. Dijkstra"
    },
    {
      "text": "The computing scientist’s main challenge is not to get confused by the complexities of his own making.",
      "author": "Edsger W. Dijkstra"
    }
    ...
  ]
  ```
