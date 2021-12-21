{ rakeLeaves, flattenTree }:
let
  nixProfiles = rakeLeaves ./profiles/nixos;
  userProfiles  = rakeLeaves ./profiles/users;

  defaultHomeSystem = with nixProfiles;  [core cachix silent_boot codecs cli compression];
  defaultHomeUser = with userProfiles;  [core browsers.firefox xdg shell.ZSH];
  vpn = nixProfiles.networking.vpn;

  nebula = {
    nixos = with nixProfiles; defaultHomeSystem ++ [ gnome fhs smart-cards vpn.pia vpn.expressVPN ];
    users = {
      doc = with userProfiles; defaultHomeUser ++ [ dev eyd vcs.git ssh ];
    };
  };

  tardis = {
    nixos = with nixProfiles; defaultHomeSystem ++ [ gnome /* fhs */ smart-cards vpn.pia vpn.expressVPN ];
    users = {
      doc = with userProfiles; defaultHomeUser ++ [ dev eyd vcs.git ssh ];
    };
  };
in { inherit nebula tardis; }
