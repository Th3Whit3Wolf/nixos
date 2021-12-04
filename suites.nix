{ rakeLeaves, flattenTree }:
let
  nixProfiles = rakeLeaves ./profiles/nixos;
  userProfiles  = rakeLeaves ./profiles/users;

  defaultHomeSystem = with nixProfiles;  [core cachix silent_boot codecs cli compression];
  defaultHomeUser = with userProfiles;  [core browsers.firefox xdg shell.ZSH];
  vpn = nixProfiles.networking.vpn;

  nebula = {
    nixos = with nixProfiles; defaultHomeSystem ++ [ gnome smart-cards vpn.pia vpn.expressVPN ];
    users = {
      doc = with userProfiles; defaultHomeUser ++ [ desktop.gnome dev eyd vcs.git ssh ];
    };
  };
in { inherit nebula; }
