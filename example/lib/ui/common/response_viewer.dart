import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResponseViewer extends StatelessWidget {
  final String text;
  final BoxConstraints? constraints;

  const ResponseViewer({
    super.key,
    required this.text,
    this.constraints = const BoxConstraints(maxHeight: 300),
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(top: 20),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "JSON Response",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            if (constraints != null)
              Container(
                constraints: constraints,
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'Courier',
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: Container(
                  constraints: constraints,
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
