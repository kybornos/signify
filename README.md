# OpenBSD signify wrapper in Erlang

Example usage:

``` erlang
maybe
    {ok, HashFile} ?= t1s_file:checksum(File),
    {ok, _SigFile} ?= t1s_signify:sign(HashFile),
    {ok, _} ?= t1s_signify:verify(File)
end
```
