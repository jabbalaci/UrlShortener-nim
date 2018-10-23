URL Shortener
=============

A URL shortener cli app. using [bit.ly](https://bitly.com/).

Usage
-----

You can pass the long URL as a command-line parameter or you can use the app.
in interactive mode if you don't specify any parameters.

```bash
$ ./urlshortener http://google.com
http://bit.ly/2CZtpGA
# expanded from shortened URL: http://google.com (matches)
```

```bash
$ ./urlshortener
Long URL: https://google.com
http://bit.ly/2R9zFOR
# expanded from shortened URL: https://google.com (matches)
```

(In the latter case we used the `https` protocol, hence the difference.)

Pre-requisite
-------------

For this to work, you need an access token from bit.ly. Don't worry, it's free.
After registration you can generate one for yourself. Then, add it as an
environment variable called `BITLY_ACCESS_TOKEN`. For instance, under Linux
add the following line to the end of your `~/.bashrc` file:

```bash
export BITLY_ACCESS_TOKEN="..."
```

Related projects
----------------

I used https://github.com/bitly/bitly-api-python to figure out what API calls to make.
