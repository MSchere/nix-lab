let
  # nix-lab server SSH host key (as age public key)
  server = "age1a6zcu0urj9pccjnnmkqkuwxhtwwlvax3ks49p23elev84nmmhvks3pexa";
in {
  "monero-rpc.age".publicKeys        = [ server ];
  "tiponero.age".publicKeys          = [ server ];
  "spending-tracker.age".publicKeys  = [ server ];
  "cloudflare-tunnel.age".publicKeys = [ server ];
}
