final: prev: {
  deploy-rs = { inherit (prev) deploy-rs; lib = final.deploy-rs.lib; };
}
