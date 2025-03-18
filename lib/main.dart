import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beltran Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Color _backgroundColor = Colors.white;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isPaused = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentImageIndex = 0;
  String _selectedSong = 'audio/song.mp3';
  late VideoPlayerController _videoController;
  bool _showVideoControls = false;
  bool _showSongControls = false;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.pink,
    Colors.purple
  ];
  int _colorIndex = 0;

  final List<String> _images = [
    'assets/girl.jpg',
    'assets/micky&draken.jpg',
  ];

  final List<String> _todoList = [
    'Wake up in the morning',
    'Drink coffee',
    'Lunch',
    'Study Flutter',
    'Relax and watch movies'
  ];

  final List<Map<String, String>> _songs = [
    {'name': 'Song 1', 'path': 'audio/song.mp3'},
    {'name': 'Song 2', 'path': 'audio/song2.mp3'},
    {'name': 'Song 3', 'path': 'audio/song3.mp3'},
  ];

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/video.mp4')
      ..initialize().then((_) => setState(() {}));

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() => _position = newPosition);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  void _showTodoList() {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('To-Do List', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._todoList.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  String task = entry.value;
                  return Dismissible(
                    key: Key(task),
                    onDismissed: (direction) {
                      setState(() => _todoList.removeAt(entry.key));
                      setStateDialog(() {});
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading:
                          Text('$index.', style: const TextStyle(fontSize: 18)),
                      title: GestureDetector(
                        onTap: () {
                          taskController.text = task;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Task'),
                              content: TextField(
                                controller: taskController,
                                decoration: const InputDecoration(
                                    hintText: "Enter updated task"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _todoList[entry.key] =
                                        taskController.text);
                                    Navigator.pop(context);
                                    setStateDialog(() {});
                                  },
                                  child: const Text('Update'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(task, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    taskController.clear();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Add New Task'),
                        content: TextField(
                          controller: taskController,
                          decoration:
                              const InputDecoration(hintText: "Enter new task"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (taskController.text.isNotEmpty) {
                                setState(
                                    () => _todoList.add(taskController.text));
                                Navigator.pop(context);
                                setStateDialog(() {});
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeBackgroundColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _colors.length;
      _backgroundColor = _colors[_colorIndex];
      // Show video controls only when the background color changes
      if (!isPlaying) {
        _showVideoControls = true;
      }
    });
  }

  void _chooseSong() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_songs[index]['name']!),
              onTap: () {
                setState(() {
                  _selectedSong = _songs[index]['path']!;
                  isPlaying = false; // Reset play state for the new song
                  isPaused = false;
                });
                _toggleAudio(); // Play the newly selected song immediately
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _toggleAudio() async {
    if (isPlaying && !isPaused) {
      // If audio is playing, pause it
      await _audioPlayer.pause();
      setState(() => isPaused = true);
    } else if (isPaused) {
      // If paused, resume from the current position
      await _audioPlayer.resume();
      setState(() {
        isPlaying = true;
        isPaused = false;
      });
    } else {
      // If not playing or paused (new song), play from start
      await _audioPlayer.stop(); // Ensure any previous song is stopped first
      await _audioPlayer.play(AssetSource(_selectedSong));

      setState(() {
        isPlaying = true;
        isPaused = false;
        _position = Duration.zero; // Reset position to 0
      });

      // Listen for when the song finishes
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          isPlaying = false;
          isPaused = false;
          _position = Duration.zero;
        });
      });
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      _position = Duration.zero;
    });
  }

  void _changeImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Welcome to Beltran Midterm Project',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Only show video controls if video is visible and not playing a song
          if (_showVideoControls &&
              _videoController.value.isInitialized &&
              !isPlaying)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 450, // Slightly wider
                  height: 250,
                  child: VideoPlayer(_videoController),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _videoController.play();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause, color: Colors.yellow),
                      onPressed: () {
                        setState(() {
                          _videoController.pause();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _videoController.seekTo(Duration.zero);
                          _videoController.pause();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 10),
          if (isPlaying)
            GestureDetector(
              onTap: _changeImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2)),
                  ],
                  image: DecorationImage(
                    image: AssetImage(_images[_currentImageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (isPlaying)
            Column(
              children: [
                Text(
                  '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble(),
                  value: _position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                    await _audioPlayer.resume();
                  },
                ),
              ],
            ),
          const SizedBox(height: 10),

          // Show Song Control Buttons only when a song is selected
          if (isPlaying)
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.lightBlueAccent,
                      size: 36, // Bigger button
                    ),
                    onPressed: _toggleAudio,
                  ),
                  const SizedBox(width: 20), // Space between buttons
                  // Stop button
                  IconButton(
                    icon: const Icon(Icons.stop,
                        color: Colors.redAccent, size: 36),
                    onPressed: _stopAudio,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRectangularButton('To Do List', Icons.list, _showTodoList),
              _buildRectangularButton(
                  'Change Color', Icons.color_lens, _changeBackgroundColor),
              _buildRectangularButton(
                  'Choose Song', Icons.music_note, _chooseSong),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildRectangularButton(
      String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              const BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 30),
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }
}
