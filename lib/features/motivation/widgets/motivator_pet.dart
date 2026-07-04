import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';

class MotivatorPet extends StatefulWidget {
  const MotivatorPet({super.key});

  @override
  State<MotivatorPet> createState() => _MotivatorPetState();
}

class _MotivatorPetState extends State<MotivatorPet> {
  String _message = "Tap me!";
  bool _showBubble = false;

  void _saySomething(bool isHappy) {
    // Haptic feedback for better user experience (enterprise standard)
    HapticFeedback.lightImpact();

    final happyMsgs = [
      "Meow! Great!",
      "All done!",
      "I'm happy!",
      "Good job!",
      "You're awesome!"
    ];
    final sadMsgs = [
      "Will you help me?",
      "Waiting for you...",
      "Let's do these tasks!",
      "I'm feeling sad...",
      "You can do it!"
    ];
    
    setState(() {
      _message = (isHappy ? happyMsgs : sadMsgs)[Random().nextInt(happyMsgs.length)];
      _showBubble = true;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showBubble = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final isHappy = !taskProvider.hasPendingUserTasks;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHappy 
                ? [Colors.green.shade50, Colors.white] 
                : [Colors.orange.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (isHappy ? Colors.green : Colors.orange).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _saySomething(isHappy),
            borderRadius: BorderRadius.circular(30),
            child: Row(
              children: [
                // Pet (Lottie animation from assets/lottie)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Lottie.asset(
                        isHappy 
                          ? 'assets/lottie/cat-happy.json' 
                          : 'assets/lottie/cat-cry.json',
                        fit: BoxFit.contain,
                        errorBuilder: (context, e, s) => Icon(
                          isHappy ? Icons.pets : Icons.pest_control_rodent,
                          size: 60,
                          color: isHappy ? Colors.green[300] : Colors.orange[300],
                        ),
                      ),
                    ),
                    if (_showBubble)
                      Positioned(
                        top: -30,
                        right: -10,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Text(
                                  _message,
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                // Motivational text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHappy ? "Your kitty is proud!" : "Kitty is waiting for you...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isHappy ? Colors.green.shade800 : Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHappy 
                          ? "All tasks for today are done. Good job!" 
                          : "You still have tasks to do. Don't let him down!",
                        style: TextStyle(
                          color: Colors.grey.shade600, 
                          fontSize: 13,
                          height: 1.3
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
