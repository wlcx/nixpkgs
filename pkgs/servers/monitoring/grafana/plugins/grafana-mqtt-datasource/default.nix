{ grafanaPlugin, lib }:

grafanaPlugin rec {
  pname = "grafana-mqtt-datasource";
  version = "1.1.0-beta.1";
  zipHash = lib.fakeHash;
  meta = with lib; {
    description = "MQTT streaming datasource plugin for grafana";
    license = licenses.asl20;
    maintainers = with maintainers; [ samw ];
    platforms = platforms.unix;
  };
}
