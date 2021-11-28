{ inputs, lib }:
let

  mkHost = { self, hostsPath, channels, overlays, system }:
    name:
    let
      inherit (builtins)
        concatMap elemAt filter map mapAttrs pathExists split attrValues
        attrNames;
      inherit (inputs) home-manager impermanence ragenix unstable nixpolyglot;
      inherit (lib) attrByPath forEach setAttrByPath getAttrFromPath;
      inherit (self.lib.importers) rakeLeaves flattenTree;

      suites = import ../suites.nix { inherit rakeLeaves flattenTree; };
      secrets = (import ../secrets).allSystems;

      # Define `optionalAttrs` and `id` manually because trying to access
      # `self.input.nixpkgs` causes an infinite recursion.
      optionalAttrs = pred: attrs: if pred then attrs else { };

      platformTuple = split "-" system;
      platform = elemAt platformTuple 2;
      arch = elemAt platformTuple 0;

      fullHostPath = hostsPath + "/${system}/${name}";
      usersPath = fullHostPath + "/users";

      users =
        if pathExists usersPath then attrNames (rakeLeaves usersPath) else [ ];

      fromNix = lsPaths: attrValues (flattenTree (attrByPath [ "nixos" ] { } lsPaths));
      fromHm  = lsPaths: attrValues (flattenTree (attrByPath [ "users"    ] { } lsPaths));

      nixosProfiles = if attrByPath [ "${name}" "nixos" ] { } suites != {} then 
        attrByPath [ "${name}" "nixos" ] { } suites
      else
        [];

      hmProfiles = user: if attrByPath [ "${name}" "users" "${user}" ] { } suites != {} then 
        attrByPath [ "${name}" "users" "${user}" ] { } suites
      else
        [];

/*
      userSecret = user: sysSec: if attrByPath [ "${name}" "users" "${user}" ] { } secrets != {} then 
        [(attrByPath [ "${name}" "users" "${user}" ] { } secrets) sysSec]
      else
        [];

      setSecrets = 
      let   
        attr = {};
        hasSecrets = attrByPath [ "${name}" "system"] { } secrets != {};
        systemSecret = attrByPath [ "${name}" "system" ] {} secrets;
        usersWithSecrets = if hasSecrets then filter (u: attrByPath ["${name}" "users" "${u}"] {} secrets != {}) users else [];
        UserSecrets = initAttr:
          if hasSecrets then
            forEach usersWithSecrets (user: 
              initAttr // (setAttrByPath [ "${user}.age" "publicKeys" ] (userSecret user systemSecret)) 
            )
          else 
          {};
          secrets = (UserSecrets {});
        in if secrets != {} then [secrets] else [];
*/
      allModules = rakeLeaves ../modules;
      
      nixosModules = 
        let nixMod = fromNix allModules;
        in if nixMod == {} then [] else nixMod;

      hmModules =
        let 
        hmModules' = fromHm allModules;
              hmModules  = if hmModules' == {} then [] else hmModules';
        hmExternalModules = [nixpolyglot.nixosModules.home-manager.nixpolyglot];
        in hmModules ++ hmExternalModules;

      hostModules = [
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        ragenix.nixosModules.age
        {
	        # Set defaults for home-manager
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];

      userDefinitions = forEach users (u:
        setAttrByPath 
          [ "home-manager" "users" "${u}" "imports" ]
          (hmModules ++ (hmProfiles u))
      );

      modules = 
        nixosModules ++
        nixosProfiles ++
        hostModules ++ 
        userDefinitions ++ [ 
          fullHostPath 
      ];

    in {
      inherit name;
      value = {
        inherit system;
        inherit modules;
        specialArgs = {
          flake = self;
          hostPath = fullHostPath;
          #hostname = name;
          flakePkgs = self.outputs.packages."${system}";
          unstable = inputs.unstable.legacyPackages."${system}";
          extraSpecialArgs = {
            flake = self;
            flakePkgs = self.outputs.packages."${system}";
            unstable = inputs.unstable.legacyPackages."${system}";
          };
        };
      };
    };

  readDirNames = path:
    let
      inherit (builtins) attrNames filter readDir;
      files = readDir path;
      isDirectory = name: files."${name}" == "directory";
    in filter isDirectory (attrNames files);

  mkSystem = args@{ hostsPath, ... }:
    system:
    let hosts = readDirNames (hostsPath + "/${system}");
    in builtins.map (mkHost (args // { inherit system; })) hosts;

  mkHosts = args@{ self, hostsPath, channels, overlays }:
    let
      inherit (builtins) concatMap listToAttrs;

      systems = readDirNames hostsPath;
    in listToAttrs (concatMap (mkSystem args) systems);
in mkHosts
