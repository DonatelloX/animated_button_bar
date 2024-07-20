import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//initialIndex --> default button
//ButtonBarEntry --> different color for each button

///A row of buttons with animated selection
class AnimatedButtonBar extends StatefulWidget {
  ///Duration for the selection animation
  final Duration animationDuration;
  final int initialIndex;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double radius;

  ///A list of [ButtonBarEntry] to display
  final List<ButtonBarEntry> children;
  final double innerVerticalPadding;
  final double elevation;
  final Color? borderColor;
  final double? borderWidth;
  final Curve curve;
  final EdgeInsets padding;

  ///Invert color of the child when true
  final bool invertedSelection;

  ///Allows to programatically interact with widget
  final AnimatedButtonController? controller;

  const AnimatedButtonBar({
    super.key,
    required this.children,
    this.animationDuration = const Duration(milliseconds: 250),
    this.backgroundColor,
    this.foregroundColor,
    this.radius = 0.0,
    this.innerVerticalPadding = 8.0,
    this.elevation = 0,
    this.borderColor,
    this.controller,
    this.borderWidth,
    this.curve = Curves.fastOutSlowIn,
    this.padding = const EdgeInsets.all(0),
    this.invertedSelection = false,
    this.initialIndex = 0,
  });

  @override
  _AnimatedButtonBarState createState() => _AnimatedButtonBarState();
}

class _AnimatedButtonBarState extends State<AnimatedButtonBar> {
  late AnimatedButtonController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? AnimatedButtonController();
    _controller.setIndex(widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return ChangeNotifierProvider(
      create: (context) => _controller,
      child: Consumer<AnimatedButtonController>(
        builder: (context, animatedButton, child) {
          return Padding(
            padding: widget.padding,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Card(
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                    side: BorderSide(
                      color: widget.borderColor ?? Colors.transparent,
                      width: widget.borderWidth ??
                          (widget.borderColor != null ? 1.0 : 0.0),
                    ),
                  ),
                  elevation: widget.elevation,
                  child: Stack(
                    fit: StackFit.loose,
                    children: [
                      AnimatedPositioned(
                        top: 0,
                        bottom: 0,
                        left: constraints.maxWidth / widget.children.length * animatedButton.index,
                        right: (constraints.maxWidth / widget.children.length) *
                            (widget.children.length - animatedButton.index - 1),
                        duration: widget.animationDuration,
                        curve: widget.curve,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.children[animatedButton.index].color ??
                                widget.foregroundColor ??
                                Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                          ),
                        ),
                      ),
                      Row(
                        children: widget.children
                            .asMap()
                            .map((i, sideButton) => MapEntry(
                          i,
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                try {
                                  sideButton.onTap();
                                } catch (e) {
                                  print('onTap implementation is missing');
                                }
                                animatedButton.setIndex(i);
                              },
                              borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: widget.innerVerticalPadding),
                                child: Center(
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        animatedButton.index == i
                                            ? (widget.invertedSelection ? backgroundColor : (sideButton.color ?? widget.foregroundColor ?? Theme.of(context).colorScheme.secondary))
                                            : backgroundColor,
                                        animatedButton.index == i && widget.invertedSelection
                                            ? BlendMode.srcIn
                                            : BlendMode.dstIn
                                    ),
                                    child: sideButton.child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ))
                            .values
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ButtonBarEntry {
  final Widget child;
  final VoidCallback onTap;
  final Color? color; // Nuovo parametro per il colore
  ButtonBarEntry({required this.child, required this.onTap, this.color});
}

///controller for AnimatedButtonBar widget
class AnimatedButtonController extends ChangeNotifier {
  int index = 0;

  ///change the index programmatically
  void setIndex(int requestedIndex) {
    index = requestedIndex;
    notifyListeners();
  }
}
