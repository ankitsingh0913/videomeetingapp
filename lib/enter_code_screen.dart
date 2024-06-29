import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videosdk/videosdk.dart';
import './participant_tile.dart';
import 'new_room_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen(
      {super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {

  TextEditingController _controller = TextEditingController();

  late Room _room;

  Map<String, Participant> participants = {};
  String? joined;

  @override
  void initState() {
    // create room
    _room = VideoSDK.createRoom(
      roomId: "9wvy-oyba-yiyq",
      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiI4MmRiNWViNS0wYjZjLTQ2OGMtYTY4MS05MTUwMDllZThmNjkiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTcxOTUxNTM1MCwiZXhwIjoxNzE5NjAxNzUwfQ.xATydJyyc7VY8trtsONWxHkOpqOUJm5U97A1guOFGkw",
      displayName: "Ankit's Org",
      micEnabled: true,
      camEnabled: true,
      defaultCameraIndex:
      1, // Index of MediaDevices will be used to set default camera
    );

    //set up event listener which will give any updates happening in the room
    setRoomEventListener();
    super.initState();
  }

  // listening to room events
  void setRoomEventListener() {
    //Event called when room is joined successfully
    _room.on(Events.roomJoined, () {
      setState(() {
        joined = "JOINED";
        participants.putIfAbsent(
            _room.localParticipant.id, () => _room.localParticipant);
      });
    });

    //Event called when new participant joins
    _room.on(
      Events.participantJoined,
          (Participant participant) {
        setState(
              () => participants.putIfAbsent(participant.id, () => participant),
        );
      },
    );
    //Event called when a participant leaves the room
    _room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(
              () => participants.remove(participantId),
        );
      }
    });
    //Event called when you leave the meeting
    _room.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  // onbackButton pressed leave the room
  Future<bool> _onWillPop() async {
    _room.leave();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent[200],
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0,bottom: 8),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  color: Colors.lightBlueAccent,
                  child: const Icon(
                    Icons.video_call,
                    color: Colors.white,
                    size: 30,
                  ),
                )
            ),
          ),
          title: const Text(
              'Video Conferencing',
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: joined != null
              ? joined == "JOINED"
              ? Stack(
              children: [
                //render all participants in the room
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return ParticipantTile(
                          participant: participants.values.elementAt(index));
                    },
                    itemCount: participants.length,
                  ),
                ),
                Positioned(
                  bottom: 30,
                    left: 20,
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue
                          ),
                          child: IconButton(
                              onPressed: (){
                                _room?.leave();
                                Get.to(()=>EnterCodeScreen());
                              },
                              icon: Icon(
                                Icons.call_end,
                                color: Colors.red,
                                size: 30,
                              )
                          ),
                        )
                      ],
                    )
                )
              ],
            ):
            const Center(
              child: Text(
                  "JOINING the Room",
                  style: TextStyle(
                      color: Colors.blue
                  )
              ),
            )
            : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.network(
                      "https://user-images.githubusercontent.com/67534990/127776450-6c7a9470-d4e2-4780-ab10-143f5f86a26e.png",
                      fit: BoxFit.cover,
                      height: 140,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Enter meeting code below",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                    child: Card(
                      color: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.link),
                            labelText: "Example : abc-efg-dhi"),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _room.join();
                      setState(() {
                        joined = "JOINING";
                      });
                    },
                    child: Text(
                      "Join",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(100, 45),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Divider(
                    thickness: 2,
                    color: Colors.grey[400],
                    indent: 40,
                    endIndent: 40,
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => CreateMeeting(participants: participants,));
                    },
                    child: Text(
                      "Create a Meeting",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(300, 45),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}