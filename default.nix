{
  mkDerivation, stdenv
, base, kafka-device, vrpn
}:

mkDerivation {
  pname = "kafka-device-vrpn";
  version = "1.0.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base kafka-device vrpn
  ];
  executableHaskellDepends = [
  ];
  homepage = "https://bitbucket.org/functionally/kafka-device-vrpn";
  description = "VRPN events via a Kafka message broker";
  license = stdenv.lib.licenses.mit;
}
