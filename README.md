# DocFX CLI as Docker image

## Bash alias

The easiest way to use the container is to add an alias like in the following snippet to your `~/.bash_profile`:

```bash
alias docfx='docker run -ti --rm -p 8080:8080 --name docfx -u `id -u` -v `pwd`:/work -w /work knsit/docfx:latest'
```

With this `alias` defined you're able to use the container e.g. like this:

```bash
docfx --help
```

## Known caveats

Apparently the command `docfx serve` does not work right now through the Docker image.
