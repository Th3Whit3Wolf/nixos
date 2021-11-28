{ config, lib, pkgs, ... }:
let 
    inherit (config.home) homeDirectory username;
    bookmarksPath = ./bookmarks.html;
    bookmarksJson = ./bookmarks.json;
    bookmarks = builtins.readFile bookmarksPath;
    uiState = {
        placements = {
            widget-overflow-fixed-list = [
                "treestyletab_piro_sakura_ne_jp-browser-action"
                "_testpilot-containers-browser-action"
                "jid1-kkzogwgsw3ao4q_jetpack-browser-action"
                "canvasblocker_kkapsner_de-browser-action"
            ];
            nav-bar = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "customizableui-special-spring1"
                "urlbar-container"
                "customizableui-special-spring2"
                "save-to-pocket-button"
                "downloads-button"
                "fxa-toolbar-menu-button"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "addon_darkreader_org-browser-action"
                "support_lastpass_com-browser-action"
            ];
            toolbar-menubar = ["menubar-items"];
            TabsToolbar = [ "tabbrowser-tabs" "new-tab-button" "alltabs-button"];
            PersonalToolbar = ["personal-bookmarks"];
        };
        seen = [
            "developer-button"
            "_f209234a-76f0-4735-9920-eb62507a54cd_-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "treestyletab_piro_sakura_ne_jp-browser-action"
            "canvasblocker_kkapsner_de-browser-action"
            "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
            "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
            "addon_darkreader_org-browser-action"
            "_testpilot-containers-browser-action"
            "_94060031-effe-4b93-89b4-9cd570217a8d_-browser-action"
            "jid1-kkzogwgsw3ao4q_jetpack-browser-action"
            "support_lastpass_com-browser-action"
            "jid1-om7ejgwa1u8akg_jetpack-browser-action"
            "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
        ];
        dirtyAreaCache = ["nav-bar" "PersonalToolbar" "widget-overflow-fixed-list"];
        currentVersion =17;
        newElementCount = 3;
    };
    downloadDir = if (config.xdg.userDirs.enable) then config.xdg.userDirs.download else "${homeDirectory}/Downs";
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        #auto-tab-discard
        bitwarden
        canvasblocker
        clearurls
        darkreader
        fraidycat
        i-dont-care-about-cookies
        lastpass-password-manager
        netflix-1080p
        octotree
        refined-github
        multi-account-containers
        #sidebery
        temporary-containers
        terms-of-service-didnt-read
        tree-style-tab
        ublock-origin
        unpaywall
    ];
    settings = (import ./settings.nix { inherit downloadDir; }) // {
        "browser.bookmarks.file" =   (builtins.toString bookmarksPath);
        "browser.places.importBookmarksHTML" = false;
        "browser.tabs.loadBookmarksInBackground" = true;
        "browser.bookmarks.addedImportButton" = false;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.uiCustomization.state" = (builtins.toJSON uiState);
    };
in
{
    programs.firefox = {
        inherit extensions;
        enable = true;
        package = pkgs.firefox-wayland;
        profiles.${username} = {
            inherit settings;
        };
    };
}