{ lib }:

let
  flattenTree =
    /* *
       Synopsis: flattenTree _tree_
       Flattens a _tree_ of the shape that is produced by rakeLeaves.
       Output Format:
       An attrset with names in the spirit of the Reverse DNS Notation form
       that fully preserve information about grouping from nesting.
       Example input:
       ```
       {
       a = {
       b = {
       c = <path>;
       };
       };
       }
       ```
       Example output:
       ```
       {
       "a.b.c" = <path>;
       }
       ```
       *
    */
    tree:
    let
      inherit (builtins) concatStringsSep isPath isAttrs foldl' attrNames;
      op = sum: path: val:
        let
          pathStr = concatStringsSep "." path; # dot-based reverse DNS notation
        in if isPath val then
        # builtins.trace "${toString val} is a path"
          (sum // { "${pathStr}" = val; })
        else if isAttrs val then
        # builtins.trace "${builtins.toJSON val} is an attrset"
        # recurse into that attribute set
          (recurse sum path val)
        else
        # ignore that value
        # builtins.trace "${toString path} is something else"
          sum;

      recurse = sum: path: val:
        foldl' (sum: key: op sum (path ++ [ key ]) val.${key}) sum
        (attrNames val);
    in recurse { } [ ] tree;

  rakeLeaves =
    /* *
       Synopsis: rakeLeaves _path_
       Recursively collect the nix files of _path_ into attrs.
       Output Format:
       An attribute set where all `.nix` files and directories with `default.nix` in them
       are mapped to keys that are either the file with .nix stripped or the folder name.
       All other directories are recursed further into nested attribute sets with the same format.
       Example file structure:
       ```
       ./core/default.nix
       ./base.nix
       ./main/dev.nix
       ./main/os/default.nix
       ```
       Example output:
       ```
       {
       core = ./core;
       base = base.nix;
       main = {
       dev = ./main/dev.nix;
       os = ./main/os;
       };
       }
       ```
       *
    */
    dirPath:
    let
      inherit (lib) filterAttrs mapAttrs' removeSuffix hasSuffix;
      inherit (builtins) pathExists readDir;
      seive = file: type:
        # Only rake `.nix` files or directories
        (type == "regular" && hasSuffix ".nix" file) || (type == "directory");

      collect = file: type: {
        name = removeSuffix ".nix" file;
        value = let path = dirPath + "/${file}";
        in if (type == "regular")
        || (type == "directory" && pathExists (path + "/default.nix")) then
          path
          # recurse on directories that don't contain a `default.nix`
        else
          rakeLeaves path;
      };

      files = filterAttrs seive (readDir dirPath);
    in filterAttrs (n: v: v != { }) (mapAttrs' collect files);

  rakePkgs = dir:
    let
      inherit (lib)
        filterAttrs splitString last nameValuePair mapAttrs';
      sieve = name: val:
        (name != "default" && name != "bud" && name != "_sources");

      flattenFiltered = flattenTree (filterAttrs sieve (rakeLeaves dir));
      getBasename = name: last (splitString "." name);
    in mapAttrs' (n: v: nameValuePair (getBasename n) v) flattenFiltered;

in { inherit flattenTree rakeLeaves rakePkgs; }
