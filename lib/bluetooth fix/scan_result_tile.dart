import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data
        .map((val) => '${getNiceHexArray(val)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries
        .map((v) => '${v.key}: ${getNiceHexArray(v.value)}')
        .join(', ')
        .toUpperCase();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.result.device.platformName,
                  overflow: TextOverflow.ellipsis,
                ),
              ), // Add this condition
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.result.device.remoteId.str),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('MAC Address Copied')),
                  );
                },
                child: Icon(Icons.content_copy),
              ),
            ],
          ),
          Text(
            widget.result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.result.device.remoteId.str,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.result.device.remoteId.str),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('MAC Address Copied')),
                  );
                },
                child: Icon(Icons.content_copy),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // void _storeDataInFirestore() {
  //   FirebaseFirestore.instance.collection('blue').doc('1').set({
  //     'remoteIdStr': widget.result.device.remoteId.str,
  //   }).then((_) {
  //     print("Data stored successfully in Firestore!");
  //   }).catchError((error) {
  //     print("Error storing data: $error");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;

    // Check if the platform name is empty
    if (widget.result.device.platformName.isNotEmpty) {
      // If the platform name is not empty, build the ExpansionTile
      return ExpansionTile(
        title: _buildTitle(context),
        leading: Text(widget.result.rssi.toString()),
        trailing: Text(
          widget.result.device.platformName,
          style: TextStyle(fontSize: 12),
        ),
        children: <Widget>[],
      );
    } else {
      // If the platform name is empty, return an empty container
      return Container();
    }
  }
}
