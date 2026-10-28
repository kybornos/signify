-module(signify).

-include_lib("common/include/common.hrl").

-define(PUB_KEY, <<"/etc/signify/kybr.pub">>).
-define(SEC_KEY, <<"/etc/signify/kybr.sec">>).

-export(
    [
        keygen/0,
        sign/1,
        verify/1,
        sig_file/1
    ]
).

keygen() ->
    Hostname = kybr_net:hostname(),
    Args = [
        <<"-n">>,
        <<"-G">>,
        <<"-c">>,
        Hostname,
        <<"-p">>,
        ?PUB_KEY,
        <<"-s">>,
        ?SEC_KEY
    ],
    case
        doas:run(
            #{
                user => ?ROOT,
                cmd => ?SIGNIFY,
                args => Args
            },
            2000
        )
    of
        {ok, _} ->
            ok;
        {error, Reason} ->
            {error, Reason}
    end.

sign(HashFile) ->
    SigFile = <<HashFile/binary, ".sig">>,
    Args = [
        <<"-S">>,
        <<"-e">>,
        <<"-s">>,
        ?SEC_KEY,
        <<"-m">>,
        HashFile,
        <<"-x">>,
        SigFile
    ],
    case
        doas:run(
            #{
                user => ?ROOT,
                cmd => ?SIGNIFY,
                args => Args
            },
            60000
        )
    of
        {ok, _} ->
            {ok, SigFile};
        {error, Reason} ->
            {error, Reason}
    end.

verify(File) ->
    SigFile = <<File/binary, ".SHA256.sig">>,
    Args = [
        <<"-C">>,
        <<"-p">>,
        ?PUB_KEY,
        <<"-x">>,
        SigFile,
        File
    ],
    case
        doas:run(
            #{
                user => ?ROOT,
                cmd => ?SIGNIFY,
                args => Args
            },
            60000
        )
    of
        {ok, _} ->
            {ok, File};
        {error, #{output := Reason}} ->
            {error, #{
                reason => Reason,
                from => {?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY}
            }}
    end.

sig_file(File) ->
    <<File/binary, ".SHA256.sig">>.
