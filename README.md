# wp-post-grammar
> Working towards a defined unambiguous grammar of WordPress posts and an associated parser.

## Contributing

Please pardon the state of building and contributing as this project is new and started as a demo.
The process for contributing involves updating `src/post.pegjs` for working on the actual grammar
and then building all of the code and checking in the generated code on commit.
We need to rebuild the generated parser so that the interactive explorer updates with the changes.

```bash
npm run build:explorer
```

> **Note**: you will need to have Elm installed in order to build this

```bash
npm install -g elm@0.18
```

## Valuable references

 - [HTML5 syntax specification](https://www.w3.org/TR/html5/syntax.html)
