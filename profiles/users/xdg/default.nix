{ config, lib, pkgs, ... }:{
  systemd.user.sessionVariables = {
    # Force XDG Compliance
    ACKRC = "${config.xdg.configHome}/ack/ackrc";
    #DCONF_PROFILE = "${config.xdg.configHome}/dconf/user";
    ELINKS_CONFDIR = "${config.xdg.configHome}/elinks";
    MANPAGER = "sh -c 'col -bx | bat --paging=always -l man -p'";
    PAGER = "less";
    ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
    BAT_PAGER = "less -RFXi";
    LESSKEY = "${config.xdg.configHome}/less/lesskey";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    MOST_INITFILE = "${config.xdg.configHome}/mostrc";
    GRIPHOME = "${config.xdg.configHome}/grip";
    MPLAYER_HOME = "${config.xdg.configHome}/mplayer";
    TERMINFO = "${config.xdg.dataHome}/terminfo";
    TERMINFO_DIRS = "${config.xdg.dataHome}/terminfo:/usr/share/terminfo";
    NOTMUCH_CONFIG = "${config.xdg.configHome}/notmuch/config";
    PARALLEL_HOME = "${config.xdg.configHome}/parallel";
    #ICEAUTHORITY = "${config.xdg.cacheHome}/ICEauthority";
    IMAPFILTER_HOME = "${config.xdg.configHome}/imapfilter";
    INPUTRC = "${config.xdg.configHome}/readline/inputrc";
    SCREENRC = "${config.xdg.configHome}/screen/screenrc";
    WEECHAT_HOME = "${config.xdg.configHome}/weechat";
  };
}
