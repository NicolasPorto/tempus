import 'package:flutter/material.dart';

/// Um widget que fornece um fundo de gradiente de cor animado.
class AnimatedBackground extends StatefulWidget {
  /// O widget filho que será colocado sobre o fundo animado.
  final Widget child;

  const AnimatedBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true); // Repete a animação, revertendo a direção

    // Sequência de cores para o PONTO 1 do gradiente: Roxo -> Azul -> Roxo
    _color1Animation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.purple.shade700, end: Colors.blue.shade700),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.blue.shade700, end: Colors.purple.shade700),
        weight: 1.0,
      ),
    ]).animate(_controller);

    // Sequência de cores para o PONTO 2 do gradiente: Preto -> Roxo Escuro -> Preto
    _color2Animation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.black, end: Colors.purple.shade900),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.purple.shade900, end: Colors.black),
        weight: 1.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usa AnimatedBuilder para reconstruir o Container a cada tick da animação
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_color1Animation.value!, _color2Animation.value!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child, // O widget filho é colocado sobre o fundo
        );
      },
    );
  }
}