{ config, lib, ... }:
let
  cfg = config.services.matrix-synapse;
  mkIntOption =
    description:
    lib.mkOption {
      type = lib.types.int;
      default = 0;
      inherit description;
    };
in
{
  imports = [
    ./single/appservice.nix
    ./single/background.nix
    ./single/user-dir.nix

    ./auth.nix
    ./client-reader.nix
    ./event-creator.nix
    ./federation-inbound.nix
    ./federation-reader.nix
    ./federation-sender.nix
    ./media-repo.nix
    ./pusher.nix
    ./sync.nix

    ./stream-writers/event-stream-writer.nix
  ];
  options.services.matrix-synapse = {
    enableWorkers = lib.mkEnableOption "Enable dedicated workers";
    enableStreamWriters = lib.mkEnableOption "Enable stream writers";
    enableAppserviceWorker = lib.mkEnableOption "Enable dedicated appservice worker";
    enableBackgroundWorker = lib.mkEnableOption "Enable dedicated background task worker";
    enableUserDirWorker = lib.mkEnableOption "Enable dedicated user directory worker";

    authWorkers = mkIntOption "Number of auth workers";
    clientReaders = mkIntOption "Number of client readers";
    eventCreators = mkIntOption "Number of auth workers";
    federationInboundWorkers = mkIntOption "Number of federation inbound workers";
    federationReaders = mkIntOption "Number of federation readers";
    federationSenders = mkIntOption "Number of federation senders";
    mediaRepoWorkers = mkIntOption "Number of media repo workers";
    pushers = mkIntOption "Number of pushers";
    syncWorkers = mkIntOption "Number of sync workers";

    #stream writers
    eventStreamWriters = mkIntOption "Number of event stream writers";
    typingStreamWriters = mkIntOption "Number of typing stream writers";
    toDeviceStreamWriters = mkIntOption "Number of to_device stream writers";
    accountDataStreamWriters = mkIntOption "Number of account data stream writers";
    receiptsStreamWriters = mkIntOption "Number of read receipt stream writers";
    presenceStreamWriters = mkIntOption "Number of presence stream writers";
    pushRuleStreamWriters = mkIntOption "Number of push rule stream writers";

    nginxVirtualHostName = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "The virtual host name for the nginx server";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.enableWorkers -> cfg.nginxVirtualHostName != null;
        message = "nginxVirtualHostName must be set when enableWorkers is true";
      }
    ];
  };
}
