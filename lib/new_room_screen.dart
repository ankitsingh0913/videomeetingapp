import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videosdk/videosdk.dart';


class CreateMeeting extends StatefulWidget {
  late Map<String, Participant> participants;
  CreateMeeting({super.key,required this.participants});
  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}


class _CreateMeetingState extends State<CreateMeeting> {

  String _meetingCode = "9wvy-oyba-yiyq";

  Room? _room;
  Map<String, Participant> participants = {};
  String? createdRoomId;

  @override
  void initState() {
    super.initState();
    createRoom();
  }

  void createRoom() {
    _room = VideoSDK.createRoom(
      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiI4MmRiNWViNS0wYjZjLTQ2OGMtYTY4MS05MTUwMDllZThmNjkiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTcxOTUxNTM1MCwiZXhwIjoxNzE5NjAxNzUwfQ.xATydJyyc7VY8trtsONWxHkOpqOUJm5U97A1guOFGkw",
      displayName: "Ankit",
      micEnabled: true,
      camEnabled: true,
      defaultCameraIndex: 1,
      roomId: '9wvy-oyba-yiyq', // Index of MediaDevices will be used to set default camera
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
    _room?.leave();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child:
      Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  child: Icon(Icons.arrow_back_ios_new_sharp, size: 35),
                  onTap: Get.back,
                ),
              ),
              SizedBox(height: 50),
              Image.network(
                "https://user-images.githubusercontent.com/67534990/127776392-8ef4de2d-2fd8-4b5a-b98b-ea343b19c03e.png",
                fit: BoxFit.cover,
                height: 125,
              ),
              SizedBox(height: 20),
              Text(
                "Copy meeting code below",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                        style: TextStyle(fontWeight: FontWeight.w300,fontSize: 20),
                      ),
                      trailing: Icon(Icons.copy),
                    )),
              ),
              Divider(thickness: 1, height: 40, indent: 20, endIndent: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Share.share("Meeting Code : $_meetingCode");
                },
                icon: Icon(Icons.arrow_drop_down),
                label: Text("Share invite",style: TextStyle(color: Colors.white, fontSize: 20),),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(350, 30),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
              SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  createRoom();
                },
                icon: Icon(Icons.video_call,size: 25,),
                label: Text("start call",style: TextStyle(fontSize: 20),),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: BorderSide(color: Colors.indigo),
                  fixedSize: Size(350, 35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
