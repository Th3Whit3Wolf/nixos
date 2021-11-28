lib: { ... } @ inputs:

inputs.unstable.lib.makeExtensible (self: rec { 
  importers = import ./importers.nix { lib = inputs.unstable.lib; };
  mkHosts = import ./mkHosts.nix { inputs = inputs; lib = inputs.unstable.lib; };

  inherit (importers)
    flattenTree
    rakeLeaves
    rakePkgs;
})
