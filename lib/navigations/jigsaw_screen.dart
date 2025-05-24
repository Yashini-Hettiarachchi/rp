// import 'dart:async';
// import 'dart:math';
// import 'dart:ui' as ui;
//
// import 'package:chat_app/navigations/puzzle_levels_screen.dart';
// import 'package:chat_app/navigations/puzzle_results_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/physics.dart';
// import 'package:http/http.dart' as http;
//
// class JigsawHomePage extends StatefulWidget {
//   final int factor;
//   final int difficulty;
//
//   // Constructor to initialize the parameters
//   JigsawHomePage({required this.factor, required this.difficulty});
//
//   @override
//   _JigsawHomePageState createState() => _JigsawHomePageState();
// }
//
// class _JigsawHomePageState extends State<JigsawHomePage>
//     with SingleTickerProviderStateMixin {
//   ui.Image? canvasImage;
//   bool _loaded = false;
//   List<JigsawPiece> pieceOnBoard = [];
//   List<JigsawPiece> pieceOnPool = [];
//   JigsawPiece? _currentPiece;
//   Animation<Offset>? _offsetAnimation;
//   final _boardWidgetKey = GlobalKey();
//   late AnimationController _animController;
//
//   int _timeElapsed = 0;
//   int _movesMade = 0;
//   int _totalMoves = 0;
//   int _score = 0;
//
//   Timer? _timer;
//
//   @override
//   void initState() {
//     _animController = AnimationController(vsync: this);
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_loaded) _prepareGame();
//   }
//
//   void _startTimer() {
//     _timeElapsed = 0;
//     _movesMade = 0;
//     _timer?.cancel();
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         _timeElapsed++;
//       });
//     });
//   }
//
//   void _stopTimer() {
//     _timer?.cancel();
//   }
//
//   void _prepareGame() async {
//     pieceOnPool.clear();
//     pieceOnBoard.clear();
//
//     setState(() {
//       _loaded = false;
//     });
//
//     final screenPixelScale = MediaQuery.of(context).devicePixelRatio;
//     final imageSize = (300 * screenPixelScale).toInt();
//     final response =
//     await http.get(Uri.parse('https://picsum.photos/$imageSize/$imageSize'));
//     final imageData = response.bodyBytes;
//
//     final image = MemoryImage(imageData, scale: screenPixelScale);
//     canvasImage = await _getImage(image);
//     pieceOnPool = _createJigsawPiece();
//     pieceOnPool.shuffle();
//
//     setState(() {
//       _loaded = true;
//       print('Loading done');
//     });
//
//     _startTimer();
//   }
//
//   Future<ui.Image> _getImage(ImageProvider image) async {
//     final completer = Completer<ImageInfo>();
//     image.resolve(const ImageConfiguration()).addListener(
//       ImageStreamListener((info, _) {
//         completer.complete(info);
//       }),
//     );
//     ImageInfo imageInfo = await completer.future;
//     return imageInfo.image;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: Colors.grey.shade700,
//           appBar: AppBar(
//             title: Text('Puzzle Screen'),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.refresh),
//                 onPressed: () {
//                   _prepareGame();
//                 },
//               ),
//             ],
//           ),
//           body: _loaded
//               ? Column(
//             children: [
//               Container(
//                 height: 400,
//                 alignment: Alignment.center,
//                 child: _buildBoard(),
//               ),
//               Expanded(
//                 child: ListView.separated(
//                   padding: EdgeInsets.all(32),
//                   scrollDirection: Axis.horizontal,
//                   physics: BouncingScrollPhysics(),
//                   itemCount: pieceOnPool.length,
//                   itemBuilder: (context, index) {
//                     final piece = pieceOnPool[index];
//                     return Center(
//                       child: Draggable(
//                         child: piece,
//                         feedback: piece,
//                         childWhenDragging: Opacity(
//                           opacity: 0.24,
//                           child: piece,
//                         ),
//                         onDragEnd: (details) {
//                           _onPiecePlaced(piece, details.offset);
//                         },
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, index) =>
//                       SizedBox(width: 32),
//                 ),
//               ),
//             ],
//           )
//               : Center(child: CircularProgressIndicator()),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               if (canvasImage != null) {
//                 _showFullImageDialog(context);
//               }
//             },
//             child: Icon(Icons.image),
//           ),
//         ),
//         if (_currentPiece != null)
//           AnimatedBuilder(
//             animation: _animController,
//             builder: (context, child) {
//               final offset = _offsetAnimation?.value ?? Offset.zero;
//               return Positioned(
//                 left: offset.dx,
//                 top: offset.dy,
//                 child: child!,
//               );
//             },
//             child: _currentPiece,
//           ),
//       ],
//     );
//   }
//
//   Widget _buildBoard() {
//     return Container(
//       key: _boardWidgetKey,
//       width: 300,
//       height: 300,
//       color: Colors.grey.shade800,
//       child: Stack(
//         children: [
//           for (var piece in pieceOnBoard)
//             Positioned(
//               left: piece.boundary.left,
//               top: piece.boundary.top,
//               child: piece,
//             ),
//         ],
//       ),
//     );
//   }
//
//   List<JigsawPiece> _createJigsawPiece() {
//     return [
//       for (int i = 0; i < widget.factor; i++)
//         for (int j = 0; j < widget.factor; j++)
//           JigsawPiece(
//             key: UniqueKey(),
//             image: canvasImage,
//             imageSize: Size(300, 300),
//             points: [
//               Offset((i / widget.factor) * 300, (j / widget.factor) * 300),
//               Offset(((i + 1) / widget.factor) * 300, (j / widget.factor) * 300),
//               Offset(((i + 1) / widget.factor) * 300, ((j + 1) / widget.factor) * 300),
//               Offset((i / widget.factor) * 300, ((j + 1) / widget.factor) * 300),
//             ],
//           ),
//     ];
//   }
//
//   void _onPiecePlaced(JigsawPiece piece, Offset pieceDropPosition) {
//     _totalMoves++; // Increment total moves
//     final RenderBox box =
//     _boardWidgetKey.currentContext?.findRenderObject() as RenderBox;
//     final boardPosition = box.localToGlobal(Offset.zero);
//     final targetPosition =
//     boardPosition.translate(piece.boundary.left, piece.boundary.top);
//
//     const threshold = 48.0;
//
//     final distance = (pieceDropPosition - targetPosition).distance;
//     if (distance < threshold) {
//       setState(() {
//         _currentPiece = piece;
//         pieceOnPool.remove(piece);
//         _movesMade++; // Increment correct moves
//       });
//
//       _offsetAnimation = Tween<Offset>(
//         begin: pieceDropPosition,
//         end: targetPosition,
//       ).animate(_animController);
//
//       _animController.addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           setState(() {
//             pieceOnBoard.add(piece);
//             _currentPiece = null;
//           });
//
//           if (pieceOnPool.isEmpty) {
//             _stopTimer();
//             _calculateScore(); // Calculate score when the puzzle is complete
//             _showCompletionDialog(context);
//           }
//         }
//       });
//
//       const spring = SpringDescription(
//         mass: 30,
//         stiffness: 1,
//         damping: 1,
//       );
//
//       final simulation = SpringSimulation(spring, 0, 1, -distance);
//       _animController.animateWith(simulation);
//     }
//   }
//
//   void _calculateScore() {
//     final incorrectMoves = _totalMoves - _movesMade; // Calculate incorrect moves
//
//     // Base score calculation
//     double baseScore = 100.0;
//
//     // Deduct points based on time taken
//     baseScore -= (_timeElapsed / 10).clamp(0, 50);
//
//     // Deduct points for incorrect moves
//     baseScore -= (incorrectMoves * 2).clamp(0, 40);
//
//     // Add difficulty bonus
//     baseScore += (widget.difficulty * 5).clamp(0, 20);
//
//     // Ensure score is within bounds
//     _score = baseScore.clamp(0, 100).round();
//   }
//
//
//   void _showCompletionDialog(BuildContext context) {
//     final incorrectMoves = _totalMoves - _movesMade;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Congratulations!', style: TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('You have completed the puzzle!', style: TextStyle(color: Colors.white70)),
//               SizedBox(height: 16),
//               Text('Time Taken: $_timeElapsed seconds', style: TextStyle(color: Colors.white70)),
//               Text('Correct Moves: $_movesMade', style: TextStyle(color: Colors.white70)),
//               Text('Wrong Moves: $incorrectMoves', style: TextStyle(color: Colors.white70)),
//               Text('Score: $_score/100', style: TextStyle(color: Colors.white70)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   // MaterialPageRoute(
//                   //   // builder: (context) => PuzzleResultsScreen(
//                   //   //   difficulty: widget.difficulty,
//                   //   //   moves: _totalMoves,
//                   //   //   timeTaken: _timeElapsed,
//                   //   //   score: _score,
//                   //   // ),
//                   // ),
//                 );
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   void _showFullImageDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Complete Image', style: TextStyle(color: Colors.white),),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (canvasImage != null)
//                 SizedBox(
//                   height: 300,
//                   child: RawImage(image: canvasImage),
//                 ),
//               SizedBox(height: 16),
//               Text('Time Taken: $_timeElapsed seconds', style: TextStyle(color: Colors.white70)),
//               Text('Moves Made: $_movesMade', style: TextStyle(color: Colors.white70)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
// }
//
// class JigsawPiece extends StatelessWidget {
//   JigsawPiece({
//     Key? key,
//     required this.image,
//     required this.points,
//     required this.imageSize,
//   })  : assert(points.isNotEmpty),
//         boundary = _getBounds(points),
//         super(key: key);
//
//   final Rect boundary;
//   final ui.Image? image;
//   final List<Offset> points;
//   final Size imageSize;
//
//   Size get size => boundary.size;
//
//   @override
//   Widget build(BuildContext context) {
//     final pixelScale = MediaQuery.of(context).devicePixelRatio;
//
//     return CustomPaint(
//       painter: JigsawPainter(
//         image: image,
//         boundary: boundary,
//         points: points,
//         pixelScale: pixelScale,
//         elevation: 0,
//       ),
//       size: size,
//     );
//   }
//
//   static Rect _getBounds(List<Offset> points) {
//     final pointsX = points.map((e) => e.dx);
//     final pointsY = points.map((e) => e.dy);
//     return Rect.fromLTRB(
//       pointsX.reduce(min),
//       pointsY.reduce(min),
//       pointsX.reduce(max),
//       pointsY.reduce(max),
//     );
//   }
// }
//
// class JigsawPainter extends CustomPainter {
//   final ui.Image? image;
//   final List<Offset> points;
//   final Rect boundary;
//   final double pixelScale;
//   final double elevation;
//
//   const JigsawPainter({
//     required this.image,
//     required this.points,
//     required this.boundary,
//     required this.pixelScale,
//     this.elevation = 0,
//   });
//
//   @override
//   void paint(ui.Canvas canvas, ui.Size size) {
//     final paint = Paint();
//     final path = getClip(size);
//     if (elevation > 0) {
//       canvas.drawShadow(path, Colors.black, elevation, false);
//     }
//
//     canvas.clipPath(path);
//     if (image != null) {
//       canvas.drawImageRect(
//           image!,
//           Rect.fromLTRB(boundary.left * pixelScale, boundary.top * pixelScale,
//               boundary.right * pixelScale, boundary.bottom * pixelScale),
//           Rect.fromLTWH(0, 0, boundary.width, boundary.height),
//           paint);
//     }
//   }
//
//   Path getClip(Size size) {
//     final path = Path();
//     for (var point in points) {
//       if (points.indexOf(point) == 0) {
//         path.moveTo(point.dx - boundary.left, point.dy - boundary.top);
//       } else {
//         path.lineTo(point.dx - boundary.left, point.dy - boundary.top);
//       }
//     }
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldRepaint(covariant JigsawPainter oldDelegate) {
//     return oldDelegate.image != image;
//   }
// }
