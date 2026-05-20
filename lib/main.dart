import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CoffeeApp());
}

class CoffeeApp extends StatelessWidget {
  const CoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoffeeTracker(),
    );
  }
}

class CoffeeTracker extends StatefulWidget {
  const CoffeeTracker({super.key});

  @override
  State<CoffeeTracker> createState() => _CoffeeTrackerState();
}

class _CoffeeTrackerState extends State<CoffeeTracker>
    with SingleTickerProviderStateMixin {
  int cups = 0;
  int limit = 5;

  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  @override
  void initState() {
    super.initState();

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    shakeAnimation = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeController);
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }

  void drinkCoffee() {
    if (cups < limit) {
      setState(() => cups++);
      if (cups == limit) {
        shakeController.forward(from: 0);
      }
    }
  }

  void resetCoffee() {
    setState(() => cups = 0);
  }

  @override
  Widget build(BuildContext context) {
    final double fillPercent =
        limit == 0 ? 0.0 : (cups / limit).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Coffee glass with shake animation
                        AnimatedBuilder(
                          animation: shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                sin(shakeAnimation.value * pi * 6) * 10,
                                0,
                              ),
                              child: child,
                            );
                          },
                          child: CoffeeGlass(fillPercent: fillPercent),
                        ),

                        const SizedBox(height: 20),

                        // Cups counter
                        Text(
                          "Cups today: $cups / $limit",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        // Limit reached warning
                        if (cups >= limit)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "🚫 No more coffee allowed today",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: cups >= limit ? null : drinkCoffee,
                              child: Opacity(
                                opacity: cups >= limit ? 0.5 : 1.0,
                                child: Image.asset(
                                  'assets/images/drink_coffee_button.png',
                                  width: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 150,
                                      height: 50,
                                      color: Colors.brown,
                                      child: const Center(
                                          child: Text(
                                        "Drink Coffee",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                    );
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: resetCoffee,
                              child: Image.asset(
                                'assets/images/reset.png',
                                width: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 150,
                                    height: 50,
                                    color: Colors.grey,
                                    child: const Center(
                                        child: Text(
                                      "Reset",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Slider for daily limit
                        Column(
                          children: [
                            const Text(
                              "Daily limit",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Slider(
                              value: limit.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 9,
                              label: limit.toString(),
                              activeColor: Colors.brown[700],
                              inactiveColor: Colors.brown[200],
                              onChanged: (value) {
                                setState(() {
                                  limit = value.toInt();
                                  if (cups > limit) cups = limit;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Coffee glass widget
class CoffeeGlass extends StatelessWidget {
  final double fillPercent;

  const CoffeeGlass({super.key, required this.fillPercent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 360,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 15,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: fillPercent.clamp(0.0, 1.0),
                child: Image.asset(
                  'assets/images/fillcoffee.png',
                  width: 150,
                  height: 270,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 270,
                      color: Colors.brown[300],
                    );
                  },
                ),
              ),
            ),
          ),
          Image.asset(
            'assets/images/coffeecup.png',
            width: 260,
            height: 360,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 260,
                height: 360,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

