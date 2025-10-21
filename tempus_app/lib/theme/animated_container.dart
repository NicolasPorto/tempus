class _SubjectsScreenState extends State<SubjectsScreen> with SingleTickerProviderStateMixin {
  final store = StorageService.instance;
  final TextEditingController _ctrl = TextEditingController();
  Color selectedColor = Colors.indigo;

  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();

    if (store.subjects.isNotEmpty) selectedColor = store.subjects.first.colorValue;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _color1 = ColorTween(begin: Colors.purple, end: Colors.blue).animate(_controller);
    _color2 = ColorTween(begin: Colors.black, end: Colors.indigo).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _ctrl.dispose();
    super.dispose();
  }
