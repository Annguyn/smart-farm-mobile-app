import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> resolveMdns(String hostname) async {
  final MDnsClient client = MDnsClient();
  await client.start();
  try {
    final String ipAddress = await client
        .lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(hostname))
        .map((record) => record.address.address)
        .firstWhere((address) => address.isNotEmpty, orElse: () => '');
    return ipAddress;
  } finally {
    client.stop();
  }
}
const String mdnsHostname = 'http://anfarm.local:5000';
const String flaskHostname = "anfarm.local:5000";
Future<String> getMdnsHostname() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('mdnsHostname') ?? 'http://anfarm.local:5000';
}
Future<String> flaskIp = resolveMdns(flaskHostname);