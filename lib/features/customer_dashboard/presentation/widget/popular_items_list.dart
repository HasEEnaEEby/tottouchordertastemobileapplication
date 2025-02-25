import 'package:flutter/material.dart';

class PopularItemsList extends StatelessWidget {
  const PopularItemsList({super.key});

  final List<Map<String, dynamic>> _popularItems = const [
    {
      "name": "Melting Cheese Pizza",
      "price": "\$9.99",
      "calories": "44 Calories",
      "time": "20 min",
      "image":
          "https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?q=80&w=3687&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      "name": "Big Beef Burger",
      "price": "\$6.49",
      "calories": "36 Calories",
      "time": "15 min",
      "image":
          "https://images.unsplash.com/photo-1593504049359-74330189a345?q=80&w=3375&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
      crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Popular Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text("See All")),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularItems.length,
            itemBuilder: (context, index) {
              final item = _popularItems[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 4)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Add this to fix inner column overflow
                  children: [
                    ClipRRect(
                      // Wrap image in ClipRRect to ensure it doesn't overflow
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item["image"],
                        height: 60,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 60,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.image_not_supported)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1, // Limit to 1 line to prevent overflow
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["price"],
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Flexible(
                          // Add Flexible to prevent text overflow
                          child: Text(
                            item["calories"],
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Flexible(
                          // Add Flexible to prevent text overflow
                          child: Text(
                            item["time"],
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
