import 'package:flutter/material.dart';
import 'package:videomeetingapp/tokenservices.dart';
import 'package:videosdk/videosdk.dart';
import 'dart:math';

class CreateMeeting extends StatefulWidget {
  late Map<String, Participant> participants;
  CreateMeeting({super.key, required this.participants});
  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  String _meetingCode = "";
  Room? _room;
  Map<String, Participant> participants = {};
  String? createdRoomId;

  @override
  void initState() {
    super.initState();
    _meetingCode = _generateMeetingCode();
    fetchTokenAndCreateRoom();
  }

  String _generateMeetingCode() {
    const length = 12;
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return List.generate(length, (index) => chars[rnd.nextInt(chars.length)])
        .join()
        .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)}-")
        .substring(0, 14);
  }

  void fetchTokenAndCreateRoom() async {
    try {
      String token = await TokenService.getToken();
      createRoom(token);
    } catch (error) {
      print('Error fetching token: $error');
    }
  }

  void createRoom(String token) {
    _room = VideoSDK.createRoom(
      token: token,
      displayName: "Ankit",
      micEnabled: true,
      camEnabled: true,
      defaultCameraIndex: 1,
      roomId: _meetingCode,
    );

    setRoomEventListener();
    _room?.join();

    setState(() {
      createdRoomId = _room?.id;
    });
  }

  void setRoomEventListener() {
    _room?.on(Events.roomJoined, () {
      setState(() {
        participants.putIfAbsent(
            _room!.localParticipant.id, () => _room!.localParticipant);
      });
    });

    _room?.on(Events.participantJoined, (Participant participant) {
      setState(() => participants.putIfAbsent(participant.id, () => participant));
    });

    _room?.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(() => participants.remove(participantId));
      }
    });

    _room?.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to leave the meeting?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create a Meeting"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                  child: Card(
                    color: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.link),
                      title: SelectableText(
                        _meetingCode,
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                      ),
                      trailing: Icon(Icons.copy),
                    ),
                  ),
                ),
                Divider(thickness: 1, height: 40, indent: 20, endIndent: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Share.share("Meeting Code : $_meetingCode");
                  },
                  icon: Icon(Icons.arrow_drop_down),
                  label: Text("Share invite", style: TextStyle(color: Colors.white, fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(350, 30),
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    String token = await TokenService.getToken();
                    createRoom(token);
                  },
                  icon: Icon(Icons.video_call, size: 25),
                  label: Text("start call", style: TextStyle(fontSize: 20)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: BorderSide(color: Colors.indigo),
                    fixedSize: Size(350, 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
