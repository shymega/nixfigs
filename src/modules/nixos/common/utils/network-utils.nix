# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = let
    inherit (lib) getExe getExe';
    inherit (pkgs) writeScriptBin;
    inherit (pkgs.stdenv) shell;
    nmcli = getExe' pkgs.networkmanager "nmcli";
  in [
    (writeScriptBin "net-type" ''
      #! ${shell}
      set -eu

      exec ${nmcli} \
        networking connectivity
    '')
    (writeScriptBin "net-metered" ''
      #! ${shell}
      set -eu

      DEVICE=$(${nmcli} device status | grep wifi | grep connected | \
        ${getExe' pkgs.coreutils "head"} -1 | ${getExe pkgs.gawk} '{print $1}')
      CURRENT_CONNECTION=$(${nmcli} -t -f GENERAL.CONNECTION --mode tabular device show "$DEVICE")

      exec ${nmcli} -g connection.metered connection show "$CURRENT_CONNECTION" | ${getExe' pkgs.coreutils "head"} -n1
    '')
    (writeScriptBin "net-current-profile" ''
      #! ${shell}
      set -eu

      exec ${nmcli} connection show --active | ${getExe' pkgs.coreutils "head"} -2 | ${getExe' pkgs.coreutils "tail"} -1 | ${getExe pkgs.gawk} '{print $1}'
    '')
    (writeScriptBin "net-connected-profiles" ''
      #! ${shell}
      set -eu

      exec ${nmcli} -t connection show --active | ${getExe pkgs.gawk} -F: '{print $2}'
    '')
    (writeScriptBin "net-reset-unit-states" ''
      #! ${shell}
      set -eu

      [ $(id -u) != 0 ] && exit 1
      ${getExe' pkgs.systemd "systemctl"} stop network-online.target \
        network-rnet.target \
        network-portal.target \
        network-mifi.target \
        network-work.target

      systemctl-user-action $" stop network-online.target \
        network-rnet.target \
        network-portal.target \
        network-mifi.target \
        network-work.target
    '')
    (writeScriptBin "systemctl-user-action" ''
      #! ${shell}

      set -eu

      USER=''${1:-dzrodriguez}
      ACTION=''${2:-status}
      UNIT=$3

      export XDG_RUNTIME_DIR="/run/user/$(${getExe' pkgs.coreutils "id"} -u $USER)"
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

      [ -z "$UNIT" ] && exit 1

      exec ${getExe pkgs.sudo} -Eu "$USER" sh -c "${getExe' pkgs.systemd "systemctl"} --no-block --user $ACTION $UNIT"
    '')
    (writeScriptBin "flush-postfix" ''
      #! ${shell}

      set -eu

      ${getExe pkgs.sudo} ${getExe' pkgs.postfix "postsuper"} -H ALL
      ${getExe pkgs.sudo} ${getExe' pkgs.postfix "postfix"} flush
    '')
  ];
}
