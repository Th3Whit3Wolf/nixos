{ overlayPkgs }:
{ pkgs, lib, ... }:
let
  folder = ./.;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "directory" && key != "rust";
  importRust = (import ./rust {inherit overlayPkgs;});
  imports = lib.mapAttrsToList toImport
    (lib.filterAttrs filterCaches (builtins.readDir folder)) ++ [importRust];
in
{
  inherit imports;
}
