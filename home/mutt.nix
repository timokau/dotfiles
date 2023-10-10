{ pkgs, ... }:
{
  home.packages = with pkgs; [
    notmuch # mail indexing
    notmuch-mutt # mutt integration
    # mail client
    neomutt
    isync # mail sync
    msmtp # send mail
    w3m # display html emails
  ];

  home.file.".mutt/aliases".source = ../mutt/.mutt/aliases;
  home.file.".mutt/colors".source = ../mutt/.mutt/colors;
  home.file.".mutt/gpg.rc".source = ../mutt/.mutt/gpg.rc;
  home.file.".mutt/mailcap".source = ../mutt/.mutt/mailcap;
  home.file.".mutt/muttrc".source = ../mutt/.mutt/muttrc;
  home.file.".mutt/process".source = ../mutt/.mutt/process; # not in git repo
  home.file.".mutt/personal".source = ../mutt/.mutt/personal; # not in git repo
}
