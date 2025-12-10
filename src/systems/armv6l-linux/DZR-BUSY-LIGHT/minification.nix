{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  # don't build documentation
  documentation.info.enable = mkForce false;
  documentation.man.enable = mkForce false;

  # don't include a 'command not found' helper
  programs.command-not-found.enable = mkForce false;

  # disable firewall (needs iptables)
  networking.firewall.enable = mkForce false;

  # disable polkit
  security.polkit.enable = mkForce false;

  # disable audit
  security.audit.enable = mkForce false;

  # disable udisks
  services.udisks2.enable = mkForce false;

  # disable containers
  boot.enableContainers = mkForce false;

  # build less locales
  # This isn't perfect, but let's expect the user specifies an UTF-8 defaultLocale
  i18n.supportedLocales = [(config.i18n.defaultLocale + "/UTF-8")];
}
