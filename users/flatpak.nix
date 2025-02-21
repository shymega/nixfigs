# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, ... }: {
  services.flatpak = {
    enable = true;
    packages = [
      "com.calibre_ebook.calibre"
      "com.discordapp.Discord"
      "com.freerdp.FreeRDP"
      "com.getpostman.Postman"
      "com.github.Matoking.protontricks"
      "com.github.tchx84.Flatseal"
      "com.google.AndroidStudio"
      "com.icanblink.blink"
      "com.jgraph.drawio.desktop"
      "com.moonlight_stream.Moonlight"
      "com.parsecgaming.parsec"
      "com.slack.Slack"
      "com.valvesoftware.Steam"
      "com.wps.Office"
      "im.riot.Riot"
      "io.dbeaver.DBeaverCommunity"
      "net.davidotek.pupgui2"
      "net.kuribo64.melonDS"
      "net.lutris.Lutris"
      "org.DolphinEmu.dolphin-emu"
      "org.citra_emu.citra"
      "org.filezillaproject.Filezilla"
      "org.freecadweb.FreeCAD"
      "org.freedesktop.Sdk.Extension.dotnet7"
      "org.freedesktop.Sdk.Extension.golang"
      "org.freedesktop.Sdk.Extension.llvm14"
      "org.freedesktop.Sdk.Extension.node18"
      "org.freedesktop.Sdk.Extension.openjdk11"
      "org.freedesktop.Sdk.Extension.openjdk17"
      "org.freedesktop.Sdk.Extension.openjdk8"
      "org.freedesktop.Sdk.Extension.rust-nightly"
      "org.freedesktop.Sdk.Extension.rust-stable"
      "org.freedesktop.Sdk.Extension.ziglang"
      "org.fritzingca.Fritzing"
      "org.gnome.NetworkDisplays"
      "org.kicad.KiCad"
      "org.openscad.OpenSCAD"
      "org.prismlauncher.PrismLauncher"
      "org.remmina.Remmina"
      "org.telegram.desktop"
      "org.winehq.Wine"
      "org.yuzu_emu.yuzu"
      "org.zdoom.GZDoom"
      "us.zoom.Zoom"
    ];
    update.onActivation = true;
    update.auto = {
      enable = true;
      onCalendar = "daily";
    };
  };
}
