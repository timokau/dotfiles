{ pkgs, ... }:
{
  home.packages = with pkgs; [
    notmuch # mail indexing
    notmuch-mutt # mutt integration
    # mail client
    (neomutt.overrideAttrs (oldAttrs: {
      patches = [
        (pkgs.fetchpatch {
          name = "fix-maildir-flag-generation.patch";
          url = "https://github.com/neomutt/neomutt/commit/627b50e0422d0bbade8910c67362c64949ae7750.patch";
          sha256 = "108ca2y1xahczx5y317v10yk10pjr1gzh4rzrbfz8w5d1911aqs5";
        })
      ];
    }))
    (isync.override {
      # https://github.com/cyrusimap/cyrus-sasl/issues/543
      cyrus_sasl = (pkgs.cyrus_sasl.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          rm "$out/lib/sasl2/libgssapiv2.so"*
        '';
      }));
    }) # mail sync
    msmtp # send mail
    w3m # display html emails
  ];

  home.file.".mutt/aliases".source = ../mutt/.mutt/aliases;
  home.file.".mutt/colors".source = ../mutt/.mutt/colors;
  home.file.".mutt/gpg.rc".source = ../mutt/.mutt/gpg.rc;
  home.file.".mutt/mailcap".source = ../mutt/.mutt/mailcap;
  home.file.".mutt/muttrc".source = ../mutt/.mutt/muttrc;
  home.file.".mutt/personal".source = ../mutt/.mutt/personal; # not in git repo
}
