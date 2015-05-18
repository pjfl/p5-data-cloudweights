requires "Moo" => "2.000001";
requires "Type::Tiny" => "1.000004";
requires "namespace::autoclean" => "0.22";
requires "perl" => "5.01";

on 'build' => sub {
  requires "Module::Build" => "0.4004";
  requires "Test::Requires" => "0.06";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
