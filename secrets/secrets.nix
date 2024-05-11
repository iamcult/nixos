let
  cult = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5q3lxHeDY1epzqP5p3k1CJUT4rPSrNga4o+RDokm2g";
  users = [ cult ];

  thing = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILGyT0gMYu9DEAaBZ2vNwImAXeWzVDcO3zXG0titxjE2";
  systems = [ thing ];
in
{
  "password.age".publicKeys = [ cult thing ];
  "factorio.age".publicKeys = [ cult thing ];
}
