{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:

with pkgs;
let
  inherit (lib) optional optionals;

  basePackages = [
    (import ./nix/default.nix { inherit pkgs; })
    pkgs.niv
  ];

  inputs =  basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  hooks = ''
    # this allows mix to work on the local directory
    mkdir -p .nix-mix .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    # make hex from Nixpkgs available
    # `mix local.hex` will install hex into MIX_HOME and should take precedence
    export MIX_PATH="${beam.packages.erlangR25.hex}/lib/erlang/lib/hex/ebin"
    export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
    export LANG=C.UTF-8
    # keep your shell history in iex
    export ERL_AFLAGS="-kernel shell_history enabled"

    # export MIX_ENV=dev
    export LANG="en_US.UTF-8"

    # I already have PG running, but if I wanted to run
    # it within nix...
    
    # export PGDATA="$PWD/db"
    # export SOCKET_DIRECTORIES="$PWD/sockets"
    # mkdir $SOCKET_DIRECTORIES
    # initdb
    # echo "unix_socket_directories = '$SOCKET_DIRECTORIES'" >> $PGDATA/postgresql.conf
    # pg_ctl -l $PGDATA/logfile start
    # createuser postgres --createdb -h localhost
    # function end {
    #   echo "Shutting down the database..."
    #  pg_ctl stop
    #  echo "Removing directories..."
    #  rm -rf $PGDATA $SOCKET_DIRECTORIES
    # }
    # trap end EXIT
    # mix local.hex
    # mix archive.install hex phx_new 1.4.0
  '';
in

mkShell {
  buildInputs = inputs;
  shellHook = hooks;

  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
}
