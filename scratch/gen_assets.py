def generate_dialogue_assets(start, end, frames_count):
    for i in range(start, end + 1):
        print(f"  static const List<String> case10Dialogue{i} = [")
        for f in range(1, frames_count + 1):
            print(f"    'assets/case10-dialogue{i}/dialogue{i}/{f}.png',")
        print("  ];\n")

generate_dialogue_assets(3, 8, 19)
